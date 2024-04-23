
import '../shelly/shelly_device.dart';

class ShellyTimerSwitch extends ShellyDevice {

  bool _on = false;

  ShellyTimerSwitch();

  bool switchToggle() {
    _on = ! _on;
    return _on;
  }

  bool switchStatus() {
    return _on;
  }


  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  ShellyTimerSwitch.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }

}