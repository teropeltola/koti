class ShellyGetDeviceInfo {
  ShellyGetDeviceInfo({
    required this.id,
    required this.mac,
    required this.model,
    required this.gen,
    required this.fwId,
    required this.ver,
    required this.app,
    required this.authEn,
    required this.authDomain,
    required this.discoverable,
  });
  late final String id;
  late final String mac;
  late final String model;
  late final int gen;
  late final String fwId;
  late final String ver;
  late final String app;
  late final bool authEn;
  late final String authDomain;
  late final bool discoverable;

  ShellyGetDeviceInfo.empty(){
    id = '';
    mac = '';
    model = '';
    gen = -1;
    fwId = '';
    ver = '';
    app = '';
    authEn = false;
    authDomain = '';
    discoverable = false;
  }

  ShellyGetDeviceInfo.fromJson(Map<String, dynamic> json){
    id = json['id'] ?? '';
    mac = json['mac'] ?? '';
    model = json['model'] ?? '';
    gen = json['gen'] ?? 0;
    fwId = json['fw_id'] ?? '';
    ver = json['ver'] ?? '';
    app = json['app'] ?? '';
    authEn = json['auth_en'] ?? false;
    authDomain = json['auth_domain'] ?? '';
    discoverable = json['discoverable'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['mac'] = mac;
    _data['model'] = model;
    _data['gen'] = gen;
    _data['fw_id'] = fwId;
    _data['ver'] = ver;
    _data['app'] = app;
    _data['auth_en'] = authEn;
    _data['auth_domain'] = authDomain;
    _data['discoverable'] = discoverable;
    return _data;
  }
}