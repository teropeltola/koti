
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'robots.dart';

class EditDeviceViewRobot {
  const EditDeviceViewRobot(this.tester);

  final WidgetTester tester;

  Future <void> validateScreen() async {
    //expect(find.widgetWithIcon(Drawer, Icons.menu),findsOneWidget);
    //expect(find.widgetWithIcon(Drawer, Icons.list),findsOneWidget);
  }

  Future <void> goBack() async {
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.textContaining('Painettaessa'), findsOneWidget);
    await tester.tap(find.textContaining('Kyllä'));
    await tester.pumpAndSettle();
  }

  Future <void> ready() async {
    await tester.pumpAndSettle();
    await tapReadyButton(tester);
    await tester.pumpAndSettle();
  }
}