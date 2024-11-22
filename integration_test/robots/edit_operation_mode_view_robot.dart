import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:koti/operation_modes/conditional_operation_modes.dart';
import 'package:koti/operation_modes/view/conditional_option_list_view.dart';

import 'robots.dart';

class EditOperationModeViewRobot  {
  const EditOperationModeViewRobot(this.tester);

  final WidgetTester tester;

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


  Future <void> enterName(String name) async {
    await enterTextField(tester, 'operationModeName', name);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
  }

  Future <void> addNewTimeRule(TimeOfDay startTime, TimeOfDay endTime, String targetOpMode) async {
    await selectDropdownItem(tester, 'alternativeTypes', 'Vaihtuva');
    await tapTextContaining(tester, 'Lisää uusi sääntö');
    await selectDropdownItem(tester, 'conditionOptions0', 'kellonaika');
    // TODO: find a way to command the visual edit - now we update the data without user interface
    _hackTimeSelection(startTime, endTime);
    await selectDropdownItem(tester, 'possibleOperationModes0', targetOpMode);
    await tester.pumpAndSettle(Duration(seconds:5));
    await tapTextContaining(tester, 'OK');
    await tester.pumpAndSettle(Duration(seconds:5));
  }

  void _hackTimeSelection(TimeOfDay start, TimeOfDay end) {
    debugOperationCondition.timeRange = MyTimeRange(startTime: start, endTime: end);
  }
}