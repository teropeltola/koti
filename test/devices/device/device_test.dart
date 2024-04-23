
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:koti/devices/device/device.dart';
import 'package:koti/devices/device/device_state.dart';
import 'package:koti/devices/ouman/ouman_device.dart';
import 'package:koti/devices/shelly_timer_switch/shelly_timer_switch.dart';

import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/estate/estate.dart';
import 'package:koti/look_and_feel.dart';

void main() {
  group('Device tests', () {
    test('Device should be created with default values', () {
      Device device = Device();

      expect(device.name, '');
      expect(device.id, '');
      expect(device.state, isA<DeviceState>());
      expect(device.connectedFunctionalities.isEmpty, true);
      expect(device.myEstates.isEmpty, true);
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
      originalDevice.myEstates.add(Estate());

      Device clonedDevice = originalDevice.clone();

      expect(clonedDevice.name, originalDevice.name);
      expect(clonedDevice.id, originalDevice.id);
      expect(clonedDevice.state.currentState(), originalDevice.state.currentState());
      expect(clonedDevice.connectedFunctionalities[0], f);
      expect(clonedDevice.myEstates[0], originalDevice.myEstates[0]);
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
      originalDevice.myEstates.add(Estate());
      originalDevice.myEstates[0].name = 'TestEstate';
      originalDevice.state.setState(StateModel.connected);

      Device clonedDevice = originalDevice.clone();
      originalDevice.myEstates[0].name = 'TestEstate2';
      originalDevice.state.setState(StateModel.notInstalled);

      expect(clonedDevice.name, originalDevice.name);
      expect(clonedDevice.id, originalDevice.id);
      expect(clonedDevice.connectedFunctionalities[0], f);
      expect(clonedDevice.myEstates[0], originalDevice.myEstates[0]);
      expect(clonedDevice.myEstates[0].name, 'TestEstate2');
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
    expect(device.temperatureFunction(),-99.9);

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
}
