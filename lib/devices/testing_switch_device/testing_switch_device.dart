import 'package:flutter/material.dart';
import 'package:koti/devices/testing_switch_device/view/edit_testing_switch_device_view.dart';
import '../../estate/estate.dart';
import '../../logic/services.dart';
import '../../logic/unique_id.dart';
import '../../logic/state_broker.dart';
import '../../service_catalog.dart';
import '../device/device.dart';

class TestingSwitchDevice extends Device {

  StateBoolNotifier _on = StateBoolNotifier(false);

  void _initOfferedServices() {
    services = Services([
      RWDeviceService<bool>(serviceName: powerOnOffService, setFunction: setPower, getFunction: getPower),
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

  @override
  Future<void> init () async {
    Estate myEstate = myEstates.estateFromId(myEstateId);
    await super.init();
    myEstate.stateBroker.initNotifyingBoolStateInformer(
        device: this,
        serviceName: powerOnOffService,
        stateBoolNotifier: _on,
        dataReadingFunction: switchStatus);

  }

  bool switchToggle() {
    setPower(!_on.data);
    return _on.data;
  }

  bool switchStatus() {
    return _on.data;
  }

  void setPower(bool value) {
    _on.data = value;
  }

  bool getPower()  {
    return _on.data;
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


}
