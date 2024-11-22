import 'package:flutter/material.dart';
import '../../logic/services.dart';
import '../../service_catalog.dart';
import '../shelly/shelly_device.dart';

class ShellyTimerSwitch extends ShellyDevice {

  bool _on = false;

  void _initOfferedServices() {
      services = Services([
        RWAsyncDeviceService<bool>(serviceName: powerOnOffAsyncService, setFunction: setPower, getFunction: getPower),
        RWDeviceService<bool>(serviceName: powerOnOffService, setFunction: setPower, getFunction: switchStatus)
      ]);
  }

  ShellyTimerSwitch() {
    _initOfferedServices();
  }

  @override
  Future<void> init () async {
    await super.init();
    _on = false; // TODO: TEMP await powerOutputOn(0);
  }

  bool switchToggle() {
    setPower(!_on);
    return _on;
  }

  bool switchStatus() {
    // todo: should we read from the device?
    return _on;
  }

  Future <void> setPower(bool value) async {
    _on = value;
    await setSwitchOn(0, _on);
  }

  Future<bool> getPower() async {
    return await powerOutputOn(0);
  }


  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: name,
        textLines: [
          'tunnus: $id',
          'IP-osoite: $ipAddress',
        ],
        widgets: [
          dumpDataMyFunctionalities(formatterWidget: formatterWidget),
        ]
    );
  }

  @override
  IconData icon() {
    return Icons.power;
  }

  @override
  String shortTypeName() {
    return 'shelly plus plug';
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  ShellyTimerSwitch.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    _initOfferedServices();
  }

}