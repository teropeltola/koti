import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/my_device_info.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:koti/devices/ouman/ouman_device.dart';
import 'package:koti/estate/estate.dart';
import 'package:koti/logic/observation.dart';
import 'package:koti/look_and_feel.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

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
      Estate estate = Estate();
      estate.addDevice(oumanDevice);
      await oumanDevice.init();

      expect(oumanDevice.outsideTemperature(), noValueDouble);
      expect(oumanDevice.measuredWaterTemperature(), noValueDouble);
      expect(oumanDevice.requestedWaterTemperature(), noValueDouble);
      expect(oumanDevice.valve(), noValueDouble);
      expect(oumanDevice.heaterEstimatedTemperature(), noValueDouble);
      expect(oumanDevice.fetchingTime(), DateTime(0));
    });

    test('Observation level determination', () async {
      OumanDevice oumanDevice = OumanDevice();
      Estate estate = Estate();
      estate.addDevice(oumanDevice);
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

    /* not tested anymore because this would require username & password
    test('Login and logout', () async {
      OumanDevice oumanDevice = OumanDevice();
      Estate estate = Estate();
      estate.addDevice(oumanDevice);
      await oumanDevice.init();
      // Test login
      expect(await oumanDevice.login(), isTrue);

      // Test logout
      expect(await oumanDevice.logout(), isTrue);
    });


     */
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

    test('observationLevel test', () {
      OumanDevice device = OumanDevice();
      device.name = 'TestDevice';
      device.id = '123';

      device.requestResult = { oumanCodes['L1Valve'] ?? '': '10.0'};
      device.analyseRequest();

      expect(device.observationLevel(), ObservationLevel.ok);

      device.requestResult = {
        oumanCodes['L1Valve'] ?? '': '10.0',
        oumanCodes['L1MeasuredWaterTemperature'] ?? '': '60.0',
        oumanCodes['L1RequestedWaterTemperature'] ?? '': '60.0',
        oumanCodes['OutsideTemperature'] ?? '': '-3.0'};
      device.analyseRequest();

      expect(device.observationLevel(), ObservationLevel.ok);

      device.requestResult = {
        oumanCodes['L1Valve'] ?? '': '99.1',
        oumanCodes['L1MeasuredWaterTemperature'] ?? '': '60.0',
        oumanCodes['L1RequestedWaterTemperature'] ?? '': '60.6',
        oumanCodes['OutsideTemperature'] ?? '': '-3.0'};
      device.analyseRequest();

      expect(device.observationLevel(), ObservationLevel.alarm);

      device.requestResult = {
        oumanCodes['L1Valve'] ?? '': '99.1',
        oumanCodes['L1MeasuredWaterTemperature'] ?? '': '60.0',
        oumanCodes['L1RequestedWaterTemperature'] ?? '': '60.4',
        oumanCodes['OutsideTemperature'] ?? '': '-3.0'};
      device.analyseRequest();

      expect(device.observationLevel(), ObservationLevel.warning);

      device.requestResult = {
        oumanCodes['L1Valve'] ?? '': '91.1',
        oumanCodes['L1MeasuredWaterTemperature'] ?? '': '60.0',
        oumanCodes['L1RequestedWaterTemperature'] ?? '': '60.0',
        oumanCodes['OutsideTemperature'] ?? '': '-3.0'};
      device.analyseRequest();

      expect(device.observationLevel(), ObservationLevel.informatic);
      expect(device.outsideTemperatureFunction(),-3.0);
      expect(device.parameterValue('OutsideTemperature'), '-3.0');
      expect(device.oumanDataCodes().length,189);

    });


  test('ParseDeviceData tests', () {

    Map<String,String> result = parseDeviceData('kukkuu');

    expect(result,{});
    String lastLog = log.history.last.message ?? '';
    expect(lastLog.contains('kukkuu'),true);
    log.cleanHistory();

    result = parseDeviceData('request?a=3.0;b=-2.2');
    expect(result['a'],'3.0');
    expect(result['b'],'-2.2');
    expect(result['c'],null);

    result = parseDeviceData('request?aaaa');
    expect(result,{});

  });

    // Add more tests for other methods as needed
  });
}

