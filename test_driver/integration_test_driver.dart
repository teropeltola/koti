import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  String myAdb =
  Platform.isAndroid ?
  'C:/Users/terop/AppData/Local/Android/Sdk/platform-tools/adb.exe' :
  'C:/Users/terop/AppData/Local/Android/Sdk/platform-tools/adb.exe';

//  await Process.run(_myAdb , ['shell' ,'pm', 'grant', 'com.mosahybrid.bbong', 'android.permission.CAMERA']);
//  await Process.run(_myAdb , ['shell' ,'pm', 'grant', 'com.mosahybrid.bbong', 'android.permission.RECORD_AUDIO']);
//  await Process.run(_myAdb , ['shell' ,'pm', 'grant', 'com.mosahybrid.bbong', 'android.permission.WRITE_EXTERNAL_STORAGE']);
//  await Process.run(_myAdb , ['shell' ,'pm', 'grant', 'com.mosahybrid.bbong', 'android.permission.READ_EXTERNAL_STORAGE']);
//  await Process.run(_myAdb , ['shell' ,'pm', 'grant', 'com.mosahybrid.bbong', 'android.permission.FOREGROUND_SERVICE']);
  await Process.run(myAdb , ['shell' ,'pm', 'grant', 'com.mosahybrid.koti', 'android.permission.ACCESS_FINE_LOCATION']);
  await Process.run(myAdb , ['shell' ,'pm', 'grant', 'com.mosahybrid.koti', 'android.permission.ACCESS_COARSE_LOCATION']);
  await Process.run(myAdb , ['shell' ,'pm', 'grant', 'com.mosahybrid.koti', 'android.permission.ACCESS_BACKGROUND_LOCATION']);
//  await Process.run(_myAdb , ['shell' ,'pm', 'grant', 'com.mosahybrid.bbong', 'android.permission.INTERNET']);

  // TODO: Add more permissions as required
  await integrationDriver();
}