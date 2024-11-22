
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'robots.dart';

class MyDrawerViewRobot {
  const MyDrawerViewRobot(this.tester);

  final WidgetTester tester;

  Future <void> validateScreen() async {
    expect(find.text('Asunnot'), findsOneWidget);
    expect(find.text('Loki'), findsOneWidget);
    expect(find.text('Tietorakenteet'), findsOneWidget);
  }

  Future <void> doDiagnostics() async {
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Diagnostiikka'));
    await tester.pumpAndSettle();
    var finder = find.textContaining('Kaikki kunnossa');
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('OK'));
    await tester.pumpAndSettle();
    if (finder.hasFound) {
      await MyTalkerViewRobot(tester).goBack();
      await tester.pumpAndSettle();
    }
    await tester.tap(find.textContaining('Palaa takaisin'));
  }
}