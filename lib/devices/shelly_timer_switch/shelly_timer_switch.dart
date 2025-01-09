import 'package:flutter/material.dart';
import 'package:koti/devices/mixins/on_off_switch.dart';
import '../../estate/estate.dart';
import '../../logic/services.dart';
import '../../logic/state_broker.dart';
import '../../service_catalog.dart';
import '../../trend/trend_switch.dart';
import '../shelly/shelly_device.dart';

class ShellyTimerSwitch extends ShellyDevice with OnOffSwitch {

  void _initOfferedServices() {
      services = Services([
        onOffServiceDefinition()
      ]);
  }

  ShellyTimerSwitch() {
  }

  @override
  Future<void> init () async {

    await super.init();

    await initSwitch(
        myEstate: myEstates.estateFromId(myEstateId),
        device: this,
        boxName: id,
        getFunction: getPower,
        setFunction: setPower,
        peekFunction: switchStatus
    );

    _initOfferedServices();

    trendBox.add(TrendSwitch(DateTime.now().millisecondsSinceEpoch, myEstateId, id, switchStatus(), 'alustus käynnistyksessä'));
  }

  bool switchToggle() {
    setPower(!switchOn.data, 'Painokytkin');
    return switchOn.data;
  }

  bool switchStatus() {
    // todo: should we read from the device?
    return switchOn.data;
  }

  Future <void> setPower(bool value, String caller) async {
    switchOn.data = value;
    trendBox.add(TrendSwitch(DateTime.now().millisecondsSinceEpoch, myEstateId, id, value, caller));
    await setSwitchOn(0, switchOn.data);
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
  }

}