import 'package:flutter/material.dart';
import '../../logic/unique_id.dart';
import '../network_device/network_device.dart';

class WeatherServiceProvider extends NetworkDevice {

  String _titleText = '';
  String _locationName = '';

  String get locationName => _locationName;


  WeatherServiceProvider(String webPage, String title, String locationName) {
    id = UniqueId('W').get();
    _titleText = title;
    internetPage = webPage;
    _locationName = locationName;
  }

  String weatherPage() {
    return internetPage;
  }

  String title() {
    return _titleText;
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: name,
        textLines: [
          'tunnus: $id',
          'otsikko: $_titleText',
          'paikka: $locationName',
          'osoite: $internetPage',
        ],
        widgets: [
          dumpDataMyFunctionalities(formatterWidget: formatterWidget),
        ]
    );
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['title'] = _titleText;
    json['locationName'] = _locationName;
    return json;
  }

  @override
  WeatherServiceProvider.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    _titleText = json['title'] ?? '';
    _locationName = json['locationName'] ?? '';
  }
}