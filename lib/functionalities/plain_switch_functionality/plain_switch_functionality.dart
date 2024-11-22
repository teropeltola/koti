
import 'package:flutter/material.dart';

import 'package:koti/functionalities/plain_switch_functionality/view/plain_switch_functionality_view.dart';

import '../../devices/device/device.dart';
import '../../devices/shelly_timer_switch/shelly_timer_switch.dart';
import '../../logic/services.dart';
import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class PlainSwitchFunctionality extends Functionality {

  static const String functionalityName = 'sähkökytkin';

  PlainSwitchFunctionality();

  late RWAsyncDeviceService<bool> mySwitchDeviceService;
  bool _power = false;

  @override

  Future<void> init () async {
    mySwitchDeviceService = myDevice().services.getService('powerOnOffService') as RWAsyncDeviceService<bool>;
    await switchStatus();
  }

  Device myDevice() {
    // todo: not nice but we know that PlainSwitch has only one device
    return connectedDevices[0];
  }

  Future<bool> toggle() async {
    _power = ! _power;
    await mySwitchDeviceService.set(_power);
    return _power;
  }

  Future <void> setPower(bool newValue) async {
    _power = newValue;
    await mySwitchDeviceService.set(newValue);
  }

  Future<bool> switchStatus() async {
    _power =  await mySwitchDeviceService.get();
    return _power;
  }

  bool switchStatusPeak()  {
    return _power;
  }


  @override
  PlainSwitchFunctionality clone() {
    return PlainSwitchFunctionality.fromJson(toJson());
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
  FunctionalityView myView() {
    return PlainSwitchFunctionalityView(this);
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  PlainSwitchFunctionality.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
  }
}