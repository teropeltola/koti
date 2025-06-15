import 'package:flutter/material.dart';
import 'package:koti/devices/mixins/on_off_switch.dart';
import 'package:koti/foreground_configurator.dart';
import '../../estate/estate.dart';
import '../../interfaces/foreground_interface.dart';
import '../../logic/services.dart';
import '../../trend/trend_switch.dart';
import '../shelly/shelly_device.dart';

class ShellyTimerSwitch extends ShellyDevice with OnOffSwitch {

  void _initOfferedServices() {
      services = Services([
        onOffServiceDefinition()
      ]);
  }

  ShellyTimerSwitch();

  @override
  Future<void> init () async {

    await super.init();

    if (state.connected()) {
      await initSwitch(
          myEstate: myEstates.estateFromId(myEstateId),
          device: this,
          boxName: id,
          getFunction: getPower,
          setFunction: setPower,
          peekFunction: switchStatus,
          defineTask: _defineTask
      );

      _initOfferedServices();

      trendBox.add(TrendSwitch(DateTime
          .now()
          .millisecondsSinceEpoch, myEstateId, id, switchStatus(),
          'alustus käynnistyksessä'));
    }
    else {
      setupShellyRetryTimer(init);
    }
  }

  bool switchToggle() {
    setPower(!onOffService.switchOn.data, 'Painokytkin');
    return onOffService.switchOn.data;
  }

  bool switchStatus() {
    // todo: should we read from the device?
    return onOffService.switchOn.data;
  }

  Future <void> setPower(bool value, String caller) async {
    onOffService.switchOn.data = value;
    trendBox.add(TrendSwitch(DateTime.now().millisecondsSinceEpoch, myEstateId, id, value, caller));
    await setSwitchOn(0, onOffService.switchOn.data);
  }

  Future<bool> getPower() async {
    return await powerOutputOn(0);
  }

  Future<bool> _defineTask(Map<String, dynamic> parameters) async {
    // todo: check the parameters from the caller
    // update own parameters
    bool powerParameter = parameters[powerOn] ?? false;
    String _message = createSwitchCommand(0,powerParameter);
    parameters[idKey] = foregroundCreateUniqueId(id);
    parameters[messagesParameter] = [_message];

    bool status = await foregroundInterface.defineUserTask(standardForegroundService, parameters);

    return status;
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
  }

}