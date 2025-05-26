import 'dart:convert';

import 'package:flutter/material.dart';
import '../../estate/estate.dart';
import '../../logic/services.dart';
import '../../look_and_feel.dart';
import '../shelly/json/blu_trv.dart';
import '../shelly/shelly_device.dart';

class BluConfigAndStatus {
  BluTrvStatus status = BluTrvStatus.empty();
  BluTrvConfig config = BluTrvConfig.empty();
  BluTrvRemoteDeviceInfo info = BluTrvRemoteDeviceInfo.empty();

  BluConfigAndStatus(this.status, this.config, this.info);

  BluConfigAndStatus.empty();

  String deviceId() => info.deviceInfo.id;
}

class ShellyBluGw extends ShellyDevice {

  List <BluConfigAndStatus> bluTrvStatusList = [];

  void _initOfferedServices() {
    services = Services([
    ]);
  }

  ShellyBluGw();

  ShellyBluGw.failed() {
    setFailed();
  }

  Future <BluConfigAndStatus> bluInfo(int id) async {
    BluConfigAndStatus myInfo = BluConfigAndStatus.empty();

    myInfo.status = await bluTrvGetStatus(id);
    if (! myInfo.status.isEmpty()) {
      myInfo.config = await bluTrvGetConfig(myInfo.status.id);
      myInfo.info = await bluTrvGetRemoteDeviceInfo(myInfo.status.id);
    }

    for (int index=0; index<bluTrvStatusList.length; index++) {
      if (bluTrvStatusList[index].deviceId() == id) {
        bluTrvStatusList[index] = myInfo;
      }
    }
    return myInfo;
  }

  Future<void> updateConnectedDevices() async {
    bluTrvStatusList.clear();
    for (int i=200; i<206; i++) {
      BluTrvStatus status = await bluTrvGetStatus(i);
      if (! status.isEmpty()) {
        BluTrvConfig config = await bluTrvGetConfig(status.id);
        BluTrvRemoteDeviceInfo info = await bluTrvGetRemoteDeviceInfo(status.id);
        bluTrvStatusList.add(BluConfigAndStatus(status, config, info));
      }
    }
  }

  @override
  Future<void> init () async {
    Estate myEstate = myEstates.estateFromId(myEstateId);

    await super.init();

    if (state.connected()) {
      await updateConnectedDevices();

      await sysGetConfig();

      _initOfferedServices();
    }
    else {
      setupShellyRetryTimer(init);
    }
  }

  Future<void> getDataFromDevice() async {

  }

  Future <BluTrvStatus> bluTrvGetStatus(int index) async {
    BluTrvStatus status = BluTrvStatus.empty();

    try {
      String response =  await rpcCall('BluTrv.GetStatus?id=$index');
      if (response != '') {
        status = BluTrvStatus.fromJson(json.decode(response));
      }
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly BluTrv.GetStatus');
      errorClarification = 'fromJson exception: $e';
    }
    return status;
  }

  Future <BluTrvConfig> bluTrvGetConfig(int index) async {
    BluTrvConfig config = BluTrvConfig.empty();

    try {
      String response =  await rpcCall('BluTrv.GetConfig?id=$index');
      if (response != '') {
        config = BluTrvConfig.fromJson(json.decode(response));
      }
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly BluTrv.GetConfig');
      errorClarification = 'fromJson exception: $e';
    }
    return config;
  }

  Future <BluTrvRemoteStatus> bluTrvGetRemoteStatus(int index) async {
    BluTrvRemoteStatus info = BluTrvRemoteStatus.empty();

    try {
      String response =  await rpcCall('BluTrv.GetRemoteStatus?id=$index');
      if (response != '') {
        info = BluTrvRemoteStatus.fromJson(json.decode(response));
      }
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly BluTrvRemoteStatus');
      errorClarification = 'fromJson exception: $e';
    }
    return info;
  }

  Future <BluTrvRemoteDeviceInfo> bluTrvGetRemoteDeviceInfo(int index) async {
    BluTrvRemoteDeviceInfo info = BluTrvRemoteDeviceInfo.empty();

    try {
      String response =  await rpcCall('BluTrv.GetRemoteDeviceInfo?id=$index');
      if (response != '') {
        info = BluTrvRemoteDeviceInfo.fromJson(json.decode(response));
      }
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly BluTrvRemoteDeviceInfo');
      errorClarification = 'fromJson exception: $e';
    }
    return info;
  }

  Future <void> bluTrvCall(int index, String method, String params) async {
    try {
      String response =  await rpcCall('BluTrv.Call?id=$index&method="$method"&params=$params');
      if (response != '') {

      }
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly BluTrv.Call');
      errorClarification = 'fromJson exception: $e';
    }
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: name,
        textLines: [
          'tunnus: $id',
          'tila: ${state.stateText()}',
          'IP-osoite: $ipAddress',
        ],
        widgets: [
          dumpDataMyFunctionalities(formatterWidget: formatterWidget),
        ]
    );
  }

  @override
  IconData icon() {
    return Icons.alt_route_rounded;
  }

  @override
  String shortTypeName() {
    return 'shelly blu gw';
  }


  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  ShellyBluGw.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }

}