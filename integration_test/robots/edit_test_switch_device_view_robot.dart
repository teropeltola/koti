import 'package:flutter_test/flutter_test.dart';

import 'robots.dart';

class EditTestSwitchDeviceViewRobot extends EditDeviceViewRobot {
  EditTestSwitchDeviceViewRobot(super.tester);

  Future <void> enterName(String name) async {
    await enterTextField(tester, 'deviceName', name);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
  }

}