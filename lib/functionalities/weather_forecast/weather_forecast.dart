
import 'package:koti/functionalities/weather_forecast/view/weather_forecast_view.dart';

import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class WeatherForecast extends Functionality {


  late Function _getCurrentTemperatureFunction = _noTemperature;

  WeatherForecast() {
    allFunctionalities.addFunctionality(this);
  }

  double _noTemperature() {
    return -99.9;
  }

  @override
  Future<void> init () async {
    _getCurrentTemperatureFunction = device.temperatureFunction;
  }

  String currentTemperature() {
    return _getCurrentTemperatureFunction().toStringAsFixed(1);
  }

  @override
  FunctionalityView myView() {
    return WeatherForecastView(this);
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  WeatherForecast.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
  }


}