
import '../device/device.dart';

class ShellyTimerSwitch extends Device {

  bool _on = false;

  bool switchToggle() {
    _on = ! _on;
    return _on;
  }

  bool switchStatus() {
    return _on;
  }

}