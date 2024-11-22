import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/device/device.dart';
import 'package:koti/devices/vehicle/vehicle.dart';
import 'package:koti/devices/wifi/wifi.dart';
import 'package:koti/estate/estate.dart';
import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';
import 'package:koti/logic/diagnostics.dart';
import 'package:koti/look_and_feel.dart'; // Change this to the correct import path

import 'package:shared_preferences/shared_preferences.dart';
import 'package:koti/devices/my_device_info.dart';



void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  group('Diagnostics empty tests', () {
    test('Empty data structures', () {
      Estates _myEstates = Estates();
      List <Device> _allDevices = [];
      FunctionalityList _allFunctionalities = FunctionalityList();
      Diagnostics diagnostics = Diagnostics(_myEstates, _allDevices, _allFunctionalities);

      expect(diagnostics.diagnosticsOk(), true);
    });
  });

  group('Diagnostics basic tests', () {
    test('Simple data', () {
      Estates _myEstates = Estates();
      List <Device> _allDevices = [];
      FunctionalityList _allFunctionalities = FunctionalityList();
      _initTest(_myEstates, _allDevices, _allFunctionalities);
      Diagnostics diagnostics = Diagnostics(_myEstates, _allDevices, _allFunctionalities);

      bool status = diagnostics.diagnosticsOk();
      expect(diagnostics.diagnosticsLog.lastDiagnosticLogTitle(),'');

    });

    test('Simple data2', () {
      Estates _myEstates = Estates();
      List <Device> _allDevices = [];
      FunctionalityList _allFunctionalities = FunctionalityList();
      _initTest(_myEstates, _allDevices, _allFunctionalities);
      Diagnostics diagnostics = Diagnostics(_myEstates, _allDevices, _allFunctionalities);

      expect(diagnostics.diagnosticsLog.lastDiagnosticLogTitle(),'');
      // expect(diagnostics.diagnosticsOk(), true);

    });

  });
}

void _initTest(Estates estates, List <Device> allDevices, FunctionalityList allFunctionalities) {
  Estate e = Estate();
  e.name = 'myHouse';
  estates.addEstate(e);
  Wifi w = Wifi();
  w.name = 'myWifi';
  e.myWifiDevice = w;
  e.addDevice(w);
  allDevices.add(w);
  PlainSwitchFunctionality p = PlainSwitchFunctionality();
  allFunctionalities.addFunctionality(p);
}
