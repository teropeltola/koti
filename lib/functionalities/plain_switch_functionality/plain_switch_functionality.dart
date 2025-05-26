
import 'package:flutter/material.dart';
import 'package:koti/devices/mixins/on_off_switch.dart';
import 'package:koti/functionalities/plain_switch_functionality/view/edit_plain_switch_view.dart';

import 'package:koti/functionalities/plain_switch_functionality/view/plain_switch_functionality_view.dart';

import '../../devices/device/device.dart';
import '../../estate/environment.dart';
import '../../estate/estate.dart';
import '../../logic/device_attribute_control.dart';
import '../../logic/services.dart';
import '../../look_and_feel.dart';
import '../../operation_modes/conditional_operation_modes.dart';
import '../../operation_modes/operation_modes.dart';
import '../../service_catalog.dart';
import '../functionality/functionality.dart';

class PlainSwitchFunctionality extends Functionality {

  static const String functionalityName = 'sähkökytkin';

  PlainSwitchFunctionality() {
    myView = PlainSwitchFunctionalityView();
    myView.setFunctionality(this);
  }

  late DeviceServiceClass<OnOffSwitchService> mySwitchDeviceService;

  void initStructures() {

    operationModes.initModeStructure(
        environment: myEstates.currentEstate(),
        parameterSettingFunctionName: '',
        deviceId: connectedDevices.isEmpty ? '' : connectedDevices[0].id,
        deviceAttributes: [DeviceAttributeCapability.directControl],
        setFunction: PlainSwitchSetOperationParametersOn,
        getFunction: getFunction );

    operationModes.addType(ConditionalOperationModes().typeName());
    operationModes.addType(BoolServiceOperationMode().typeName());
  }

  void PlainSwitchSetOperationParametersOn(Map<String, dynamic> parameters) {
    log.error('plainSwitch setFunction not implemented ');
  }

  Map<String, dynamic> getFunction() {
    Map<String, dynamic> map = {};
//    map[temperatureParameterId] = myPumpDevice().setTemperature();
    log.error('plainSwitch getFunction not implemented ');
    return map;
  }

  @override
  Future<void> init () async {
    initStructures();
    var myService = myDevice().services.getService(powerOnOffWaitingService);
    if (myService is DeviceServiceClass<OnOffSwitchService>) {
      mySwitchDeviceService = myService;
    }
  }

  Device myDevice() {
    // todo: not nice but we know that PlainSwitch has only one device
    return connectedDevices.isNotEmpty ? connectedDevices[0] : noDevice;
  }

  Future<bool> toggle() async {
    bool newState =  ! await mySwitchDeviceService.services.get();
    await mySwitchDeviceService.services.set(newState ,caller: 'painokytkin');
    return newState;
  }

  Future <void> setPower(bool newValue) async {
    await mySwitchDeviceService.services.set(newValue);
  }

  Future<bool> switchStatus() async {
    return await mySwitchDeviceService.services.get();
  }

  bool switchStatusPeek()  {
    return mySwitchDeviceService.services.peek();
  }

  @override
  Future<bool> Function(BuildContext context, Environment environment, Functionality functionality, Function callback)  myEditingFunction() {
    return editPlainSwitchFunctionality;
  }

  @override
  Future<bool> editWidget(BuildContext context, bool createNew, Environment environment, Functionality functionality, Device device) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return EditPlainSwitchView(
                environment: environment,
                switchFunctionality: functionality as PlainSwitchFunctionality,
                callback: () {}
            );
          },
        )
    );
  }

  @override
  PlainSwitchFunctionality clone() {
    PlainSwitchFunctionality p = PlainSwitchFunctionality.fromJson(toJson());
    p.initStructures();
    return p;
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: functionalityName,
        textLines: [
          'tunnus: $id',
//          switchStatus() ? 'päällä' : 'suljettu',
        ],
        widgets: [
          dumpDataMyDevices(formatterWidget: formatterWidget)
        ]
    );
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  PlainSwitchFunctionality.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    myView = PlainSwitchFunctionalityView();
    myView.setFunctionality(this);
  }
}

Future<bool> editPlainSwitchFunctionality(BuildContext context, Environment environment, Functionality functionality, Function callback) async {
  bool success = await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return EditPlainSwitchView(
          environment: environment,
          switchFunctionality: functionality as PlainSwitchFunctionality,
          callback: callback
        );
      }));
  return success;
}