
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'robots.dart';

class EstateViewRobot {
  const EstateViewRobot(this.tester);

  final WidgetTester tester;

  Future <void> validateScreen() async {
    expect(find.widgetWithIcon(Drawer, Icons.menu),findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Icons.edit),findsOneWidget);
    expect(find.widgetWithIcon(Drawer, Icons.list),findsOneWidget);
  }

  Future <void> goEditEstate() async {
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
  }

  Future <void> deleteEstate() async {
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tämä komento tuhoaa'), findsOneWidget);
    await tester.tap(find.textContaining('Kyllä'));
    await tester.pumpAndSettle();
  }

  Future <void> openDrawer() async {
    await tester.pumpAndSettle();
    var locateDrawer = find.byTooltip('Open navigation menu');
    await tester.pumpAndSettle();
    await tester.tap(locateDrawer);
    await tester.pumpAndSettle();
  }

  ///////////////////////////
  Future <void> checkDiagnostics() async {
    await tester.pumpAndSettle();
    await openDrawer();

    await MyDrawerViewRobot(tester).doDiagnostics();

  }

}