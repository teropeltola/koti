
import 'package:koti/functionalities/plain_switch_functionality/view/plain_switch_functionality_view.dart';

import '../../devices/shelly/shelly.dart';
import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class PlainSwitchFunctionality extends Functionality {

  late ShellyDevice shellyDevice;
  bool _on = false;

  PlainSwitchFunctionality();

  @override
  Future<void> init () async {
    shellyDevice = device as ShellyDevice;
    _on = await shellyDevice.powerOutputOn();
  }

  bool switchToggle() {
    _on = ! _on;
    shellyDevice.setSwitchOn(_on);
    return _on;
  }

  void setToggle(bool toggle) {
    _on = toggle;
    shellyDevice.setSwitchOn(_on);
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