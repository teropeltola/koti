import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koti/main.dart';
import 'package:integration_test/integration_test.dart';
import 'robots/robots.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await appInitializationRoutines();
  await resetAllFatal();

  group('end-to-end test', () {
    testWidgets('first test flow from empty to several devices',
            (tester) async {
          // Load app widget.
          await tester.pumpWidget(const MyApp());

          await _firstTest(tester);
        });
  });
}

Future <void> _firstTest(WidgetTester tester) async {
  FirstPageScreenRobot firstPageScreenRobot = FirstPageScreenRobot(tester);

  await firstPageScreenRobot.validate();

  await firstPageScreenRobot.tapNextScreen();

  await EditEstateViewRobot(tester).createEstate();

  EstateViewRobot e = EstateViewRobot(tester);

  //await e.checkDiagnostics();

  await e.goEditEstate();
  await EditEstateViewRobot(tester).tapReady();

  // await e.checkDiagnostics();

  await e.goEditEstate();
  await EditEstateViewRobot(tester).goBack();

  // await e.checkDiagnostics();

  await e.goEditEstate();

  EditEstateViewRobot ee = EditEstateViewRobot(tester);

  await ee.addTestSwitch('testSw');
  await ee.addOuman('oumanT');
  await tester.pumpAndSettle();
  await ee.tapReady();

  // await e.checkDiagnostics();

  await e.goEditEstate();

  await ee.goAddNewFunctionality('lämmitys','Lämminvesivaraaja');

  EditBoilerHeatingViewRobot editBoilerHeatingViewRobot = EditBoilerHeatingViewRobot(tester);

  await editBoilerHeatingViewRobot.goCreateNewFunction();

  EditOperationModeViewRobot editOperationModeViewRobot = EditOperationModeViewRobot(tester);

  await editOperationModeViewRobot.enterName('normi');
  await editOperationModeViewRobot.addNewTimeRule(const TimeOfDay(hour:10,minute:0),const TimeOfDay(hour:11,minute:0),'Päällä');
  await editOperationModeViewRobot.ready();

  await editBoilerHeatingViewRobot.ready();

  await ee.tapReady();

  // await e.checkDiagnostics();
}

