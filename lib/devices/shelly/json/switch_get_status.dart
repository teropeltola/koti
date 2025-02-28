import 'dart:math';

class ShellySwitchStatus {
  ShellySwitchStatus({
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

  late int id;
  late String source;
  late bool output; // true if the output channel is currently on, false otherwise
  late double apowerInWatts; // Last measured instantaneous active power (in Watts) delivered to the attached load (shown if applicable)
  late double voltage;
  late double currentInAmperes;
  late int freq;
  late Aenergy aenergy;
  late Temperature temperature;

  ShellySwitchStatus.empty() {
    id = -1;
    source = '';
    output = false;
    apowerInWatts = 0.0;
    voltage = 0.0;
    currentInAmperes = 0.0;
    freq = 0;
    aenergy = Aenergy(totalInWattHours: 0.0, byMinuteInMilliwattHours: [], minuteTs: 0);
    temperature = Temperature(tC: 0.0, tF:0);
  }
  ShellySwitchStatus.fromJson(Map<String, dynamic> json)
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

  @override
  String toString() {
    return 'source: $source\n'
        'power(W): $apowerInWatts\n'
        'voltage: $voltage\n'
        'amperes: $currentInAmperes\n'
        'freq: $freq\n'
        '${aenergy.toString()}';
  }
}

class Aenergy {
  Aenergy({
    required this.totalInWattHours,
    required this.byMinuteInMilliwattHours,
    required this.minuteTs,
  });

  late  double totalInWattHours;
  late  List<double> byMinuteInMilliwattHours;
  late  int minuteTs; // Unix timestamp of the first second of the last minute (in UTC)

  Aenergy.fromJson(Map<String, dynamic> json)
      : totalInWattHours = json['total'] != null ? json['total'].toDouble() : 0.0,
        byMinuteInMilliwattHours = List.castFrom<dynamic, double>(json['by_minute'] ?? []),
        minuteTs = json['minute_ts'] ?? 0;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['total'] = totalInWattHours;
    data['by_minute'] = byMinuteInMilliwattHours;
    data['minute_ts'] = minuteTs;
    return data;
  }

  @override
  String toString() {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(minuteTs*1000);
    String s = 'Aenergy ${dateTime.day}.${dateTime.month}. ${dateTime.hour}:${dateTime.minute} total(W):$totalInWattHours\n  -last minutes(mW):';
    int amount = min(byMinuteInMilliwattHours.length,20);
    for (int i=0; i<amount; i++) {
      s += '${byMinuteInMilliwattHours[i]},';
    }
    return s;
  }
}

class Temperature {
  Temperature({
    required this.tC,
    required this.tF,
  });

  late double tC;
  late double tF;

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