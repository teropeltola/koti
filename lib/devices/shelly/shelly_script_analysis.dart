
import 'dart:math';

import 'package:bonsoir/bonsoir.dart';
import 'package:koti/devices/shelly/shelly_device.dart';
import 'package:koti/devices/shelly/shelly_scan.dart';
import 'package:koti/devices/shelly/shelly_script_code.dart';

import '../../look_and_feel.dart';
import 'json/script.dart';

const _myTestPlugName = 'shellyplusplugs-b0b21c110aa0';

Future <ShellyDevice> _initTestEnvironment() async {

  List<String> shellyServices = shellyScan.listPossibleServices();
  if (shellyServices.isEmpty) {
    return ShellyDevice();
  }
  String serviceName = shellyServices.firstWhere((element) => element.contains(_myTestPlugName));

  ResolvedBonsoirService bSData = shellyScan.resolveServiceData(serviceName);

  ShellyDevice newDevice = ShellyDevice();
  newDevice.name = 'testDevice';
  newDevice.id = bSData.name;
  newDevice.initFromScan(bSData);

  return newDevice;
}

class ShellyScriptAnalysis {

  Future<void> test1() async {
    log.info('test1 started');
    ShellyDevice s = await _initTestEnvironment();

    if (s.name.isEmpty) {
      log.info('environment is not available');
      return;
    }
    log.info('${s.name} initiated');
    await s.script.clear();

    await s.script.list();

    if (s.script.shellyScriptList.scripts.isNotEmpty) {
      log.error('clear didnt empty the scripts');
    }

    int scriptIndex = await s.script.create('test script');

    await s.script.list();

    if (s.script.shellyScriptList.scripts.length == 1) {
      log.info('created script: ${s.script.shellyScriptList.scripts[0]}');
    }
    else {
      log.error('create didnt succeed');
      return;
    }

    //String code = 'let greeting=\'Terve\';\nprint(greeting);';
    String code = "let greeting='Terve'; print(greeting);";
    ShellyScriptCode ssc = ShellyScriptCode();
    ssc.setCode(code);
    ssc.modify();

    int codeLength = await s.script.putCode(scriptIndex, ssc);

    if (codeLength != code.length) {
      log.error('putCode didnt succeed ($codeLength/${code.length})');
    }

    bool status = await s.script.start(scriptIndex);
    log.info('start: ${status.toString()}');

    await s.script.list();

    if (s.script.shellyScriptList.scripts.length == 1) {
      log.info('script: ${s.script.shellyScriptList.scripts[0]}');
    }
    else {
      log.error('error in putCode');
      return;
    }

    status = await s.script.start(scriptIndex);
    log.info('start: ${status.toString()}');

    ShellyScriptStatus sStatus = await s.script.getStatus(scriptIndex);

    log.info('status: ${sStatus.toString()}');
  }

  Future<void> test2(ShellyScriptCode code) async {
    log.info('test2 started');

    ShellyDevice s = await _initTestEnvironment();

    if (s.name.isEmpty) {
      log.info('environment is not available');
      return;
    }
    log.info('${s.name} initiated');

    await s.script.clear();

    int scriptIndex = await s.script.create('newCode${_scriptNameIndex}');
    _scriptNameIndex++;

    await s.script.list();

    int codeLength = await s.script.putCode(scriptIndex, code);

    if (codeLength != code.modifiedCode.length) {
      log.error(
          'putCode didnt succeed ($codeLength/${code.modifiedCode.length})');
      int start = max(codeLength-20, 0);
      int end = min(codeLength+20, code.modifiedCode.length);
      log.info('code from $start-$end: ${code.modifiedCode.substring(start,end)}');
    }

    bool status = await s.script.start(scriptIndex);
    log.info('start: ${status.toString()}');

    await s.script.list();

    if (s.script.shellyScriptList.scripts.isNotEmpty) {
      log.info('script: ${s.script.shellyScriptList.scripts.last}');
    }
  }
}

int _scriptNameIndex = 1;