import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

import 'package:koti/devices/wlan/active_wifi_name.dart';


void main() {
  group('ActiveWifiName Tests', () {
    test('Initialization', () {
      final testWifiName = ActiveWifiName(); // Create a new instance for this test.
      expect(testWifiName.activeWifiName, '');
      testWifiName.dispose(); // Close the stream controller after the test.
    });


    test('Change Wifi Name', () {
      final testWifiName = ActiveWifiName(); // Create a new instance for this test.
      const newName = 'NewWifiName';
      testWifiName.changeWifiName(newName);
      expect(testWifiName.activeWifiName, newName);
      testWifiName.dispose(); // Close the stream controller after the test.
    });

    test('activeWifiName variable', () {
      expect(activeWifiName.activeWifiName, '');
      activeWifiName.changeWifiName('new Name');
      expect(activeWifiName.activeWifiName, 'new Name');
    });

    test('iAmActive', () {
      expect(activeWifiName.iAmActive('nope'), false);
      activeWifiName.changeWifiName('new Name');
      expect(activeWifiName.iAmActive('new Name'), true);
      expect(activeWifiName.iAmActive('nope'), false);
    });

    testWidgets('Stream Updates', (WidgetTester tester) async {
      final testWifiName = ActiveWifiName(); // Create a new instance for this test.
      const newName = 'NewWifiName';
      final streamValues = <String>[];

      testWifiName.stream.listen((value) {
        streamValues.add(value);
      });

      testWifiName.changeWifiName(newName);
      await tester.pump(const Duration(milliseconds: 10)); // Pump the widget tree.

      expect(streamValues, ['', newName]);
      testWifiName.dispose(); // Close the stream controller after the test.
    });
  });


  testWidgets('Stream Broadcasting', (WidgetTester tester) async {
    final testWifiName = ActiveWifiName(); // Create a new instance for this test.
    const newName = 'NewWifiName';
    final streamValues1 = <String>[];
    final streamValues2 = <String>[];

    Stream myBroadcastStream = testWifiName.stream.asBroadcastStream();

    myBroadcastStream.listen((value) {
      streamValues1.add(value);
    });

    myBroadcastStream.listen((value) {
      streamValues2.add(value);
    });

    testWifiName.changeWifiName(newName);
    await tester.pump(const Duration(milliseconds: 10)); // Pump the widget tree.

    expect(streamValues1, ['', newName]);
    expect(streamValues2, ['', newName]);

    final streamValues3 = <String>[];

    myBroadcastStream.listen((value) {
      streamValues3.add(value);
    });

    testWifiName.changeWifiName('Hi');
    await tester.pump(const Duration(milliseconds: 10)); // Pump the widget tree.

    expect(streamValues1, ['', newName, 'Hi']);
    expect(streamValues2, ['', newName, 'Hi']);
    expect(streamValues3, [ 'Hi']);

    testWifiName.dispose(); // Close the stream controller after the test.
  });

  testWidgets('ActiveWifiBroadcaster', (WidgetTester tester) async {
    final testWifiName = ActiveWifiName(); // Create a new instance for this test.
    const newName = 'NewWifiName';
    final streamValues1 = <String>[];
    final streamValues2 = <String>[];

    ActiveWifiBroadcaster myBroadcast = ActiveWifiBroadcaster(testWifiName);

    myBroadcast.setListener((value) {
      streamValues1.add(value);
    });

    myBroadcast.setListener((value) {
      streamValues2.add(value);
    });

    testWifiName.changeWifiName(newName);
    await tester.pump(const Duration(milliseconds: 10)); // Pump the widget tree.

    expect(streamValues1, ['', newName]);
    expect(streamValues2, ['', newName]);

    final streamValues3 = <String>[];

    myBroadcast.setListener((value) {
      streamValues3.add(value);
    });

    testWifiName.changeWifiName('Hi');
    await tester.pump(const Duration(milliseconds: 10)); // Pump the widget tree.

    expect(streamValues1, ['', newName, 'Hi']);
    expect(streamValues2, ['', newName, 'Hi']);
    expect(streamValues3, [ 'Hi']);

    testWifiName.dispose(); // Close the stream controller after the test.
  });

}

