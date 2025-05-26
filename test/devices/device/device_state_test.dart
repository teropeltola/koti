
import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/device/device.dart';
import 'package:koti/devices/device/device_state.dart';
import 'package:koti/devices/my_device_info.dart';
import 'package:koti/devices/wlan/active_wifi_name.dart';
import 'package:koti/interfaces/network_connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  group('DeviceState', () {
    test('initial state is notInstalled', () {
      final deviceState = DeviceState();
      expect(deviceState.currentState(), StateModel.notInstalled);
      expect(deviceState.connected(), isFalse);
      expect(deviceState.stateText(), 'ei ole asennettu');
    });

    test('clone() creates a new DeviceState with the same state', () {
      final deviceState = DeviceState();
      deviceState.setState(StateModel.connected);
      final clonedState = deviceState.clone();
      expect(clonedState.currentState(), StateModel.connected);
      expect(clonedState, isNot(same(deviceState))); // Ensure it's a new instance
    });

    test('setState() updates the state', () {
      final deviceState = DeviceState();
      deviceState.setState(StateModel.connected);
      expect(deviceState.currentState(), StateModel.connected);
      expect(deviceState.connected(), isTrue);
      expect(deviceState.stateText(), 'yhdistetty');

      deviceState.setState(StateModel.notConnected);
      expect(deviceState.currentState(), StateModel.notConnected);
      expect(deviceState.connected(), isFalse);
      expect(deviceState.stateText(), 'ei ole yhdistetty');

      deviceState.setState(StateModel.notInstalled);
      expect(deviceState.currentState(), StateModel.notInstalled);
      expect(deviceState.connected(), isFalse);
      expect(deviceState.stateText(), 'ei ole asennettu');
    });

    test('connected() returns true only when state is connected', () {
      final deviceState = DeviceState();
      deviceState.setState(StateModel.notInstalled);
      expect(deviceState.connected(), isFalse);

      deviceState.setState(StateModel.notConnected);
      expect(deviceState.connected(), isFalse);

      deviceState.setState(StateModel.connected);
      expect(deviceState.connected(), isTrue);
    });

    test('setConnected() sets the state to connected', () {
      final deviceState = DeviceState();
      deviceState.setConnected();
      expect(deviceState.currentState(), StateModel.connected);
      expect(deviceState.connected(), isTrue);
      expect(deviceState.stateText(), 'yhdistetty');
    });

    test('stateText() returns the correct text based on the current state', () {
      final deviceState = DeviceState();
      deviceState.setState(StateModel.notInstalled);
      expect(deviceState.stateText(), 'ei ole asennettu');

      deviceState.setState(StateModel.notConnected);
      expect(deviceState.stateText(), 'ei ole yhdistetty');

      deviceState.setState(StateModel.connected);
      expect(deviceState.stateText(), 'yhdistetty');
    });
  });

  group('StateModel', () {
    test('text() returns the correct text for each enum value', () {
      expect(StateModel.notInstalled.text(), 'ei ole asennettu');
      expect(StateModel.notConnected.text(), 'ei ole yhdistetty');
      expect(StateModel.connected.text(), 'yhdistetty');
    });

    test('textOptions() returns the correct list of text options', () {
      expect(StateModel.notInstalled.textOptions(),
          ['ei ole asennettu', 'ei ole yhdistetty', 'yhdistetty']);
      expect(StateModel.notConnected.textOptions(),
          ['ei ole asennettu', 'ei ole yhdistetty', 'yhdistetty']);
      expect(StateModel.connected.textOptions(),
          ['ei ole asennettu', 'ei ole yhdistetty', 'yhdistetty']);
    });
  });

  group('dependency', ()  {
    test('basic dependency between wifi and devices', () async {
      Device d1 = Device();
      d1.id = 'd1 id';
      d1.name = 'd1';
      Device d2 = Device();
      d2.id = 'd2 id';
      d2.name = 'd2';
      Device d3 = Device();
      d3.id = 'd3 id';
      d3.name = 'd3';
      allDevices.add(d1);
      allDevices.add(d2);
      allDevices.add(d3);
      expect(d1.state.currentState(), StateModel.notInstalled);
      expect(d2.state.currentState(), StateModel.notInstalled);
      expect(d3.state.currentState(), StateModel.notInstalled);

      String currentWifiName = activeWifi.name;

      d1.state.defineDependency(stateDependantOnWifi, 'testWifi');
      expect(d1.state.currentState(), StateModel.notConnected);
      expect(d2.state.currentState(), StateModel.notInstalled);
      expect(d3.state.currentState(), StateModel.notInstalled);
      d2.state.defineDependency(d1.id, d1.name);
      expect(d1.state.currentState(), StateModel.notConnected);
      expect(d2.state.currentState(), StateModel.notConnected);
      expect(d3.state.currentState(), StateModel.notInstalled);
      d3.state.defineDependency(d2.id,d3.name);
      expect(d1.state.currentState(), StateModel.notConnected);
      expect(d2.state.currentState(), StateModel.notConnected);
      expect(d3.state.currentState(), StateModel.notConnected);
      activeWifi.changeWifiName('testWifi');
      await Future.delayed(Duration(milliseconds: 3), () {});
      expect(d1.state.currentState(), StateModel.connected);
      expect(d2.state.currentState(), StateModel.connected);
      expect(d3.state.currentState(), StateModel.connected);
      d2.state.setState(StateModel.notConnected);
      await Future.delayed(Duration(milliseconds: 3), () {});
      expect(d1.state.currentState(), StateModel.connected);
      expect(d2.state.currentState(), StateModel.notConnected);
      expect(d3.state.currentState(), StateModel.notConnected);

      d1.state.setState(StateModel.notConnected);
      await Future.delayed(Duration(milliseconds: 3), () {});
      expect(d1.state.currentState(), StateModel.notConnected);
      expect(d2.state.currentState(), StateModel.notConnected);
      expect(d3.state.currentState(), StateModel.notConnected);

      activeWifi.changeWifiName(currentWifiName);
    });

    test('basic dependency between IP connectivity and devices', () async {
      Device d1 = Device();
      d1.id = 'd1 id';
      d1.name = 'd1';
      Device d2 = Device();
      d2.id = 'd2 id';
      d2.name = 'd2';
      Device d3 = Device();
      d3.id = 'd3 id';
      d3.name = 'd3';
      allDevices.add(d1);
      allDevices.add(d2);
      allDevices.add(d3);
      expect(d1.state.currentState(), StateModel.notInstalled);
      expect(d2.state.currentState(), StateModel.notInstalled);
      expect(d3.state.currentState(), StateModel.notInstalled);

      StateModel currentNetworkState = ipNetworkState.data;

      ipNetworkState.data = StateModel.notConnected;
      d1.state.defineDependency(stateDependantOnIP, 'testWifi');
      expect(d1.state.currentState(), StateModel.notConnected);
      expect(d2.state.currentState(), StateModel.notInstalled);
      expect(d3.state.currentState(), StateModel.notInstalled);
      d2.state.defineDependency(d1.id, d1.name);
      expect(d1.state.currentState(), StateModel.notConnected);
      expect(d2.state.currentState(), StateModel.notConnected);
      expect(d3.state.currentState(), StateModel.notInstalled);
      d3.state.defineDependency(d2.id,d3.name);
      expect(d1.state.currentState(), StateModel.notConnected);
      expect(d2.state.currentState(), StateModel.notConnected);
      expect(d3.state.currentState(), StateModel.notConnected);
      ipNetworkState.data = StateModel.connected;
      await Future.delayed(Duration(milliseconds: 3), () {});
      expect(d1.state.currentState(), StateModel.connected);
      expect(d2.state.currentState(), StateModel.connected);
      expect(d3.state.currentState(), StateModel.connected);
      d2.state.setState(StateModel.notConnected);
      await Future.delayed(Duration(milliseconds: 3), () {});
      expect(d1.state.currentState(), StateModel.connected);
      expect(d2.state.currentState(), StateModel.notConnected);
      expect(d3.state.currentState(), StateModel.notConnected);

      d1.state.setState(StateModel.notConnected);
      await Future.delayed(Duration(milliseconds: 3), () {});
      expect(d1.state.currentState(), StateModel.notConnected);
      expect(d2.state.currentState(), StateModel.notConnected);
      expect(d3.state.currentState(), StateModel.notConnected);

      ipNetworkState.data = currentNetworkState;
    });
  });

}