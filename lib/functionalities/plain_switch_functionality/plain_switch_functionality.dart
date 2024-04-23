
import 'package:koti/functionalities/plain_switch_functionality/view/plain_switch_functionality_view.dart';

import '../../devices/shelly/shelly_device.dart';
import '../../devices/shelly_timer_switch/shelly_timer_switch.dart';
import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class PlainSwitchFunctionality extends Functionality {

  late ShellyTimerSwitch shellyTimerSwitch;
  bool _on = false;

  PlainSwitchFunctionality();

  @override
  Future<void> init () async {
    shellyTimerSwitch = device as ShellyTimerSwitch;
    _on = await shellyTimerSwitch.powerOutputOn(0);
  }

  bool switchToggle() {
    _on = ! _on;
    shellyTimerSwitch.setSwitchOn(0, _on);
    return _on;
  }

  void setToggle(bool toggle) {
    _on = toggle;
    shellyTimerSwitch.setSwitchOn(0, _on);
  }

  bool switchStatus() {
    return _on;
  }


  @override
  FunctionalityView myView() {
    return PlainSwitchFunctionalityView(this);
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  PlainSwitchFunctionality.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
  }


}