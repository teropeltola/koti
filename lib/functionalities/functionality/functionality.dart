import 'package:koti/functionalities/functionality/view/functionality_view.dart';

import '../../devices/device/device.dart';

class Functionality {
  late Device device;

  void pair(Device newDevice) {
    device = newDevice;
    device.functionality = this;
  }

  FunctionalityView myView() {
    return FunctionalityView(this);
  }
}