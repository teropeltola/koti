class BluTrvStatus {
  late final int id;
  late final int rssi;
  late final int battery;
  late final int packetId;
  late final int lastUpdatedTs;
  late final bool paired;
  late final bool rpc;
  late final int rsv;

  BluTrvStatus({
    required this.id,
    required this.rssi,
    required this.battery,
    required this.packetId,
    required this.lastUpdatedTs,
    required this.paired,
    required this.rpc,
    required this.rsv,
  });

  BluTrvStatus.empty() {
    id = -75;
    rssi = 0;
    battery = 0;
    packetId = 0;
    lastUpdatedTs = 0;
    paired = false;
    rpc = false;
    rsv = 0;
  }

  bool isEmpty() { return id == -75; }

  BluTrvStatus.fromJson(Map<String, dynamic> json){
    id = json['id'];
    rssi = json['rssi'];
    battery = json['battery'];
    packetId = json['packet_id'];
    lastUpdatedTs = json['last_updated_ts'];
    paired = json['paired'];
    rpc = json['rpc'];
    rsv = json['rsv'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['rssi'] = rssi;
    data['battery'] = battery;
    data['packet_id'] = packetId;
    data['last_updated_ts'] = lastUpdatedTs;
    data['paired'] = paired;
    data['rpc'] = rpc;
    data['rsv'] = rsv;
    return data;
  }
}

class BluTrvConfig {
  late final int id;
  late final String addr;
  late final String name;
  late final String key;
  late final String trv;
  late final List<String> tempSensors;
  late final List<dynamic> dwSensors;
  late final String meta;

  BluTrvConfig({
    required this.id,
    required this.addr,
    required this.name,
    required this.key,
    required this.trv,
    required this.tempSensors,
    required this.dwSensors,
    required this.meta,
  });

  BluTrvConfig.fromJson(Map<String, dynamic> json){
    id = json['id'];
    addr = json['addr'];
    name = json['name'] ?? '';
    key = json['key'] ?? '';
    trv = json['trv'];
    tempSensors = List.castFrom<dynamic, String>(json['temp_sensors']);
    dwSensors = List.castFrom<dynamic, dynamic>(json['dw_sensors']);
    meta = json['meta'] ?? '';
  }

  BluTrvConfig.empty(){
    id = -75;
    addr = '';
    name = '';
    key = '';
    trv = '';
    tempSensors = [];
    dwSensors = [];
    meta = '';
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['addr'] = addr;
    data['name'] = name;
    data['key'] = key;
    data['trv'] = trv;
    data['temp_sensors'] = tempSensors;
    data['dw_sensors'] = dwSensors;
    data['meta'] = meta;
    return data;
  }
}

class BluTrvRemoteDeviceInfo {
  BluTrvRemoteDeviceInfo({
    required this.v,
    required this.ts,
    required this.deviceInfo,
  });
  late final int v;
  late final int ts;
  late final DeviceInfo deviceInfo;

  BluTrvRemoteDeviceInfo.empty(){
    v = -1;
    ts = -1;
    deviceInfo = DeviceInfo.empty();
  }

  BluTrvRemoteDeviceInfo.fromJson(Map<String, dynamic> json){
    v = json['v'];
    ts = json['ts'];
    deviceInfo = DeviceInfo.fromJson(json['device_info']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['v'] = v;
    data['ts'] = ts;
    data['device_info'] = deviceInfo.toJson();
    return data;
  }
}

class DeviceInfo {
  DeviceInfo({
    required this.id,
    required this.mac,
    required this.fwId,
    required this.blVer,
    required this.app,
    required this.model,
    required this.batch,
    required this.ver,
  });
  late final String id;
  late final String mac;
  late final String fwId;
  late final int blVer;
  late final String app;
  late final String model;
  late final String batch;
  late final String ver;

  DeviceInfo.empty(){
    id = '';
    mac = '';
    fwId = '';
    blVer = 0;
    app = '';
    model = '';
    batch = '';
    ver = '';
  }

  DeviceInfo.fromJson(Map<String, dynamic> json){
    id = json['id'];
    mac = json['mac'];
    fwId = json['fw_id'];
    blVer = json['bl_ver'];
    app = json['app'];
    model = json['model'];
    batch = json['batch'];
    ver = json['ver'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['mac'] = mac;
    data['fw_id'] = fwId;
    data['bl_ver'] = blVer;
    data['app'] = app;
    data['model'] = model;
    data['batch'] = batch;
    data['ver'] = ver;
    return data;
  }
}

class BluTrvRemoteStatus {
  BluTrvRemoteStatus({
    required this.v,
    required this.ts,
    required this.status,
  });
  late final int v;
  late final int ts;
  late final BluTrvStatusInfo status;

  BluTrvRemoteStatus.empty(){
    v = -1;
    ts = -1;
    status = BluTrvStatusInfo.empty();
  }

  BluTrvRemoteStatus.fromJson(Map<String, dynamic> json){
    v = json['v'];
    ts = json['ts'];
    status = BluTrvStatusInfo.fromJson(json['status']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['v'] = v;
    data['ts'] = ts;
    data['status'] = status.toJson();
    return data;
  }
}

class BluTrvStatusInfo {
  BluTrvStatusInfo({
    required this.sys,
    required this.temperature0,
    required this.trv0,
  });
  late final Sys sys;
  late final Temperature_0 temperature0;
  late final Trv_0 trv0;

  BluTrvStatusInfo.empty(){
    sys = Sys.empty();
    temperature0 = Temperature_0.empty();
    trv0 = Trv_0.empty();
  }

  BluTrvStatusInfo.fromJson(Map<String, dynamic> json){
    sys = Sys.fromJson(json['sys']);
    temperature0 = Temperature_0.fromJson(json['temperature:0']);
    trv0 = Trv_0.fromJson(json['trv:0']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sys'] = sys.toJson();
    data['temperature0'] = temperature0.toJson();
    data['trv0'] = trv0.toJson();
    return data;
  }
}

class Sys {
  Sys({
    required this.time,
    required this.unixtime,
    required this.offset,
    required this.uptime,
    required this.ramSize,
    required this.ramFree,
    required this.cfgRev,
    required this.stateRev,
  });
  late final String time;
  late final int unixtime;
  late final int offset;
  late final int uptime;
  late final int ramSize;
  late final int ramFree;
  late final int cfgRev;
  late final int stateRev;

  Sys.empty(){
    time = '';
    unixtime = 0;
    offset = 0;
    uptime = 0;
    ramSize = 0;
    ramFree = 0;
    cfgRev = 0;
    stateRev = 0;
  }

  Sys.fromJson(Map<String, dynamic> json){
    time = json['time'];
    unixtime = json['unixtime'];
    offset = json['offset'];
    uptime = json['uptime'];
    ramSize = json['ram_size'];
    ramFree = json['ram_free'];
    cfgRev = json['cfg_rev'];
    stateRev = json['state_rev'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['time'] = time;
    data['unixtime'] = unixtime;
    data['offset'] = offset;
    data['uptime'] = uptime;
    data['ram_size'] = ramSize;
    data['ram_free'] = ramFree;
    data['cfg_rev'] = cfgRev;
    data['state_rev'] = stateRev;
    return data;
  }
}

class Temperature_0 {
Temperature_0({
required this.id,
required this.tC,
required this.tF,
required this.errors,
});
late final int id;
late final double tC;
late final double tF;
late final List<dynamic> errors;

Temperature_0.empty(){
id = 0;
tC = 0.0;
tF = 0.0;
errors = [];
}

Temperature_0.fromJson(Map<String, dynamic> json){
  id = json['id'];
  tC = json['tC'];
  tF = json['tF'];
  errors = List.castFrom<dynamic, dynamic>(json['errors']);
}

Map<String, dynamic> toJson() {
final data = <String, dynamic>{};
data['id'] = id;
data['tC'] = tC;
data['tF'] = tF;
data['errors'] = errors;
return data;
}
}

class Trv_0 {
Trv_0({
required this.id,
required this.pos,
required this.steps,
required this.currentC,
required this.targetC,
required this.override,
required this.scheduleRev,
required this.errors,
});
late final int id;
late final int pos;
late final int steps;
late final double currentC;
late final double targetC;
late final Override override;
late final int scheduleRev;
late final List<String> errors;

Trv_0.empty(){
  id = 0;
  pos = 0;
  steps = 0;
  currentC = 0.0;
  targetC = 0.0;
  override = Override.empty();
  scheduleRev = 0;
  errors = [];
}

Trv_0.fromJson(Map<String, dynamic> json){
id = json['id'];
pos = json['pos'];
steps = json['steps'];
currentC = json['current_C'];
targetC = json['target_C'];
override = Override.fromJson(json['override'] ?? {});
scheduleRev = json['schedule_rev'];
errors = List.castFrom<dynamic, String>(json['errors']);
}

Map<String, dynamic> toJson() {
final data = <String, dynamic>{};
data['id'] = id;
data['pos'] = pos;
data['steps'] = steps;
data['current_C'] = currentC;
data['target_C'] = targetC;
data['override'] = override.toJson();
data['schedule_rev'] = scheduleRev;
data['errors'] = errors;
return data;
}
}

class Override {
  Override({
    required this.startedAt,
  });
  late final int startedAt;

  Override.empty(){
    startedAt = -2;
  }

  Override.fromJson(Map<String, dynamic> json){
    startedAt = json['started_at'] ?? -1;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['started_at'] = startedAt;
    return data;
  }
}

