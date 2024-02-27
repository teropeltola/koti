
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:koti/devices/device/device.dart';
import 'package:koti/devices/device/device_state.dart';
import 'package:koti/devices/network_device/network_device.dart';
import 'package:koti/devices/ouman/ouman_device.dart';
import 'package:koti/devices/shelly_timer_switch/shelly_timer_switch.dart';

import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/estate/estate.dart';
import 'package:koti/look_and_feel.dart';

void main() {
  group('NetworkDevice tests', () {
    test('NetworkDevice should be created with default values', () {
      NetworkDevice n = NetworkDevice();

      expect(n.name, '');
      expect(n.id, '');
      expect(n.state, isA<DeviceState>());
      expect(n.connectedFunctionalities.isEmpty, true);
      expect(n.myEstate, isA<Estate>());
    });

    test('Device should be created from JSON correctly', () {
      Map<String, dynamic> json = {
        'name': 'TestDevice',
        'id': '123',
      };

      NetworkDevice device = NetworkDevice.fromJson(json);

      expect(device.name, 'TestDevice');
      expect(device.id, '123');

      json = {
        'name': 'TestDevice',
        'id': '123',
        'internetPage' : 'web'
      };
      device = NetworkDevice.fromJson(json);

      expect(device.name, 'TestDevice');
      expect(device.id, '123');
      expect(device.internetPage, 'web');

    });

    test('JSON representation should be correct', () {
      NetworkDevice device = NetworkDevice();
      device.name = 'TestDevice';
      device.id = '123';

      Map<String, dynamic> json = device.toJson();

      expect(json['name'], 'TestDevice');
      expect(json['id'], '123');

      device.internetPage = 'web page';
      json = device.toJson();
      expect(json['internetPage'], 'web page');

    });
  });
}
