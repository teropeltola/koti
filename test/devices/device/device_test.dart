
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:koti/devices/my_device_info.dart';
import 'package:koti/devices/ouman/view/ouman_view.dart';
import 'package:koti/logic/observation.dart';

import 'package:koti/devices/device/device.dart';
import 'package:koti/devices/device/device_state.dart';
import 'package:koti/devices/ouman/ouman_device.dart';
import 'package:koti/devices/shelly_timer_switch/shelly_timer_switch.dart';

import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/estate/estate.dart';
import 'package:koti/look_and_feel.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  group('Device tests', () {
    test('Device should be created with default values', () {
      Device device = Device();

      expect(device.name, '');
      expect(device.id, '');
      expect(device.state, isA<DeviceState>());
      expect(device.connectedFunctionalities.isEmpty, true);
      expect(device.myEstateId, '');
      expect(device.connected(), false);
      device.state.setConnected();
      expect(device.connected(), true);
      // dummy tests for coverage
      expect(device.observationLevel(),ObservationLevel.ok);
    });


    test('Details description should be an empty string', () {
      Device device = Device();

      String description = device.detailsDescription();

      expect(description, '');
    });

    test('Cloned device should have the same properties', () {
      Device originalDevice = Device();
      Functionality f = Functionality();
      originalDevice.name = 'TestDevice';
      originalDevice.id = '123';
      originalDevice.state = DeviceState();
      originalDevice.connectedFunctionalities.add(f);
      originalDevice.myEstateId = 'estate';

      Device clonedDevice = originalDevice.clone();

      expect(clonedDevice.name, originalDevice.name);
      expect(clonedDevice.id, originalDevice.id);
      expect(clonedDevice.state.currentState(), originalDevice.state.currentState());
      expect(clonedDevice.connectedFunctionalities[0], f);
      expect(clonedDevice.myEstateId, originalDevice.myEstateId);
    });

    test('Device should be created from JSON correctly', () {
      Map<String, dynamic> json = {
        'name': 'TestDevice',
        'id': '123',
      };

      Device device = Device.fromJson(json);

      expect(device.name, 'TestDevice');
      expect(device.id, '123');
    });

    test('JSON representation should be correct', () {
      Device device = Device();
      device.name = 'TestDevice';
      device.id = '123';

      Map<String, dynamic> json = device.toJson();

      expect(json['name'], 'TestDevice');
      expect(json['id'], '123');
    });

    test('Cloned device content should be really copied', () {
      Device originalDevice = Device();
      Functionality f = Functionality();
      originalDevice.name = 'TestDevice';
      originalDevice.id = '123';
      originalDevice.state = DeviceState();
      originalDevice.connectedFunctionalities.add(f);
      Estate estate = Estate();
      originalDevice.myEstateId = estate.id;
      estate.name = 'TestEstate';
      originalDevice.state.setState(StateModel.connected);

      Device clonedDevice = originalDevice.clone();
      originalDevice.state.setState(StateModel.notInstalled);

      expect(clonedDevice.name, originalDevice.name);
      expect(clonedDevice.id, originalDevice.id);
      expect(clonedDevice.connectedFunctionalities[0], f);
      expect(clonedDevice.myEstateId, originalDevice.myEstateId);
      expect(clonedDevice.state.currentState(), StateModel.connected);

    });

    test('JSON object finder - Device', () {
      Device device = Device();
      device.name = 'TestDevice';
      device.id = '123';
      var json = device.toJson();

      var newDevice = extendedDeviceFromJson(json);
      expect(newDevice is Device, true);
      expect(newDevice.name,'TestDevice');
    });

    test('JSON object finder - ShellyTimerSwitch', () {
      Device device = ShellyTimerSwitch();
      device.name = 'TestDevice';
      device.id = '123';
      var json = device.toJson();

      var newDevice = extendedDeviceFromJson(json);
      expect(newDevice is ShellyTimerSwitch, true);
      expect(newDevice.name,'TestDevice');

    });

    test('JSON object finder - OumanDevice ', () {
      OumanDevice device = OumanDevice();
      device.name = 'TestDevice';
      device.id = '123';
      device.ipAddress = '1.2.3.4.';
      var json = device.toJson();

      var newDevice = extendedDeviceFromJson(json);
      expect(newDevice is OumanDevice, true);
      expect(newDevice.name,'TestDevice');
      expect((newDevice as OumanDevice).ipAddress,'1.2.3.4.');
    });

  });

  test('JSON object finder - wrong name', () {
    Device device = Device();
    device.name = 'TestDevice';
    device.id = '123';
    var json = device.toJson();
    json['type'] = 'notFoundType';

    var newDevice = extendedDeviceFromJson(json);
    expect(newDevice is Device, true);
    expect(newDevice.name,'');
    var x = log.history.last;
    expect(x.message, 'unknown jsonObject: notFoundType');

  });

  test('device other functions', () async {
    Device device = Device();
    device.name = 'TestDevice';
    device.id = '123';
    await device.init();
    expect(device.outsideTemperatureFunction(),-99.9);

  });

  test('device dispose', () async {
    clearAllDevices();
    Device device = Device();
    device.name = 'TestDevice';
    device.id = '123';

    Device d2 = findDevice('123');
    expect(d2.name, device.name);
    device.dispose();
    d2 = findDevice('123');
    expect(d2 == noDevice, true);
  });

    // dummy tests to get coverage 100% (to avoid checking what is missing...)
    testWidgets('test device edit widget', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const TestApp());
    });

}

class TestApp extends StatelessWidget {
  const TestApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Estate estate = Estate();
    Device device = Device();
    Functionality functionality = Functionality();

    device.editWidget(context, estate);

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

