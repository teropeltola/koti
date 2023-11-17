
import '../device/device.dart';

class PlainSwitchFunctionality extends Device {

  bool _on = false;

  bool switchToggle() {
    _on = ! _on;
    return _on;
  }

  void setToggle(bool toggle) {
    _on = toggle;
  }

  bool switchStatus() {
    return _on;
  }

}