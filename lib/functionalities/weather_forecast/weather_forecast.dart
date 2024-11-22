import 'package:flutter/material.dart';
import 'package:koti/functionalities/weather_forecast/view/edit_weather_forecast_view.dart';

import 'package:koti/functionalities/weather_forecast/view/weather_forecast_view.dart';
import '../../devices/device/device.dart';
import '../../devices/weather_service_provider/weather_service_provider.dart';
import '../../estate/estate.dart';
import '../../look_and_feel.dart';
import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

double _noTemperature() {
  return -99.9;
}

class WeatherForecast extends Functionality {

  static const String functionalityName = 'Sääennuste';

  String locationName = '';

  List<WeatherServiceProvider> weatherServices = [];

  void updateWeatherServices() {
    weatherServices.clear();
    Estate estate = myEstates.estateFromId(connectedDevices[0].myEstateId);
    for (var dev in estate.devices) {
      if (dev is WeatherServiceProvider) {
        weatherServices.add(dev as WeatherServiceProvider);
      }
    }
  }

  WeatherForecast() {
  }


  @override
  Future<void> init () async {
    updateWeatherServices();
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
  FunctionalityView myView() {
    return WeatherForecastView(this);
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['locationName'] = locationName;
    return json;
  }

  @override
  WeatherForecast.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    locationName = json['locationName'] ?? '';
  }

  @override
  Future<bool> editWidget(BuildContext context, bool createNew, Estate estate, Functionality functionality, Device device) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return EditWeatherForecastView(
              createNew: createNew,
                estate: estate,
                originalWeatherForecast: functionality as WeatherForecast
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
          'paikka: ${locationName}',
      ],
      widgets: [
        dumpDataMyDevices(formatterWidget: formatterWidget)
      ]
    );
  }


}