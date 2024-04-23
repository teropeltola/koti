class ShellySwitchConfig {
  ShellySwitchConfig({
    required this.id,
    required this.name,
    required this.inMode,
    required this.initialState,
    required this.autoOn,
    required this.autoOnDelay,
    required this.autoOff,
    required this.autoOffDelay,
    required this.autorecoverVoltageErrors,
    required this.powerLimit,
    required this.voltageLimit,
    required this.undervoltageLimit,
    required this.currentLimit,
  });
  late  int id;
  late  String name;
  late  String inMode;
  late  String initialState;
  late  bool autoOn;
  late  double autoOnDelay;
  late  bool autoOff;
  late  double autoOffDelay;
  late  bool autorecoverVoltageErrors;
  late  int powerLimit;
  late  int voltageLimit;
  late  int undervoltageLimit;
  late  int currentLimit;

  ShellySwitchConfig.empty(){
    id = -1;
    name = '';
    inMode = '';
    initialState = '';
    autoOn = false;
    autoOnDelay = 0;
    autoOff = false;
    autoOffDelay = 0;
    autorecoverVoltageErrors = false;
    powerLimit = 0;
    voltageLimit = 0;
    undervoltageLimit = 0;
    currentLimit = 0;
  }

  ShellySwitchConfig.fromJson(Map<String, dynamic> json){
    id = json['id'] ?? -1;
    name = json['name'] ?? '';
    inMode = json['in_mode'] ?? '';
    initialState = json['initial_state'] ?? '';
    autoOn = json['auto_on'] ?? false;
    autoOnDelay = json['auto_on_delay'] ?? 0;
    autoOff = json['auto_off'] ?? false;
    autoOffDelay = json['auto_off_delay'] ?? 0;
    autorecoverVoltageErrors = json['autorecover_voltage_errors'] ?? false;
    powerLimit = json['power_limit'] ?? 0;
    voltageLimit = json['voltage_limit'] ?? 0;
    undervoltageLimit = json['undervoltage_limit'] ?? 0;
    currentLimit = json['current_limit'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['in_mode'] = inMode;
    _data['initial_state'] = initialState;
    _data['auto_on'] = autoOn;
    _data['auto_on_delay'] = autoOnDelay;
    _data['auto_off'] = autoOff;
    _data['auto_off_delay'] = autoOffDelay;
    _data['autorecover_voltage_errors'] = autorecoverVoltageErrors;
    _data['power_limit'] = powerLimit;
    _data['voltage_limit'] = voltageLimit;
    _data['undervoltage_limit'] = undervoltageLimit;
    _data['current_limit'] = currentLimit;
    return _data;
  }

  String toString() {
    if (id == -1) {
      return '-';
    }
    else {
      return 'switch id:$id, name: $name, inMode:$inMode\n'
          'initialState: $initialState \n'
          '${autoOn ? 'autoOn at ${autoOnDelay}': 'no autoOn'}\n'
          '${autoOff ? 'autoOff at ${autoOffDelay}': 'no autoOff'}\n'
      '${autorecoverVoltageErrors ? 'autorecoveryVoltageErrors' : 'no autorecoveryVoltageErrors'}'
      'powerLimit: $powerLimit \n'
      'voltageLimit: $voltageLimit \n'
      'undervoltageLimit: $undervoltageLimit \n'
      'currentLimit: $currentLimit \n';
    }
  }
}

String _dateTime(int timeStamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp*1000);
  return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
}