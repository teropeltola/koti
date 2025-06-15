import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:koti/devices/testing_switch_device/view/edit_testing_switch_device_view.dart';
import '../../estate/estate.dart';
import '../../foreground_configurator.dart';
import '../../interfaces/foreground_interface.dart';
import '../../logic/services.dart';
import '../../logic/task_handler_controller.dart';
import '../../logic/unique_id.dart';
import '../../service_catalog.dart';
import '../../trend/trend_switch.dart';
import '../device/device.dart';
import '../mixins/on_off_switch.dart';

class TestingSwitchDevice extends Device with OnOffSwitch {

  void _initOfferedServices() {
    services = Services([
      AttributeDeviceService(attributeName: deviceWithManualCreation)
    ]);
  }

  TestingSwitchDevice() {
    _setUniqueId();
    _initOfferedServices();
  }

  @override
  _setUniqueId() {
    id = UniqueId('testing').get();
  }

  @override
  setOk() {
    _setUniqueId();
  }

  String _trendBoxName() {
    return id;
  }

  @override
  Future<void> init () async {
    Estate myEstate = myEstates.estateFromId(myEstateId);
    await super.init();
    state.setConnected();

    await initSwitch(
        myEstate: myEstates.estateFromId(myEstateId),
        device: this,
        boxName: _trendBoxName(),
        getFunction: asyncGetPower,
        setFunction: asyncSetPower,
        peekFunction: switchStatus,
        defineTask: defineTask
    );

    services.addService(onOffServiceDefinition());

    trendBox.add(TrendSwitch(DateTime.now().millisecondsSinceEpoch, myEstateId, id, switchStatus(), 'alustus käynnistyksessä'));

  }

  bool switchToggle() {
    setPower(!onOffService.switchOn.data, 'Painokytkin');
    return onOffService.switchOn.data;
  }

  bool switchStatus() {
    return onOffService.switchOn.data;
  }

  void setPower(bool value, String caller) {
    onOffService.switchOn.data = value;
    trendBox.add(TrendSwitch(DateTime.now().millisecondsSinceEpoch, myEstateId, id, value, caller));
  }

  bool getPower()  {
    return onOffService.switchOn.data;
  }

  Future <void> asyncSetPower(bool value, String caller) async {
    setPower(value, caller);
  }

  Future <bool> asyncGetPower() async {
    return getPower();
  }

  Future<bool> defineTask(Map<String, dynamic> parameters) async {
    // todo: check the parameters from the caller
    // update own parameters
    parameters[idKey] = foregroundCreateUniqueId(id);
    bool status = await foregroundInterface.defineUserTask(testOnOffForegroundService, parameters);
    foregroundInterface.foregroundData.setServiceListener(testOnOffForegroundService, id, _foregroundListener);

    return status;
  }

  void _foregroundListener(Map<String, dynamic> data) {
    print('main: foregroundListener');
    setPower(data[powerOn] ?? false, 'tehtävä');
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: name,
        textLines: [
          'tunnus: $id',
          'tila: ${state.stateText()}',
        ],
        widgets: [
          dumpDataMyFunctionalities(formatterWidget: formatterWidget),
        ]
    );
  }

  @override
  Future<bool> editWidget(BuildContext context, Estate estate) async {
    return await Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return EditTestingSwitchDeviceView(
              estate: estate,
              testingSwitchDevice: this,
              callback: (){}
          );
        })
    );
  }


  @override
  IconData icon() {
    return Icons.power;
  }

  @override
  String shortTypeName() {
    return 'testikytkin';
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  TestingSwitchDevice.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    _initOfferedServices();
  }


  @override
  TestingSwitchDevice clone() {
    return TestingSwitchDevice.fromJson(toJson());
  }

  @override
  bool isReusableForFunctionalities() {
    return true;
  }
}

// foreground routines - not using the same address space
Future<bool> testOnOffInitFunction(TaskHandlerController controller, Map<String, dynamic> inputData) async {
  return true;
}

Future<bool> testOnOffExecutionFunction(TaskHandlerController controller, Map<String, dynamic> inputData) async {
  print('foreground: testOnOffExecutionFunction');
  Map<String, dynamic> response = {
    messageKey: responseMessage,
    serviceNameKey: testOnOffForegroundService,
    idKey: inputData[idKey] ?? 'idNotFound',
    powerOn: inputData[powerOn] ?? false
  };
  FlutterForegroundTask.sendDataToMain(response);
  return true;
}

