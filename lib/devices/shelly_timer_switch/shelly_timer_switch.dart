import 'package:flutter/material.dart';

import '../../estate/estate.dart';
import '../../functionalities/functionality/functionality.dart';
import '../device/device.dart';
import '../device/view/edit_device_view.dart';
import '../shelly/shelly.dart';

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
  Future<void> editWidget(BuildContext context, Estate estate, Functionality functionality, Device device) async {
    await Navigator.push(
        context, MaterialPageRoute(
      builder: (context) {
        return EditDeviceView(
            estate: estate,
            functionality: functionality,
            device: device);
      },
    ));
  }

  @override
  ShellyTimerSwitch.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }

}