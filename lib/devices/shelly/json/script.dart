
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
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['enable'] = enable;
    return data;
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
    final data = <String, dynamic>{};
    data['id'] = id;
    data['running'] = running;
    data['errors'] = errors;
    return data;
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
    final data = <String, dynamic>{};
    data['id'] = id;
    return data;
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
    final data = <String, dynamic>{};
    data['len'] = len;
    return data;
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
    final data = <String, dynamic>{};
    data['was_running'] = wasRunning;
    return data;
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
    final data = <String, dynamic>{};
    data['scripts'] = scripts.map((e)=>e.toJson()).toList();
    return data;
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
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['enable'] = enable;
    data['running'] = running;
    return data;
  }

  @override
  String toString() {
    return '$id: "$name" ${enable ? 'enabled' : 'not enabled'} & ${running ? 'running' : 'not running'}';
  }
}