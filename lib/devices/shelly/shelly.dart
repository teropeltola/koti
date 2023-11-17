import 'dart:convert';
import'dart:async';
import 'package:http/http.dart' as http;
import 'package:koti/devices/shelly/json/plugs_ui_get_config.dart';
import 'package:koti/devices/shelly/json/switch_get_status.dart';

import 'package:koti/devices/shelly/json/sys_get_config.dart';

import '../device/device.dart';


import '../../look_and_feel.dart';

const String _http = 'http://';
const String _rpc = '/rpc/';

class ShellyDevice extends Device {

  @override
  String name = '';
  String ipAddress = '';
  String errorClarification = '';

  String configMac = '';
  String firmwareId = '';
  ShellyLocation location = ShellyLocation(tz:'', lat:0.0, lon: 0.0);

  void setIpAddress(String newAddress) {
    ipAddress = newAddress;
  }

  String _cmd(String commandName) {
    return '$_http$ipAddress$_rpc$commandName';
  }

  Future <String> rpcCall(String commandName) async {
    try {
      final response = await http.get(Uri.parse(_cmd(commandName)));
      if (response.statusCode == 200) {
        String responseString = response.body.toString();
        return responseString;
      }
      errorClarification = 'statusCode = ${response.statusCode}';
      return '';
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly rpc');
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
      int i = 0;
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Switch.GetStatus');
      errorClarification = 'fromJson exception: $e';
    }
  }




}