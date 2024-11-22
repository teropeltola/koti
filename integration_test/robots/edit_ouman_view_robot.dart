import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'robots.dart';

class EditOumanViewRobot extends EditDeviceViewRobot {
  EditOumanViewRobot(super.tester);

  Future <void> enterName(String name) async {
    await tester.pumpAndSettle();
    await enterTextField(tester, 'oDeviceName', name);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
  }

  Future <void> enterIpAddress(String ipAddress) async {
    await enterTextField(tester, 'ipAddress', ipAddress);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
  }
  Future <void> enterUsername(String username) async {
    await enterTextField(tester, 'usernameKey', username);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
  }

  Future <void> enterPassword(String password) async {
    await enterTextField(tester, 'passwordKey', password);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

}