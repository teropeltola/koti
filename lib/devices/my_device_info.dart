import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

import 'package:flutter_settings_screens/flutter_settings_screens.dart';


Future<void> initMySettings() async {
  await Settings.init(
    cacheProvider: SharePreferenceCache(),
  );
  // accentColor = ValueNotifier(myPrimaryColor);
}

Future<bool> isSimulator() async {
  bool isSimulator = false;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if(Platform.isIOS) {
    var iosInfo = await deviceInfo.iosInfo;
    isSimulator = !iosInfo.isPhysicalDevice;
  }
  else {
    var androidInfo = await deviceInfo.androidInfo;
    isSimulator = !androidInfo.isPhysicalDevice;
  }
  return isSimulator;
}

String simulatorWifiName() {
  return '"AndroidWifi"';
}