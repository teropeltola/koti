import 'package:flutter/material.dart';
import 'package:koti/functionalities/boiler_heating/view/boiler_heating_functionality_view.dart';
import 'package:koti/functionalities/functionality/functionality.dart';

import '../../../look_and_feel.dart';
import '../../air_heat_pump_functionality/view/air_heat_pump_view.dart';
import '../../electricity_price/view/electricity_price_view.dart';
import '../../heating_system_functionality/view/heating_system_view.dart';
import '../../plain_switch_functionality/view/plain_switch_functionality_view.dart';
import '../../vehicle_charging/view/vehicle_charging_view.dart';
import '../../weather_forecast/view/weather_forecast_view.dart';

class FunctionalityView {

  late Functionality _myFunctionality;

  FunctionalityView();

  void setFunctionality(Functionality functionality) {
    _myFunctionality = functionality;
  }

  Functionality myFunctionality() {
    return _myFunctionality;
  }

  ButtonStyle buttonStyle (Color backgroundColor, Color foregroundColor) {
    return   ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        )
    );
  }

  Widget gridBlock(BuildContext context, Function callback) {
    return emptyWidget();
  }

  Widget shortOperationModeText() {
    Functionality functionality = myFunctionality();
    if (functionality.operationModes.showCurrent())  {
      return Container(
        padding: const EdgeInsets.all(3.0), // Adjust padding as needed
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white, // Border color
            width: 1.0, // Border width
          ),
          borderRadius: BorderRadius.circular(5.0), // Rounded corners
        ),
        child: Text(
          functionality.operationModes.currentModeName(),
          style: const TextStyle(
            fontSize: 10.0, // Adjust font size as needed
            fontWeight: FontWeight.normal, // Adjust font weight as needed
            //color: Colors.black, // Text color
          ),
        ),
      );
    }
    else {
      return emptyWidget();
    }
  }

  Future<void> setParameters(Map<String, dynamic> parameters) async {

  }

  void fromJson(Map<String, dynamic> json){
    //myFunctionalityId = json['myFunctionalityId'] ?? '';
  }


  FunctionalityView.fromJson(Map<String, dynamic> json){
    fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json['type'] = runtimeType.toString();
    //json['myFunctionalityId'] = myFunctionalityId;
    return json;
  }

  String viewName() {
    return 'puuttuva toimintonäyttö';
  }

  String subtitle() {
    return '';
  }

}



FunctionalityView extendedFunctionalityViewFromJson(Map<String, dynamic> json) {
  switch (json['type'] ?? '') {
    case 'FunctionalityView': return FunctionalityView.fromJson(json);
    case 'HeatingSystemView': return HeatingSystemView.fromJson(json);
    case 'PlainSwitchFunctionalityView': return PlainSwitchFunctionalityView.fromJson(json);
    case 'VehicleChargingView': return VehicleChargingView.fromJson(json);
    case 'WeatherForecastView': return WeatherForecastView.fromJson(json);
    case 'ElectricityGridBlock': return ElectricityGridBlock.fromJson(json);
    case 'AirHeatPumpView': return AirHeatPumpView.fromJson(json);
    case 'BoilerHeatingFunctionalityView': return BoilerHeatingFunctionalityView.fromJson(json);
  }
  log.error('unknown FunctionalityView jsonObject: ${json['type'] ?? '- not found at all-'}');
  return FunctionalityView();
}

