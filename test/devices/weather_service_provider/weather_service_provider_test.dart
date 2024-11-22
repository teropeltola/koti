
import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/my_device_info.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:koti/devices/device/device_state.dart';
import 'package:koti/devices/weather_service_provider/weather_service_provider.dart';


void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  group('WeatherServiceProvider tests', () {
    test('WeatherServiceProvider should be created with default values', () {
      WeatherServiceProvider w = WeatherServiceProvider('page', 'title', 'locationName');

      expect(w.name, '');
      expect(w.id.contains('W#'), true);
      expect(w.state, isA<DeviceState>());
      expect(w.connectedFunctionalities.isEmpty, true);
      expect(w.myEstateId, '');
      expect(w.internetPage, 'page');
      expect(w.weatherPage(),'page');
      expect(w.title(),'title');
   });

    test('Device should be created from JSON correctly', () {
      Map<String, dynamic> json = {
        'name': 'TestDevice',
        'id': '123',
      };

      WeatherServiceProvider w = WeatherServiceProvider.fromJson(json);

      expect(w.name, 'TestDevice');
      expect(w.id, '123');

      json = {
        'name': 'TestDevice',
        'id': '123',
        'internetPage' : 'web'
      };
      w = WeatherServiceProvider.fromJson(json);

      expect(w.name, 'TestDevice');
      expect(w.id, '123');
      expect(w.internetPage, 'web');

    });

    test('JSON representation should be correct', () {
      WeatherServiceProvider w = WeatherServiceProvider('page', 'title', 'location');
      w.name = 'TestDevice';
      w.id = '123';
      expect(w.locationName, 'location');

      Map<String, dynamic> json = w.toJson();

      expect(json['name'], 'TestDevice');
      expect(json['id'], '123');
      expect(json['internetPage'], 'page');
      expect(json['title'], 'title');
      expect(json['locationName'], 'location');

    });

  });
}
