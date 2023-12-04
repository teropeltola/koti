

import 'dart:convert';

import 'package:koti/devices/shelly/shelly.dart';
import 'package:koti/devices/shelly/shelly_script_code.dart';

import '../../look_and_feel.dart';
import 'json/script.dart';

const maxConfigs = 5;
class ShellyScript {

  late ShellyDevice device;

  ShellyScriptList shellyScriptList = ShellyScriptList.empty();

  ShellyScript(ShellyDevice myDevice) {
    device = myDevice;
  }

  Future<void> setConfig(int configId, bool enable) async {
    if (configId > maxConfigs) {
      log.error('${device.name}/Script.setConfig: wrong configId: $configId');
    }
    try {
      await device.rpcCall('Script.SetConfig?id=$configId&config={"enable":$enable');
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Switch.GetStatus');
      device.errorClarification = 'fromJson exception: $e';
      return;
    }
  }

  Future<ShellyScriptConfig> getConfig(int configId) async {
    if (configId > maxConfigs) {
      log.error('${device.name}/Script.getConfig: wrong configId: $configId');
    }
    try {
      String response = await device.rpcCall('Script.GetConfig?id=$configId');

      if (response.isEmpty) {
        return ShellyScriptConfig.empty();
      }

      ShellyScriptConfig config = ShellyScriptConfig.fromJson(json.decode(response));
      return config;
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Script.GetConfig');
      device.errorClarification = 'fromJson exception: $e';
      return ShellyScriptConfig.empty();
    }
  }

  Future<ShellyScriptStatus> getStatus(int configId) async {
    if (configId > maxConfigs) {
      log.error('${device.name}/Script.getStatus: wrong configId: $configId');
    }
    try {
      String response = await device.rpcCall('Script.GetStatus?id=$configId');

      if (response.isEmpty) {
        return ShellyScriptStatus(id: -1,running: false);
      }

      ShellyScriptStatus status = ShellyScriptStatus.fromJson(json.decode(response));
      return status;
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Script.GetStatus');
      device.errorClarification = 'fromJson exception: $e';
      return ShellyScriptStatus(id: -1,running: false);
    }
  }

  Future<int> create(String scriptName) async {
    if (scriptName.isEmpty) {
      log.error('${device.name}/Script.create: wrong scriptName: $scriptName');
    }
    try {
      String response = await device.rpcCall('Script.Create?name="$scriptName"');

      if (response.isEmpty) {
        return -1;
      }

      ShellyScriptId id = ShellyScriptId.fromJson(json.decode(response));
      return id.id;
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Script.create');
      device.errorClarification = 'fromJson exception: $e';
      return -1;
    }
  }

  // code: The code which will be included in the script (the length must be greater than 0).
  // append: true to append the code, false otherwise.
  // If set to false, the existing code will be overwritten.
  int _chunkLastIndex(int startIndex, int codeLeft) {
    return (codeLeft > codeChunkSize ? codeChunkSize : codeLeft);
  }

  Future<int> putCode(int id, ShellyScriptCode code) async {
    if (code.modifiedCode.isEmpty) {
      log.error('${device.name}/Script.PutCode: invalid parameters - modified code is empty');
    }
    try {
      List <String> codeChunks = code.codeChunks();
      int totalLength = 0;

      for (int i=0; i<codeChunks.length; i++) {
        String response = await device.rpcCall(
            'Script.PutCode?id=$id&code="${codeChunks[i]}"&append=${i == 0
                ? 'false'
                : 'true'}');

        if (response.isEmpty) {
          return -1;
        }
        ShellyScriptLength len = ShellyScriptLength.fromJson(json.decode(response));
        totalLength = len.len;
      }
      return totalLength;
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Script.PutCode');
      device.errorClarification = 'fromJson exception: $e';
      return -1;
    }
  }

  Future<bool> start(int id) async {
    if (id > maxConfigs) {
      log.error('${device.name}/Script.start: wrong id: $id');
    }
    try {
      String response = await device.rpcCall('Script.Start?id=$id');

      if (response.isEmpty) {
        return false;
      }

      ShellyScriptRunning running = ShellyScriptRunning.fromJson(json.decode(response));
      return running.wasRunning;

    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Script.Start');
      device.errorClarification = 'fromJson exception: $e';
      return false;
    }
  }

  Future<bool> stop(int id) async {
    if (id > maxConfigs) {
      log.error('${device.name}/Script.stop: wrong id: $id');
    }
    try {
      String response = await device.rpcCall('Script.Stop?id=$id');

      if (response.isEmpty) {
        return false;
      }

      ShellyScriptRunning running = ShellyScriptRunning.fromJson(json.decode(response));
      return running.wasRunning;

    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Script.Stop');
      device.errorClarification = 'fromJson exception: $e';
      return false;
    }
  }

  Future<void> list() async {

    try {
      String response = await device.rpcCall('Script.List');

      if (response.isEmpty) {
        shellyScriptList = ShellyScriptList.empty();
        return;
      }

      shellyScriptList = ShellyScriptList.fromJson(json.decode(response));

    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Script.List');
      device.errorClarification = 'fromJson exception: $e';
      shellyScriptList = ShellyScriptList.empty();
      return ;
    }
  }

  Future<void> delete(int id) async {
    if (id > maxConfigs) {
      log.error('${device.name}/Script.Delete: wrong id: $id');
    }
    try {
      await device.rpcCall('Script.Delete?id=$id');
    }
    catch (e, st) {
      log.handle(e, st, 'exception in shelly Script.Delete');
      device.errorClarification = 'fromJson exception: $e';
    }
  }

  Future<void> clear() async {
    await list();
    for (int i=0; i<shellyScriptList.scripts.length; i++) {
      await delete(shellyScriptList.scripts[i].id);
    }
    shellyScriptList.scripts.clear();
  }

}

const codeChunkSize = 1024;