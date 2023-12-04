
import 'package:koti/functionalities/weather_forecast/view/weather_forecast_view.dart';

import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class WeatherForecast extends Functionality {

  WeatherForecast() {
    _getCurrentTemperatureFunction = _noTemperature;
  }

  late Function _getCurrentTemperatureFunction;

  String _noTemperature() {
    return '-';
  }

  void init (Function getCurrentTemperature) async {
    _getCurrentTemperatureFunction = getCurrentTemperature;
  }

  String currentTemperature() {
    return _getCurrentTemperatureFunction().toStringAsFixed(1);
  }

  @override
  FunctionalityView myView() {
    return WeatherForecastView(this);
  }

}