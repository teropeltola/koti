
import 'package:koti/functionalities/heating_system_functionality/view/heating_system_view.dart';
import '../../devices/ouman/ouman_device.dart';
import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class HeatingSystem extends Functionality {

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
    return json;
  }

  @override
  HeatingSystem.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
  }

}

HeatingSystem createNewHeatingSystem(OumanDevice ouman) {

  HeatingSystem heatingSystem = HeatingSystem();
  allFunctionalities.addFunctionality(heatingSystem);
  heatingSystem.pair(ouman);

  return heatingSystem;
}
