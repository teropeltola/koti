
import 'package:koti/functionalities/boiler_heating/view/boiler_heating_functionality_view.dart';
import '../../devices/shelly_pro2/shelly_pro2.dart';
import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class BoilerHeatingFunctionality extends Functionality {

  late ShellyPro2 shellyPro2;

  BoilerHeatingFunctionality();

  @override
  Future<void> init () async {
    shellyPro2 = device as ShellyPro2;
  }


  @override
  FunctionalityView myView() {
    return BoilerHeatingFunctionalityView(this);
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  BoilerHeatingFunctionality.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
  }


}