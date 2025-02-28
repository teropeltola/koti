class ShellyInputConfig {
  ShellyInputConfig({
    required this.id,
    required this.name,
    required this.type,
    required this.enable,
    required this.invert,
  });
  late  int id;
  late  String name;
  late  String type;
  late  bool enable;
  late  bool invert;

  ShellyInputConfig.empty(){
    id = -1;
    name = '';
    type = '';
    enable = false;
    invert = false;
  }

  ShellyInputConfig.fromJson(Map<String, dynamic> json){
    id = json['id'] ?? -1;
    name = json['name'] ?? '';
    type = json['type'] ?? '';
    enable = json['enable'] ?? false;
    invert = json['invert'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['enable'] = enable;
    data['invert'] = invert;
    return data;
  }

  @override
  String toString() {
    if (id == -1) {
      return '-';
    }
    else {
      return 'input id:$id name: $name\n'
             'type: $type ${enable ? 'enabled' : 'not enabled'} /'
             '${invert ? 'inverted' : 'not inverted'}';
    }
  }
}
