class SysGetConfig {
  SysGetConfig({
    required this.device,
    required this.location,
    required this.debug,
    required this.uiData,
    required this.rpcUdp,
    required this.sntp,
    required this.cfgRev,
  });
  late final dDevice device;
  late final ShellyLocation location;
  late final Debug debug;
  late final UiData uiData;
  late final RpcUdp rpcUdp;
  late final Sntp sntp;
  late final int cfgRev;

  SysGetConfig.fromJson(Map<String, dynamic> json){
    device = dDevice.fromJson(json['device']);
    location = ShellyLocation.fromJson(json['location']);
    debug = Debug.fromJson(json['debug']);
    uiData = UiData.fromJson(json['ui_data']);
    rpcUdp = RpcUdp.fromJson(json['rpc_udp']);
    sntp = Sntp.fromJson(json['sntp']);
    cfgRev = json['cfg_rev'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['device'] = device.toJson();
    data['location'] = location.toJson();
    data['debug'] = debug.toJson();
    data['ui_data'] = uiData.toJson();
    data['rpc_udp'] = rpcUdp.toJson();
    data['sntp'] = sntp.toJson();
    data['cfg_rev'] = cfgRev;
    return data;
  }
}

class dDevice {
  dDevice({
    required this.name,
    required this.mac,
    required this.fwId,
    required this.ecoMode,
    required this.profile,
    required this.discoverable,
  });
  late final String name;
  late final String mac;
  late final String fwId;
  late final bool ecoMode;
  late final String profile;
  late final bool discoverable;

  dDevice.fromJson(Map<String, dynamic> json){
    name = json['name'] ?? '';
    mac = json['mac'] ?? '';
    fwId = json['fw_id'] ?? '';
    ecoMode = json['eco_mode'];
    profile = json['profile'] ?? '';
    discoverable = json['discoverable'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['mac'] = mac;
    data['fw_id'] = fwId;
    data['eco_mode'] = ecoMode;
    data['profile'] = profile;
    data['discoverable'] = discoverable;
    return data;
  }
}

class ShellyLocation {
  ShellyLocation({
    required this.tz,
    required this.lat,
    required this.lon,
  });
  late final String tz;
  late final double lat;
  late final double lon;

  ShellyLocation.fromJson(Map<String, dynamic> json){
    tz = json['tz'];
    lat = json['lat'];
    lon = json['lon'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['tz'] = tz;
    data['lat'] = lat;
    data['lon'] = lon;
    return data;
  }
}

class Debug {
  Debug({
    required this.mqtt,
    required this.websocket,
    required this.udp,
  });
  late final Mqtt mqtt;
  late final Websocket websocket;
  late final Udp udp;

  Debug.fromJson(Map<String, dynamic> json){
    mqtt = Mqtt.fromJson(json['mqtt']);
    websocket = Websocket.fromJson(json['websocket']);
    udp = Udp.fromJson(json['udp']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['mqtt'] = mqtt.toJson();
    data['websocket'] = websocket.toJson();
    data['udp'] = udp.toJson();
    return data;
  }
}

class Mqtt {
  Mqtt({
    required this.enable,
  });
  late final bool enable;

  Mqtt.fromJson(Map<String, dynamic> json){
    enable = json['enable'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['enable'] = enable;
    return data;
  }
}

class Websocket {
  Websocket({
    required this.enable,
  });
  late final bool enable;

  Websocket.fromJson(Map<String, dynamic> json){
    enable = json['enable'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['enable'] = enable;
    return data;
  }
}

class Udp {
  Udp({
    required this.addr,
  });
  late final String addr;

  Udp.fromJson(Map<String, dynamic> json){
    addr = json['addr'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['addr'] = addr;
    return data;
  }
}

class UiData {
  UiData();

  UiData.fromJson(Map json);

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    return data;
  }
}

class RpcUdp {
  RpcUdp({
    this.dstAddr,
    this.listenPort,
  });
  late final void dstAddr;
  late final void listenPort;

  RpcUdp.fromJson(Map<String, dynamic> json){
    dstAddr = null;
    listenPort = null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['dst_addr'] = dstAddr;
    data['listen_port'] = listenPort;
    return data;
  }
}

class Sntp {
  Sntp({
    required this.server,
  });
  late final String server;

  Sntp.fromJson(Map<String, dynamic> json){
    server = json['server'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['server'] = server;
    return data;
  }
}