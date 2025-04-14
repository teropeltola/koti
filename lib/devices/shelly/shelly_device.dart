import 'package:flutter/material.dart';
import 'dart:convert';
import'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:http/http.dart' as http;
import 'package:koti/devices/shelly/json/plugs_ui_get_config.dart';
import 'package:koti/devices/shelly/json/shelly_get_device_info.dart';
import 'package:koti/devices/shelly/json/shelly_input_config.dart';
import 'package:koti/devices/shelly/json/switch_get_status.dart';

import 'package:koti/devices/shelly/json/sys_get_config.dart';
import 'package:koti/devices/shelly/shelly_scan.dart';
import 'package:koti/devices/shelly/shelly_script.dart';
import 'package:koti/devices/shelly/view/edit_shelly_device_view.dart';

import '../../estate/estate.dart';
import '../device/device.dart';


import '../../look_and_feel.dart';
import '../device/device_state.dart';
import 'json/shelly_switch_config.dart';

const String _http = 'http://';
const String _rpc = '/rpc/';

const int _retryIntervalInMinutes = 2;

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

  ShellyGetDeviceInfo deviceInfo =ShellyGetDeviceInfo.empty();
  SysGetConfig sysConfig = SysGetConfig.empty();

  @override
  String shortTypeName() {
    return '?Shelly?';
  }

  @override
  Future<void> init() async {
    ResolvedBonsoirService bSData = shellyScan.resolveServiceData(id);

    if (bSData.name != "#not found#") {
      initFromScan(bSData);
      state.setConnected();
    }
    else {
      state.setState(StateModel.notConnected);
      _setupRetryTimer();
    }
  }

  void _setupRetryTimer() {
    const Duration delay =  Duration(
      minutes: _retryIntervalInMinutes,
    );

    // Schedule the daily task at given time
    Timer timer = Timer(delay, () async {
      await init();
    });
  }


  void initScript(ShellyDevice myDevice) {
    script = ShellyScript(myDevice);
  }
  void initFromScan(ResolvedBonsoirService bSData) {
    ipAddress = bSData.host ?? '';
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
    if (! state.connected()) {
      // todo: what is the right answer here to tell that connection is not available?
      return '';
    }
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
        if (response.statusCode != 500) {
          // status code 500 is a normal response with non existence service
          log.error(
              '$name/$commandName/rpcCall error: $errorClarification, ${x
                  .toString()}');
          log.info(uri.toString());
        }
        else {
          log.info(
              'VÄLIAIKAINEN JOTTA TIETÄÄ, PALJON NÄITÄ TULEE... $name/$commandName/rpcCall error: $errorClarification, ${x
                  .toString()}');
          log.info(uri.toString());
        }
        return '';
      }
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly rpc (commandName: "$commandName", ipAddress: "$ipAddress", clarification: "$errorClarification")');
      errorClarification ='exception $e';
      return '';
    }
  }

  Future <void> getDeviceInfo() async {

    try {
      String response =  await rpcCall('Shelly.GetDeviceInfo');
      deviceInfo = ShellyGetDeviceInfo.fromJson(json.decode(response));
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly sysGetConfig');
      errorClarification = 'fromJson exception: $e';
    }
  }

  Future <void> sysGetConfig() async {

    try {
      String response =  await rpcCall('Sys.GetConfig');
      sysConfig = SysGetConfig.fromJson(json.decode(response));
      configMac = sysConfig.device.mac;
      location = sysConfig.location;
      firmwareId = sysConfig.device.fwId;
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly sysGetConfig');
      errorClarification = 'fromJson exception: $e';
    }
  }

  Future <void> plugsUiGetConfig() async {

    try {
      String response =  await rpcCall('PLUGS_UI.GetConfig');
      PlugsUiGetConfig config = PlugsUiGetConfig.fromJson(json.decode(response));
      int i = 0;
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly plugUiGetConfig');
      errorClarification = 'fromJson exception: $e';
    }
  }


  Future <ShellySwitchConfig> switchGetConfig(int index) async {
    ShellySwitchConfig config = ShellySwitchConfig.empty();

    try {
      String response =  await rpcCall('Switch.GetConfig?id=$index');
      config = ShellySwitchConfig.fromJson(json.decode(response));
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Switch.GetConfig');
      errorClarification = 'fromJson exception: $e';
    }
    return config;
  }

  Future <ShellySwitchStatus> switchGetStatus(int index) async {
    ShellySwitchStatus config = ShellySwitchStatus.empty();

    try {
      String response =  await rpcCall('Switch.GetStatus?id=$index');
      config = ShellySwitchStatus.fromJson(json.decode(response));
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Switch.GetStatus');
      errorClarification = 'fromJson exception: $e';
    }
    return config;
  }

  Future <bool> powerOutputOn(int index) async {

    try {
      String response =  await rpcCall('Switch.GetStatus?id=$index');
      if (response == ''){
        return false;
      }
      ShellySwitchStatus config = ShellySwitchStatus.fromJson(json.decode(response));
      return config.output;
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Switch.GetStatus');
      errorClarification = 'fromJson exception: $e';
    }
    return false;
  }

  String _switchCommandString(int index, bool turnSwitchOn) {
    return 'Switch.Set?id=$index&on=${turnSwitchOn?'true':'false'}';
  }
  Future <void> setSwitchOn(int index, bool turnSwitchOn) async {

    try {
      String response =  await rpcCall(_switchCommandString(index, turnSwitchOn));
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Switch.setSwitch');
      errorClarification = 'fromJson exception: $e';
    }
  }

  String createSwitchCommand(int index, bool powerOn) { 

    return _cmd(_switchCommandString(0, powerOn));
  }


  Future <ShellyInputConfig> inputGetConfig(int index) async {
    ShellyInputConfig config = ShellyInputConfig.empty();

    try {
      String response =  await rpcCall('Input.GetConfig?id=$index');
      config = ShellyInputConfig.fromJson(json.decode(response));
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Input.GetConfig');
      errorClarification = 'fromJson exception: $e';
    }
    return config;
  }

  @override
  Future<bool> editWidget(BuildContext context, Estate estate) async {
    return await Navigator.push(context, MaterialPageRoute(
        builder: (context) {
      return EditShellyDeviceView(
          estate: estate,
          shellyDevice: this,
          callback: (){}
      );
    }));

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
    newDevice.state = state.clone();
    for (var e in connectedFunctionalities) {newDevice.connectedFunctionalities.add(e);}
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