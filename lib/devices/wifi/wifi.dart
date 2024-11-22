
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_value/flutter_reactive_value.dart';

import 'package:koti/logic/observation.dart';

import '../../estate/estate.dart';
import '../../logic/unique_id.dart';
import '../../look_and_feel.dart';
import '../device/device.dart';
import '../wlan/active_wifi_name.dart';

class Wifi extends Device {
  late StreamSubscription<String> _wifiActivitySubscription;
  late ActiveWifiBroadcaster _myWifiBroadcaster;

  //bool iAmActive = false;
  var iAmActive = ReactiveValueNotifier<bool>(false);

  Wifi();

  bool isMyWifi(String currentWifiName) {
    return (currentWifiName != '') && (name == currentWifiName);
  }

  @override
  Future<void> init () async {
    await super.init();
    _initWifiListening();
  }

  void _initWifiListening() {
    _myWifiBroadcaster = activeWifiBroadcaster;
    _wifiActivitySubscription = activeWifiBroadcaster.setListener(listenWifiName);
    iAmActive.value = isMyWifi(activeWifiBroadcaster.wifiName());

  }

  void initWifi(String myWifiName) {
    name = myWifiName;
    id = UniqueId('wifi').get();
    _initWifiListening();
  }

  void changeWifiName(String newWifiName) {
    name = newWifiName;
    bool oldStatus = iAmActive.value;

    iAmActive.value = isMyWifi(_myWifiBroadcaster.wifiName());

    if (oldStatus != iAmActive.value) {
      observationMonitor.add(ObservationLogItem(DateTime.now(),ObservationLevel.informatic));
      //broadcast
    }
  }

  void listenWifiName(String currentWifiName) {
    bool oldStatus = iAmActive.value;

    iAmActive.value = isMyWifi(currentWifiName);

    if (oldStatus != iAmActive.value) {

      if (iAmActive.value) {
        observationMonitor.add((ObservationLogItem(DateTime.now(), ObservationLevel.ok)));
      }
      else {
        observationMonitor.add((ObservationLogItem(DateTime.now(), ObservationLevel.warning)));
      }
      //broadcast
    }
  }

  // this is used in UI to get immediate updates
  bool reactiveIsActiveStatus(BuildContext context) {
    return iAmActive.reactiveValue(context);
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
          iAmActive.value
              ? 'wifi aktiivisena tässä laitteessa'
              : 'wifi ei aktiivisena tässä laitteessa',
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
    _wifiActivitySubscription.cancel();
  }

}