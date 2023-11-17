class SwitchGetStatus {
  SwitchGetStatus({
    required this.id,
    required this.source,
    required this.output,
    required this.apowerInWatts,
    required this.voltage,
    required this.currentInAmperes,
    required this.freq,
    required this.aenergy,
    required this.temperature,
  });

  late final int id;
  late final String source;
  late final bool output; // true if the output channel is currently on, false otherwise
  late final double apowerInWatts; // Last measured instantaneous active power (in Watts) delivered to the attached load (shown if applicable)
  late final double voltage;
  late final double currentInAmperes;
  late final int freq;
  late final Aenergy aenergy;
  late final Temperature temperature;

  SwitchGetStatus.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        source = json['source'] ?? '',
        output = json['output'] ?? false,
        apowerInWatts = json['apower'] ?? 0.0,
        voltage = json['voltage'] ?? 0.0,
        currentInAmperes = json['current'] ?? 0.0,
        freq = json['freq'] ?? 0,
        aenergy = Aenergy.fromJson(json['aenergy'] ?? {}),
        temperature = Temperature.fromJson(json['temperature'] ?? {});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['source'] = source;
    data['output'] = output;
    data['apower'] = apowerInWatts;
    data['voltage'] = voltage;
    data['current'] = currentInAmperes;
    data['freq'] = freq;
    data['aenergy'] = aenergy.toJson();
    data['temperature'] = temperature.toJson();
    return data;
  }
}

class Aenergy {
  Aenergy({
    required this.totalInWattHours,
    required this.byMinuteInMilliwattHours,
    required this.minuteTs,
  });

  late final double totalInWattHours;
  late final List<int> byMinuteInMilliwattHours;
  late final int minuteTs; // Unix timestamp of the first second of the last minute (in UTC)

  Aenergy.fromJson(Map<String, dynamic> json)
      : totalInWattHours = json['total'] != null ? json['total'].toDouble() : 0.0,
        byMinuteInMilliwattHours = List.castFrom<dynamic, int>(json['by_minute'] ?? []),
        minuteTs = json['minute_ts'] ?? 0;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['total'] = totalInWattHours;
    data['by_minute'] = byMinuteInMilliwattHours;
    data['minute_ts'] = minuteTs;
    return data;
  }
}

class Temperature {
  Temperature({
    required this.tC,
    required this.tF,
  });

  late final double tC;
  late final double tF;

  Temperature.fromJson(Map<String, dynamic> json)
      : tC = json['tC'] != null ? json['tC'].toDouble() : 0.0,
        tF = json['tF'] != null ? json['tF'].toDouble() : 0.0;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['tC'] = tC;
    data['tF'] = tF;
    return data;
  }
}

/*
class SwitchGetStatus {
  SwitchGetStatus({
    required this.id,
    required this.source,
    required this.output,
    required this.apowerInWatts,
    required this.voltage,
    required this.currentInAmperes,
    required this.freq,
    required this.aenergy,
    required this.temperature,
  });

  late final int id;
  late final String source;
  late final bool output; // true if the output channel is currently on, false otherwise
  late final double apowerInWatts; // Last measured instantaneous active power (in Watts) delivered to the attached load (shown if applicable)
  late final double voltage;
  late final double currentInAmperes;
  late final int freq;
  late final Aenergy aenergy;
  late final Temperature temperature;

  SwitchGetStatus.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        source = json['source'] ?? '',
        output = json['output'] ?? false,
        apowerInWatts = json['apower'] ?? 0.0,
        voltage = json['voltage'] ?? 0.0,
        currentInAmperes = json['current'] ?? 0.0,
        freq = json['freq'] ?? 0,
        aenergy = Aenergy.fromJson(json['aenergy'] ?? {}),
        temperature = Temperature.fromJson(json['temperature'] ?? {});

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['source'] = source;
    _data['output'] = output;
    _data['apower'] = apowerInWatts;
    _data['voltage'] = voltage;
    _data['current'] = currentInAmperes;
    _data['freq'] = freq;
    _data['aenergy'] = aenergy.toJson();
    _data['temperature'] = temperature.toJson();
    return _data;
  }
}

class Aenergy {
  Aenergy({
    required this.totalInWattHours,
    required this.byMinuteInMilliwattHours,
    required this.minuteTs,
  });

  late final double totalInWattHours;
  late final List<int> byMinuteInMilliwattHours;
  late final int minuteTs; // Unix timestamp of the first second of the last minute (in UTC)

  Aenergy.fromJson(Map<String, dynamic> json)
      : totalInWattHours = json['total'] ?? 0.0,
        byMinuteInMilliwattHours = List.castFrom<dynamic, int>(json['by_minute'] ?? []),
        minuteTs = json['minute_ts'] ?? 0;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total'] = totalInWattHours;
    _data['by_minute'] = byMinuteInMilliwattHours;
    _data['minute_ts'] = minuteTs;
    return _data;
  }
}

class Temperature {
  Temperature({
    required this.tC,
    required this.tF,
  });

  late final double tC;
  late final double tF;

  Temperature.fromJson(Map<String, dynamic> json)
      : tC = json['tC'] ?? 0.0,
        tF = json['tF'] ?? 0.0;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['tC'] = tC;
    _data['tF'] = tF;
    return _data;
  }
}


 */