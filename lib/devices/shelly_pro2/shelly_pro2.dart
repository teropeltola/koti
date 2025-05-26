import 'package:flutter/material.dart';
import 'package:koti/devices/mixins/on_off_switch.dart';

import 'package:koti/devices/shelly/json/shelly_input_config.dart';
import '../../estate/estate.dart';
import '../../foreground_configurator.dart';
import '../../interfaces/foreground_interface.dart';
import '../../logic/services.dart';
import '../../trend/trend_switch.dart';
import '../shelly/json/shelly_switch_config.dart';
import '../shelly/json/switch_get_status.dart';
import '../shelly/shelly_device.dart';

enum ShellyPro2Id {
  id0,
  id1,
  both;
  int id() => index;

  String get text => (this == ShellyPro2Id.both) ? '' : (this == ShellyPro2Id.id0) ? '(indeksi:0)' : '(indeksi:1)';
}

class ShellyPro2 extends ShellyDevice with OnOffSwitch {

  List<ShellySwitchConfig> switchConfigList = [ShellySwitchConfig.empty(), ShellySwitchConfig.empty()];
  List<ShellySwitchStatus> switchStatusList = [ShellySwitchStatus.empty(), ShellySwitchStatus.empty()];
  List<ShellyInputConfig> inputConfigList = [ShellyInputConfig.empty(),   ShellyInputConfig.empty()];

  void _initOfferedServices() {
    services = Services([
      onOffServiceDefinition(),
    ]);
  }

  ShellyPro2();

  ShellyPro2.failed() {
    setFailed();
  }

  @override
  Future<void> init () async {

    await super.init();

    await initSwitch(
        myEstate: myEstates.estateFromId(myEstateId),
        device: this,
        boxName: id,
        getFunction: getFullPower,
        setFunction: setFullPower,
        peekFunction: () {
          return switchStatus(ShellyPro2Id.both);
        },
        defineTask: _defineTask
    );

    _initOfferedServices();

    if (state.connected()) {

      trendBox.add(TrendSwitch(DateTime
          .now()
          .millisecondsSinceEpoch, myEstateId, id,
          switchStatus(ShellyPro2Id.both), 'alustus käynnistyksessä'));
    }
    else {
      setupShellyRetryTimer(init);
    }
  }


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

  bool getSwitchFullStatus() {
    return switchStatus(ShellyPro2Id.both);
  }

  Future <void> setFullPower(bool value, String caller) async {
    await setPower(ShellyPro2Id.both, value);
    trendBox.add(TrendSwitch(DateTime.now().millisecondsSinceEpoch, myEstateId, id, value, caller));
  }

  Future<bool> getFullPower() async {
    return switchStatus(ShellyPro2Id.both);
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

  Future<bool> _defineTask(Map<String, dynamic> parameters) async {
    // todo: not implemented
    bool powerParameter = parameters[powerOn] ?? false;
    List<String> _messages = [];
    _messages.add(createSwitchCommand(ShellyPro2Id.id0.id(),powerParameter));
    _messages.add(createSwitchCommand(ShellyPro2Id.id1.id(),powerParameter));
    parameters[idKey] = foregroundCreateUniqueId(id);
    parameters[messagesParameter] = _messages;

    bool status = await foregroundInterface.defineUserTask(standardForegroundService, parameters);

    return status;

    return false;
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
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: name,
        textLines: [
          'tunnus: $id',
          'tila: ${state.stateText()}',
          'IP-osoite: $ipAddress',
        ],
        widgets: [
          dumpDataMyFunctionalities(formatterWidget: formatterWidget),
        ]
    );
  }

  @override
  IconData icon() {
    return Icons.electrical_services;
  }

  @override
  String shortTypeName() {
    return 'shelly pro2';
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