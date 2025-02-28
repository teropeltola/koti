
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bonsoir/bonsoir.dart';

import 'package:koti/devices/shelly/shelly_device.dart';
import 'package:koti/devices/shelly/shelly_scan.dart';



const String _http = 'http://';
const String _rpc = '/rpc/';
String ipAddress = '11.22.33.44';

String _cmd(String commandName) {
  return '$_http$ipAddress$_rpc$commandName';
}

void main() {
  group('Shelly Script Tests', () {
    setUp(() async {
      WidgetsFlutterBinding.ensureInitialized();
    });

    test('Test testEnvironment setup', () async {

      String s1 = 'let greeting=\'Terve\'; let g2="G2";print(greeting);';
      String s2 = "Script.PutCode?id=1&code=\x22$s1\x22&append=false";
      String s3 = _cmd(s2);
      Uri u = Uri.parse(s3);
      String s4 = u.query;

      expect(s2.length, 90);

    });
  });

  test('Test testEnvironment trick 2', () async {

    String s1 = 'let greeting=\'Terve\';\nprint(greeting);';
    String s2 = "Script.PutCode?id=1&code=\\x22$s1\\x22&append=false";
    String s3 = _cmd(s2);
    Uri u = Uri.parse(s3);
    String s4 = u.query;

    expect(s2.length, 84);

  });

}

const _myTestPlugName = 'shellyplusplugs-b0b21c110aa0';

Future <ShellyDevice> _initTestEnvironment() async {
  await shellyScan.init();
  await Future.delayed(const Duration(seconds: 1));

  /*
  List<String> shellyServices = shellyScan.listPossibleServices();
  String serviceName = shellyServices.firstWhere((element) => element.contains(_myTestPlugName));
  */
  String serviceName = _myTestPlugName;
  ResolvedBonsoirService bSData = shellyScan.resolveServiceData(serviceName);


  ShellyDevice newDevice = ShellyDevice();
  newDevice.initFromScan(bSData);
  newDevice.name = 'testDevice';

  return newDevice;
}
