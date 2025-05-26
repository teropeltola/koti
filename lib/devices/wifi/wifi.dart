
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:koti/logic/observation.dart';

import '../../estate/estate.dart';
import '../../logic/unique_id.dart';
import '../../look_and_feel.dart';
import '../device/device.dart';
import '../device/device_state.dart';

class Wifi extends Device {

  Wifi();

  bool isMyWifi(String currentWifiName) {
    return (currentWifiName != '') && (name == currentWifiName);
  }

  @override
  Future<void> init () async {
    await super.init();
    state.defineDependency(stateDependantOnWifi, name);
  }

  void initWifi(String myWifiName) {
    name = myWifiName;
    id = UniqueId('wifi').get();
    state.defineDependency(stateDependantOnWifi, name);
  }

  void changeWifiName(String newWifiName) {
    name = newWifiName;
    bool oldStatus = state.connected();

    state.defineDependency(stateDependantOnWifi, name);

    if (oldStatus != state.connected()) {
      observationMonitor.add(ObservationLogItem(DateTime.now(),ObservationLevel.informatic));
    }
  }


  // this is used in UI to get immediate updates
  bool reactiveIsActiveStatus(BuildContext context) {
    // TODO: NOT YET WORKING
    return state.connected();
  }

  @override
  Future<bool> editWidget(BuildContext context, Estate estate) async {
    await informMatterToUser(context, 'wifi-laitteen tietoja ei voi muuttaa', 'Wifin nimen voi muuttaa asunnon tiedoista');
    return false;
  }

  @override
  IconData icon() {
    return Icons.wifi;
  }

  @override
  Color ownColor() {
    return Colors.blue;
  }

  @override
  String shortTypeName() {
    return 'wifi';
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
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  Wifi.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }

  @override
  void dispose() {
    super.dispose();
  }

}