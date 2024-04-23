import 'package:flutter/material.dart';
import 'package:koti/devices/shelly/json/shelly_input_config.dart';

import '../../estate/estate.dart';
import '../../functionalities/functionality/functionality.dart';
import '../device/device.dart';
import '../device/view/edit_device_view.dart';
import '../shelly/json/shelly_switch_config.dart';
import '../shelly/json/switch_get_status.dart';
import '../shelly/shelly_device.dart';

enum ShellyPro2Id {
  id0,
  id1,
  both;
  int id() => this.index;
}

class ShellyPro2 extends ShellyDevice {

  List<ShellySwitchConfig> switchConfigList = [ShellySwitchConfig.empty(), ShellySwitchConfig.empty()];
  List<ShellySwitchStatus> switchStatusList = [ShellySwitchStatus.empty(), ShellySwitchStatus.empty()];
  List<ShellyInputConfig> inputConfigList = [ShellyInputConfig.empty(),   ShellyInputConfig.empty()];

  ShellyPro2();

  bool switchToggle(ShellyPro2Id id) {
    if (id == ShellyPro2Id.id0) {
      switchStatusList[0].output = ! switchStatusList[0].output;
      setPower(ShellyPro2Id.id0,switchStatusList[0].output);
      return switchStatusList[0].output;
    } else if (id == ShellyPro2Id.id1) {
      switchStatusList[1].output = ! switchStatusList[1].output;
      setPower(ShellyPro2Id.id1,switchStatusList[1].output);
      return switchStatusList[1].output;
    }
    else { // both
      switchStatusList[0].output = ! switchStatusList[0].output;
      switchStatusList[1].output = ! switchStatusList[1].output;
      setPower(ShellyPro2Id.id0,switchStatusList[0].output);
      setPower(ShellyPro2Id.id1,switchStatusList[1].output);
      return switchStatusList[0].output || switchStatusList[1].output;
    }
  }

  bool switchStatus(ShellyPro2Id id) {
    if (id == ShellyPro2Id.both) {
      return switchStatusList[0].output || switchStatusList[1].output;
    }
    else {
      return switchStatusList[id.id()].output;
    }
  }

  Future<void> setPower(ShellyPro2Id id, bool on) async {
    if (id == ShellyPro2Id.both) {
      await setPower(ShellyPro2Id.id0, on);
      await setPower(ShellyPro2Id.id1, on);
    }
    else {
      await setSwitchOn(id.id(), on);
      switchStatusList[id.id()].output = on;
    }
  }

  Future<void> getDataFromDevice() async {

    switchConfigList[0] = await switchGetConfig(0);
    switchConfigList[1] = await switchGetConfig(1);
    switchStatusList[0] = await switchGetStatus(0);
    switchStatusList[1] = await switchGetStatus(1);
    inputConfigList[0] = await inputGetConfig(0);
    inputConfigList[1] = await inputGetConfig(1);

  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  ShellyPro2.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }

}