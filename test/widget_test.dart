// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:koti/devices/device/device.dart';
import 'package:koti/devices/my_device_info.dart';
import 'package:koti/estate/estate.dart';
import 'package:koti/functionalities/functionality/functionality.dart';

import 'package:koti/main.dart';

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

void main() {

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });
  testWidgets('test widget templates', (WidgetTester tester) async {

    // Build our app and trigger a frame.
    await tester.pumpWidget(const TestApp());
/*
    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
 */
  });

}
