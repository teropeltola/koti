
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';


class MyTalkerViewRobot {
  const MyTalkerViewRobot(this.tester);

  final WidgetTester tester;

  Future <void> validateScreen() async {
    expect(find.text('Loki'), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Icons.menu), findsOneWidget);
  }

  Future <void> goBack() async {
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
  }

}
