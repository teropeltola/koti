
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'robots.dart';

class EditEstateViewRobot {
  const EditEstateViewRobot(this.tester);

  final WidgetTester tester;

  Future <void> validateScreen() async {
    expect(find.text('Asunnon tiedot'),findsOneWidget);
  }

  Future <void> goBack() async {
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.textContaining('Poistuttaessa muutokset'), findsOneWidget);
    await tester.tap(find.textContaining('Kyllä'));
    await tester.pumpAndSettle();

  }


  Future <void> enterEstateName(String name) async {
    await tester.pumpAndSettle();
    await enterTextField(tester, 'estateName', name);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
  }

  Future <void> enterWifiName(String wifiName) async {
    await enterTextField(tester, 'wifiName', wifiName);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
  }


  Future <void> selectElectricityAgreement(String selectionText) async {
    await selectDropdownItem(tester, 'electricityAgreement', selectionText);
  }

  Future <void> selectElectricityDistributionAgreement(String selectionText) async {
    await selectDropdownItem(tester, 'electricityDistributionAgreement', selectionText);
  }

  Future <void> tapReady() async {
    await tapReadyButton(tester);
  }

  Future <void> addTestSwitch(String switchName) async {
    await tapTextContaining(tester, 'testikytkin');
    EditTestSwitchDeviceViewRobot editTestSwitchDeviceViewRobot = EditTestSwitchDeviceViewRobot(tester);
    await editTestSwitchDeviceViewRobot.enterName(switchName);
    await editTestSwitchDeviceViewRobot.ready();
  }

  Future <void> addOuman(String myOuman) async {
    await tapTextContaining(tester, 'ouman');
    EditOumanViewRobot editOumanViewRobot = EditOumanViewRobot(tester);
    await editOumanViewRobot.enterName(myOuman);
    await editOumanViewRobot.enterIpAddress('12.34.56.78');
    await editOumanViewRobot.enterUsername('oumanUser');
    await editOumanViewRobot.enterPassword('oumanPW');
    await tester.pumpAndSettle();
    await editOumanViewRobot.ready();
    await tester.pumpAndSettle();
    expect(find.textContaining('Yhteyttä laitteiseen'), findsOneWidget);
    await tapTextContaining(tester, 'OK');
    await tester.pumpAndSettle(Duration(seconds:5));
  }

  Future goAddNewFunctionality(String functionalityType, String functionalityName) async {
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.textContaining(functionalityType), 500.0, scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await selectDropdownItem(tester, '$functionalityType-options', functionalityName);
    await tester.pumpAndSettle();
  }

  ///////////////////
  Future <void> createEstate() async {
    EditEstateViewRobot editEstateView = EditEstateViewRobot(tester);

    await editEstateView.enterEstateName('my house');
    await editEstateView.enterWifiName('myWifi');
    await editEstateView.selectElectricityAgreement('Fortum Tarkka');
    await editEstateView.selectElectricityDistributionAgreement(
        'Helen Aikasiirto');
    await editEstateView.tapReady();
    await toGetScreenUpdatesDone();
  }
}