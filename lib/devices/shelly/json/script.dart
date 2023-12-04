
class ShellyScriptConfig {
  ShellyScriptConfig({
    required this.id,
    required this.name,
    required this.enable,
  });
  late final int id;
  late final String name;
  late final bool enable;

  ShellyScriptConfig.empty() {
    id = -1;
    name = '';
    enable = false;
  }

  bool isEmpty() => id == -1;

  ShellyScriptConfig.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    enable = json['enable'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['enable'] = enable;
    return _data;
  }
}

class ShellyScriptStatus {
  ShellyScriptStatus({
    required this.id,
    required this.running,
  });
  late final int id;
  late final bool running;
  List<String> errors = [];

  ShellyScriptStatus.fromJson(Map<String, dynamic> json){
    id = json['id'];
    running = json['running'];
    if (json['errors'] == null) {
      errors = [];
    }
    else {
      errors = List.castFrom<dynamic, String>(json['errors']);
    }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['running'] = running;
    _data['errors'] = errors;
    return _data;
  }

  String _errorList() {
    return errors.toString();
  }

  @override
  String toString() {
    return ('$id: ${running?'running':'not running ${_errorList()}'}');
  }
}

class ShellyScriptId {
  ShellyScriptId({
    required this.id,
  });
  late final int id;

  ShellyScriptId.fromJson(Map<String, dynamic> json){
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    return _data;
  }
}

class ShellyScriptLength {
  ShellyScriptLength({
    required this.len,
  });
  late final int len;

  ShellyScriptLength.fromJson(Map<String, dynamic> json){
    len = json['len'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['len'] = len;
    return _data;
  }
}

class ShellyScriptRunning {
  ShellyScriptRunning({
    required this.wasRunning,
  });
  late final bool wasRunning;

  ShellyScriptRunning.fromJson(Map<String, dynamic> json){
    wasRunning = json['was_running'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['was_running'] = wasRunning;
    return _data;
  }
}

class ShellyScriptList {
  ShellyScriptList({
    required this.scripts,
  });
  late List<Scripts> scripts; //was final???

  ShellyScriptList.empty() {
    scripts = [];
  }

  ShellyScriptList.fromJson(Map<String, dynamic> json){
    scripts = List.from(json['scripts']).map((e)=>Scripts.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['scripts'] = scripts.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Scripts {
  Scripts({
    required this.id,
    required this.name,
    required this.enable,
    required this.running,
  });
  late final int id;
  late final String name;
  late final bool enable;
  late final bool running;

  Scripts.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    enable = json['enable'];
    running = json['running'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['enable'] = enable;
    _data['running'] = running;
    return _data;
  }

  String toString() {
    return '$id: "$name" ${enable ? 'enabled' : 'not enabled'} & ${running ? 'running' : 'not running'}';
  }
}