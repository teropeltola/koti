import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'robots.dart';

class EditBoilerHeatingViewRobot  {
  const EditBoilerHeatingViewRobot(this.tester);

  final WidgetTester tester;


  Future <void> goBack() async {
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.textContaining('Poistuttaessa'), findsOneWidget);
    await tester.tap(find.textContaining('Kyllä'));
    await tester.pumpAndSettle();
  }


  Future <void> ready() async {
    await tester.pumpAndSettle();
    await tapReadyButton(tester);
    await tester.pumpAndSettle();
  }


  Future <void> goCreateNewFunction() async {
    await tester.pumpAndSettle();
    await tapTextContaining(tester,'Luo uusi');
    await tester.pumpAndSettle();
  }

  Future <void> goEditFunction(String functionName) async {
    await tester.pumpAndSettle();
    await tapKey(tester, 'edit-$functionName');
    await tester.pumpAndSettle();
  }

  Future <void> deleteFunction(String functionName) async {
    await tester.pumpAndSettle();
    await tapKey(tester, 'delete-$functionName');
    await tester.pumpAndSettle();
    await tapTextContaining(tester, 'Kyllä');
    await tester.pumpAndSettle();
  }
}