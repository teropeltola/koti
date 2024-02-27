import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/ouman/ouman_device.dart';
import 'package:koti/estate/estate.dart';
import 'package:koti/logic/observation.dart';

void main() {
  group('OumanDevice', () {

    test('Initialization', () async {
      Estate estate = Estate();
      OumanDevice oumanDevice = OumanDevice();
      estate.addDevice(oumanDevice);
      expect(oumanDevice.noData(), true);
      await oumanDevice.init();
      expect(oumanDevice.noData(), true);
    });

    test('Data fetching and analysis', () async {
      OumanDevice oumanDevice = OumanDevice();
      await oumanDevice.init();

      expect(oumanDevice.outsideTemperature(), noValue);
      expect(oumanDevice.measuredWaterTemperature(), noValue);
      expect(oumanDevice.requestedWaterTemperature(), noValue);
      expect(oumanDevice.valve(), noValue);
      expect(oumanDevice.heaterEstimatedTemperature(), noValue);
      expect(oumanDevice.fetchingTime(), DateTime(0));
    });

    test('Observation level determination', () async {
      OumanDevice oumanDevice = OumanDevice();
      await oumanDevice.init();
      // Test for different observation levels
      oumanDevice.requestResult = {
        oumanCodes['OutsideTemperature']!: '10.0',
  oumanCodes['L1MeasuredWaterTemperature']!: '15.0',
  oumanCodes['L1RequestedWaterTemperature']!: '20.0',
  oumanCodes['L1Valve']!: '50.0',

      };
      oumanDevice.analyseRequest();
      expect(oumanDevice.observationLevel(), equals(ObservationLevel.ok));
      expect(oumanDevice.outsideTemperature(), 10.0);
      expect(oumanDevice.measuredWaterTemperature(), 15.0);
      expect(oumanDevice.requestedWaterTemperature(), 20.0);
      expect(oumanDevice.valve(), 50.0);
    });

    test('Login and logout', () async {
      OumanDevice oumanDevice = OumanDevice();
      await oumanDevice.init();
      // Test login
      expect(await oumanDevice.login(), isTrue);

      // Test logout
      expect(await oumanDevice.logout(), isTrue);
    });

    test('Device should be created from JSON correctly', () {
      Map<String, dynamic> json = {
        'name': 'TestDevice',
        'id': '123',
      };

      OumanDevice device = OumanDevice.fromJson(json);

      expect(device.name, 'TestDevice');
      expect(device.id, '123');

      json = {
        'name': 'TestDevice',
        'id': '123',
        'ipAddress' : 'web'
      };
      device = OumanDevice.fromJson(json);

      expect(device.name, 'TestDevice');
      expect(device.id, '123');
      expect(device.ipAddress, 'web');

    });

    test('JSON representation should be correct', () {
      OumanDevice device = OumanDevice();
      device.name = 'TestDevice';
      device.id = '123';

      Map<String, dynamic> json = device.toJson();

      expect(json['name'], 'TestDevice');
      expect(json['id'], '123');

      device.ipAddress = 'web page';
      json = device.toJson();
      expect(json['ipAddress'], 'web page');

    });

    // Add more tests for other methods as needed
  });
}

