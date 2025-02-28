import 'package:flutter/material.dart';
import 'package:koti/functionalities/weather_forecast/view/edit_weather_forecast_view.dart';

import 'package:koti/functionalities/weather_forecast/view/weather_forecast_view.dart';
import '../../devices/device/device.dart';
import '../../estate/estate.dart';
import '../../look_and_feel.dart';
import '../functionality/functionality.dart';

double _noTemperature() {
  return noValueDouble;
}

class WeatherForecast extends Functionality {

  static const String functionalityName = 'Sääennuste';

  String locationName = '';


  WeatherForecast() {
    myView = WeatherForecastView();
    myView.setFunctionality(this);
  }

  @override
  Future<void> init () async {
  }

  String currentTemperature() {
    double temp = myEstates.currentEstate().stateBroker.getDoubleValue('Ulkolämpötila');
    if (temp == noValueDouble) {
      return '??';
    }
    else {
      return temp.toStringAsFixed(1);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['locationName'] = locationName;
    return json;
  }

  @override
  WeatherForecast.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    myView = WeatherForecastView();
    myView.setFunctionality(this);
    locationName = json['locationName'] ?? '';
  }

  @override
  Future<bool> editWidget(BuildContext context, bool createNew, Estate estate, Functionality functionality, Device device) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return EditWeatherForecastView(
                estate: estate,
                originalWeatherForecast: functionality as WeatherForecast,
                callback: () {}
            );
          },
        )
    );
  }

  WeatherForecast clone() {
    return WeatherForecast.fromJson(toJson());
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
      headline: functionalityName,
      textLines: [
          'tunnus: $id',
          'paikka: $locationName',
      ],
      widgets: [
        dumpDataMyDevices(formatterWidget: formatterWidget)
      ]
    );
  }
  @override
  Future<bool> Function(BuildContext context, Estate estate, Functionality functionality, Function callback)  myEditingFunction() {
    return editWeatherForecastFunctionality;
  }
}


Future<bool> editWeatherForecastFunctionality(BuildContext context, Estate estate, Functionality functionality, Function callback) async {
  bool success = await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return EditWeatherForecastView(
            estate: estate,
            originalWeatherForecast: functionality as WeatherForecast,
            callback: callback
        );
      }));
  return success;
}
