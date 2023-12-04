import 'dart:convert';
import'dart:async';
import 'package:bonsoir/bonsoir.dart';
import 'package:http/http.dart' as http;
import 'package:koti/devices/shelly/json/plugs_ui_get_config.dart';
import 'package:koti/devices/shelly/json/switch_get_status.dart';

import 'package:koti/devices/shelly/json/sys_get_config.dart';
import 'package:koti/devices/shelly/shelly_script.dart';

import '../device/device.dart';


import '../../look_and_feel.dart';

const String _http = 'http://';
const String _rpc = '/rpc/';

class ShellyDevice extends Device {

  String ipAddress = '';
  String errorClarification = '';
  int port = -1;
  Map <String, String> attributes = {};
  String shellyType = '';

  String configMac = '';
  String firmwareId = '';
  ShellyLocation location = ShellyLocation(tz:'', lat:0.0, lon: 0.0);
  late ShellyScript script;

  void initScript(ShellyDevice myDevice) {
    script = ShellyScript(myDevice);
  }
  void initFromScan(ResolvedBonsoirService bSData) {
    id = bSData.name;
    ipAddress = bSData.ip ?? '';
    port = bSData.port;
    shellyType = bSData.type;
    attributes = bSData.attributes ?? {};
    initScript(this);
  }

  void setIpAddress(String newAddress) {
    ipAddress = newAddress;
  }

  String _cmd(String commandName) {
    return '$_http$ipAddress$_rpc$commandName';
  }

  Future <String> rpcCall(String commandName) async {
    try {
      var uri = Uri.parse(_cmd(commandName));
      final response = await http.get(uri,
        headers: {
          'Content-type': 'application/json; charset=UTF-8'
        });
      if (response.statusCode == 200) {
        String responseString = response.body.toString();
        return responseString;
      }
      else {
        errorClarification = 'statusCode = ${response.statusCode}';
        var x = utf8.decode(response.bodyBytes);
        log.error('${name}/$commandName/rpcCall error: $errorClarification, ${x.toString()}');
        log.info(uri.toString());
        return '';
      }
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly rpc ($commandName)');
      errorClarification ='exception $e';
      return '';
    }
  }

  Future <void> sysGetConfig() async {
    String response =  await rpcCall('Sys.GetConfig');

    try {
      SysGetConfig config = SysGetConfig.fromJson(json.decode(response));
      configMac = config.device.mac;
      location = config.location;
      firmwareId = config.device.fwId;
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly sysGetConfig');
      errorClarification = 'fromJson exception: $e';
    }
  }

  Future <void> plugsUiGetConfig() async {
    String response =  await rpcCall('PLUGS_UI.GetConfig');

    try {
      PlugsUiGetConfig config = PlugsUiGetConfig.fromJson(json.decode(response));
      int i = 0;
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly plugUiGetConfig');
      errorClarification = 'fromJson exception: $e';
    }
  }

  Future <void> switchGetStatus() async {
    String response =  await rpcCall('Switch.GetStatus?id=0');

    try {
      SwitchGetStatus config = SwitchGetStatus.fromJson(json.decode(response));
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Switch.GetStatus');
      errorClarification = 'fromJson exception: $e';
    }
  }

  Future <bool> powerOutputOn() async {
    String response =  await rpcCall('Switch.GetStatus?id=0');

    try {
      SwitchGetStatus config = SwitchGetStatus.fromJson(json.decode(response));
      return config.output;
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Switch.GetStatus');
      errorClarification = 'fromJson exception: $e';
    }
    return false;
  }

  Future <void> setSwitchOn(bool turnSwitchOn) async {

    try {
      String response =  await rpcCall('Switch.Set?id=0&on=${turnSwitchOn?'true':'false'}');
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Switch.GetStatus');
      errorClarification = 'fromJson exception: $e';
    }
  }

  @override
  String detailsDescription() {
    return 'IP-osoite: $ipAddress, portti: $port\n'
           'attribuutit: ${attributes.toString()}';
  }

  @override
  Device clone() {
    ShellyDevice newDevice = ShellyDevice();
    newDevice.name = name;
    newDevice.id = id;
    newDevice.state = state;
    newDevice.functionality = functionality;
    newDevice.ipAddress = ipAddress;
    newDevice.errorClarification = errorClarification;
    newDevice.port = port;
    newDevice.attributes = attributes;
    newDevice.shellyType = shellyType;
    newDevice.configMac = configMac;
    newDevice.firmwareId = firmwareId;
    newDevice.location = location;

    return newDevice;
  }
}