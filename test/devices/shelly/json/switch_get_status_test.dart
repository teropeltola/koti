import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/shelly/json/switch_get_status.dart';

void main() {
  group('SwitchGetStatus', () {
    test('fromJson should correctly parse JSON', () {
      final Map<String, dynamic> json = {
        'id': 1,
        'source': 'example',
        'output': true,
        'apower': 100.0,
        'voltage': 220.0,
        'current': 5.0,
        'freq': 50,
        'aenergy': {
          'total': 500.0,
          'by_minute': [10.0, 20.0, 30.0],
          'minute_ts': 1633620000,
        },
        'temperature': {
          'tC': 25.0,
          'tF': 77.0,
        },
      };

      final switchStatus = ShellySwitchStatus.fromJson(json);

      expect(switchStatus.id, equals(1));
      expect(switchStatus.source, equals('example'));
      expect(switchStatus.output, equals(true));
      expect(switchStatus.apowerInWatts, equals(100.0));
      expect(switchStatus.voltage, equals(220.0));
      expect(switchStatus.currentInAmperes, equals(5.0));
      expect(switchStatus.freq, equals(50));
      expect(switchStatus.aenergy.totalInWattHours, equals(500.0));
      expect(
          switchStatus.aenergy.byMinuteInMilliwattHours, equals([10.0, 20.0, 30.0]));
      expect(switchStatus.aenergy.minuteTs, equals(1633620000));
      expect(switchStatus.temperature.tC, equals(25.0));
      expect(switchStatus.temperature.tF, equals(77.0));
    });

    test('toJson should correctly convert to JSON', () {
      final switchStatus = ShellySwitchStatus(
        id: 2,
        source: 'test',
        output: false,
        apowerInWatts: 50.0,
        voltage: 240.0,
        currentInAmperes: 3.0,
        freq: 60,
        aenergy: Aenergy(
          totalInWattHours: 300.0,
          byMinuteInMilliwattHours: [5, 15, 25],
          minuteTs: 1633623600,
        ),
        temperature: Temperature(
          tC: 30.0,
          tF: 86.0,
        ),
      );

      final json = switchStatus.toJson();

      expect(json['id'], equals(2));
      expect(json['source'], equals('test'));
      expect(json['output'], equals(false));
      expect(json['apower'], equals(50.0));
      expect(json['voltage'], equals(240.0));
      expect(json['current'], equals(3.0));
      expect(json['freq'], equals(60));
      expect(json['aenergy']['total'], equals(300.0));
      expect(json['aenergy']['by_minute'], equals([5, 15, 25]));
      expect(json['aenergy']['minute_ts'], equals(1633623600));
      expect(json['temperature']['tC'], equals(30.0));
      expect(json['temperature']['tF'], equals(86.0));
    });
  });

  group('SwitchGetStatus2', () {
    test('fromJson should handle missing optional fields', () {
      final Map<String, dynamic> json = {
        'id': 3,
        'source': 'test',
        'output': false,
        'apower': 75.0,
        'voltage': 220.0,
        'current': 4.0,
        // 'freq' is missing
        'aenergy': {
          'total': 200.0,
          'by_minute': [5.0, 10.0],
          'minute_ts': 1633627200,
        },
        // 'temperature' is missing
      };

      final switchStatus = ShellySwitchStatus.fromJson(json);

      expect(switchStatus.id, equals(3));
      expect(switchStatus.source, equals('test'));
      expect(switchStatus.output, equals(false));
      expect(switchStatus.apowerInWatts, equals(75.0));
      expect(switchStatus.voltage, equals(220.0));
      expect(switchStatus.currentInAmperes, equals(4.0));
      expect(switchStatus.freq, equals(0)); // Default value when missing
      expect(switchStatus.aenergy.totalInWattHours, equals(200.0));
      expect(switchStatus.aenergy.byMinuteInMilliwattHours, equals([5.0, 10.0]));
      expect(switchStatus.aenergy.minuteTs, equals(1633627200));
      expect(switchStatus.temperature.tC,
          equals(0.0)); // Default value when missing
      expect(switchStatus.temperature.tF,
          equals(0.0)); // Default value when missing
    });

    test('fromJson should handle null values gracefully', () {
      final Map<String, dynamic> json = {
        'id': null,
        'source': null,
        'output': null,
        'apower': null,
        'voltage': null,
        'current': null,
        'freq': null,
        'aenergy': null,
        'temperature': null,
      };

      final switchStatus = ShellySwitchStatus.fromJson(json);

      expect(switchStatus.id, equals(0)); // Default value when null
      expect(switchStatus.source, equals('')); // Default value when null
      expect(switchStatus.output, equals(false)); // Default value when null
      expect(
          switchStatus.apowerInWatts, equals(0.0)); // Default value when null
      expect(switchStatus.voltage, equals(0.0)); // Default value when null
      expect(switchStatus.currentInAmperes,
          equals(0.0)); // Default value when null
      expect(switchStatus.freq, equals(0)); // Default value when null
      expect(switchStatus.aenergy.totalInWattHours,
          equals(0.0)); // Default value when null
      expect(
          switchStatus.aenergy.byMinuteInMilliwattHours,
          equals([])); // Default value when null
      expect(
          switchStatus.aenergy.minuteTs, equals(0)); // Default value when null
      expect(
          switchStatus.temperature.tC, equals(0.0)); // Default value when null
      expect(
          switchStatus.temperature.tF, equals(0.0)); // Default value when null
    });
  });

  group('Aenergy', () {
    test('test timestamp', () {
      int timestamp = 1710758852;
      DateTime t1 = DateTime.fromMillisecondsSinceEpoch(timestamp);
      DateTime t2 = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      expect(t2.year, 2024);
    });

    test('test timestamp', () {
      int timestamp = 1710758852;
      Aenergy aenergy = Aenergy(totalInWattHours: 1.0, byMinuteInMilliwattHours: [2.0, 3.0], minuteTs: timestamp);
      expect(aenergy.toString(), 'Aenergy 18.3. 12:47 total(W):1.0\n  -last minutes(mW):2.0,3.0,');
    });

  });
}

