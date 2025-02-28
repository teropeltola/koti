import 'package:flutter/material.dart';
import 'package:koti/devices/testing_switch_device/view/edit_testing_switch_device_view.dart';
import '../../estate/estate.dart';
import '../../logic/services.dart';
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

    await initSwitch(
        myEstate: myEstates.estateFromId(myEstateId),
        device: this,
        boxName: _trendBoxName(),
        getFunction: asyncGetPower,
        setFunction: asyncSetPower,
        peekFunction: switchStatus
    );

    services.addService(onOffServiceDefinition());

    trendBox.add(TrendSwitch(DateTime.now().millisecondsSinceEpoch, myEstateId, id, switchStatus(), 'alustus käynnistyksessä'));

  }

  bool switchToggle() {
    setPower(!switchOn.data, 'Painokytkin');
    return switchOn.data;
  }

  bool switchStatus() {
    return switchOn.data;
  }

  void setPower(bool value, String caller) {
    switchOn.data = value;
    trendBox.add(TrendSwitch(DateTime.now().millisecondsSinceEpoch, myEstateId, id, value, caller));
  }

  bool getPower()  {
    return switchOn.data;
  }

  Future <void> asyncSetPower(bool value, String caller) async {
    setPower(value, caller);
  }

  Future <bool> asyncGetPower() async {
    return getPower();
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: name,
        textLines: [
          'tunnus: $id',
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
        }));

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


