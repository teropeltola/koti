
import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';
import 'package:koti/functionalities/heating_system_functionality/view/heating_system_view.dart';
import '../../devices/device/device.dart';
import '../../devices/ouman/ouman_device.dart';
import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class HeatingSystem extends Functionality {

  MitsuHeatPumpDevice myAirPump = MitsuHeatPumpDevice();

  HeatingSystem() {
  }

  @override
  Future<void> init () async {
  }


  OumanDevice myOuman() {
    return device as OumanDevice;
  }

  @override
  FunctionalityView myView() {
    return HeatingSystemView(this);
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['myAirPump'] = myAirPump.id;
    return json;
  }

  @override
  HeatingSystem.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    myAirPump = findDevice(json['myAirPump'] ?? '') as MitsuHeatPumpDevice;
  }

}

HeatingSystem createNewHeatingSystem(OumanDevice ouman, MitsuHeatPumpDevice mitsu) {

  HeatingSystem heatingSystem = HeatingSystem();
  allFunctionalities.addFunctionality(heatingSystem);
  heatingSystem.pair(ouman);
  heatingSystem.myAirPump = mitsu;

  return heatingSystem;
}
