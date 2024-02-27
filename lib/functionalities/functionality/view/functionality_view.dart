import 'package:flutter/material.dart';
import 'package:koti/functionalities/functionality/functionality.dart';

import '../../../look_and_feel.dart';
import '../../electricity_price/view/electricity_price_view.dart';
import '../../heating_system_functionality/view/heating_system_view.dart';
import '../../plain_switch_functionality/view/plain_switch_functionality_view.dart';
import '../../tesla_functionality/view/tesla_functionality_view.dart';
import '../../weather_forecast/view/weather_forecast_view.dart';

class FunctionalityView {

  dynamic myFunctionality;

  FunctionalityView(this.myFunctionality);

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

  void fromJson(Map<String, dynamic> json){
    myFunctionality = allFunctionalities.findFunctionality(json['myFunctionalityId'] ?? '');
  }


  FunctionalityView.fromJson(Map<String, dynamic> json){
    fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json['type'] = runtimeType.toString();
    json['myFunctionalityId'] = myFunctionality.id();
    return json;
  }
}

FunctionalityView extendedFunctionalityViewFromJson(Map<String, dynamic> json) {
  switch (json['type'] ?? '') {
    case 'FunctionalityView': return FunctionalityView.fromJson(json);
    case 'HeatingSystemView': return HeatingSystemView.fromJson(json);
    case 'PlainSwitchFunctionalityView': return PlainSwitchFunctionalityView.fromJson(json);
    case 'TeslaFunctionalityView': return TeslaFunctionalityView.fromJson(json);
    case 'WeatherForecastView': return WeatherForecastView.fromJson(json);
    case 'ElectricityGridBlock': return ElectricityGridBlock.fromJson(json);
  }
  log.error('unknown FunctionalityVoew jsonObject: ${json['type'] ?? '- not found at all-'}');
  return FunctionalityView(allFunctionalities.noFunctionality());
}

