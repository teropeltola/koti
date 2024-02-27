
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:koti/logic/observation.dart';

import '../../look_and_feel.dart';
import '../device/device.dart';
import '../wlan/active_wifi_name.dart';

class Wifi extends Device {
  late StreamSubscription<String> _wifiActivitySubscription;
  late ActiveWifiBroadcaster _myWifiBroadcaster;

  bool iAmActive = false;

  Wifi();

  bool isMyWifi(String currentWifiName) {
    return (currentWifiName != '') && (name == currentWifiName);
  }

  void initWifi(String myWifiName) {
    name = myWifiName;
    id = 'wifi-$myWifiName';
    _myWifiBroadcaster = activeWifiBroadcaster;
    _wifiActivitySubscription = activeWifiBroadcaster.setListener(listenWifiName);
    iAmActive = isMyWifi(activeWifiBroadcaster.wifiName());
  }

  void changeWifiName(String newWifiName) {
    name = newWifiName;
    bool oldStatus = iAmActive;

    iAmActive = isMyWifi(_myWifiBroadcaster.wifiName());

    if (oldStatus != iAmActive) {
      observationMonitor.add(ObservationLogItem(DateTime.now(),ObservationLevel.informatic));
      //broadcast
    }
  }

  void listenWifiName(String currentWifiName) {
    bool oldStatus = iAmActive;

    iAmActive = isMyWifi(currentWifiName);

    if (oldStatus != iAmActive) {

      if (iAmActive) {
        observationMonitor.add((ObservationLogItem(DateTime.now(), ObservationLevel.ok)));
      }
      else {
        observationMonitor.add((ObservationLogItem(DateTime.now(), ObservationLevel.warning)));
      }
      //broadcast
    }
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