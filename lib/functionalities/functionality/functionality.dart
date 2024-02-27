import 'package:flutter/material.dart';

import 'package:koti/functionalities/functionality/view/functionality_view.dart';
import 'package:koti/functionalities/heating_system_functionality/heating_system.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';
import 'package:koti/functionalities/tesla_functionality/tesla_functionality.dart';
import 'package:koti/functionalities/weather_forecast/weather_forecast.dart';

import '../../devices/device/device.dart';
import '../../estate/estate.dart';
import '../../logic/unique_id.dart';
import '../../look_and_feel.dart';
import '../electricity_price/electricity_price.dart';

FunctionalityList allFunctionalities = FunctionalityList();

class FunctionalityList {
  List<Functionality> _fl = [];

  FunctionalityList() {
    Functionality empty = Functionality.empty();
    _fl.add(empty);
  }

  Functionality noFunctionality() {
    return _fl[0];
  }

  Functionality newFunctionality() {
    Functionality functionality = Functionality();
    _fl.add(functionality);
    return functionality;
  }

  void addFunctionality(Functionality newFunctionality) {
    int index = findFunctionalityIndex(newFunctionality.id());
    if (index >= 0) {
      _fl[index] = newFunctionality;
    }
    else {
      _fl.add(newFunctionality);
    }
  }

  Functionality functionalityWithId(String id) {
    Functionality fun = findFunctionality(id);
    if (fun == noFunctionality()) {
      fun = Functionality.withParameters(noDevice, UniqueId.fromString(id));
      _fl.add(fun);
    }
    return fun;
  }

  int findFunctionalityIndex(String id) {
    for (int i = 0; i<_fl.length; i++) {
      if (id == _fl[i].id()) {
        return i;
      }
    }
    return -1;
  }

  Functionality findFunctionality(String id) {
    int index = findFunctionalityIndex(id);
    if (index >= 0) {
      return _fl[index];
    }
    return noFunctionality();
  }

  // including noFunctionality
  int nbrOfFunctionalities() {
    return _fl.length;
  }

  void clear() {
    _fl.clear();
  }
}


class Functionality {
  late Device device;
  late UniqueId _id;

  Functionality() {
    _id = UniqueId('f');
  }

  Functionality.withParameters(Device devicePar, UniqueId idPar) {
    device = devicePar;
    _id = idPar;
  }

  Functionality.empty() {
    device = noDevice;
    _id = UniqueId.fromString('f#');
  }

  void pair(Device newDevice) {
    device = newDevice;
    device.connectedFunctionalities.add(this);
  }

  Future<void> init () async {
  }

  Future<void> editWidget(BuildContext context, Estate estate, Functionality functionality, Device device) async {
    this.device.editWidget(context, estate, this, this.device);
  }

  FunctionalityView myView() {
    return FunctionalityView(this);
  }

  String id() {
    return _id.get();
  }


  void fromJson(Map<String, dynamic> json){
    device = findDevice(json['deviceId'] ?? '');
  }

  Functionality.fromJson(Map<String, dynamic> json){
    _id = UniqueId.fromString(json['id'] ?? '');
    fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['type'] = runtimeType.toString();
    json['id'] = _id.get();
    json['deviceId'] = device.id;

    return json;
  }

}

Functionality extendedFunctionalityFromJson(Map<String, dynamic> json) {
  String myId = json['id'] ?? '';
  Functionality myFunctionality = allFunctionalities.findFunctionality(myId);
  String myType = json['type'] ?? '';

  if (myFunctionality == allFunctionalities.noFunctionality()) {
    switch (myType) {
      case 'Functionality':
        myFunctionality = Functionality.fromJson(json);
        break;
      case 'HeatingSystem':
        myFunctionality = HeatingSystem.fromJson(json);
        break;
      case 'ElectricityPrice':
        myFunctionality = ElectricityPrice.fromJson(json);
        break;
      case 'PlainSwitchFunctionality':
        myFunctionality = PlainSwitchFunctionality.fromJson(json);
        break;
      case 'TeslaFunctionality':
        myFunctionality = TeslaFunctionality.fromJson(json);
        break;
      case 'WeatherForecast':
        myFunctionality = WeatherForecast.fromJson(json);
        break;
      default:
        log.error('unknown functionality jsonObject($myType) not implemented');
        return allFunctionalities.noFunctionality();
    }
    allFunctionalities.addFunctionality(myFunctionality);
  }
  else {
    String foundType = myFunctionality.runtimeType.toString();
    if (foundType != myType) {
      log.error('different functionality classes (${myFunctionality.runtimeType}/$myType) with the same id ($myId).');
    }
  }
  return myFunctionality;
}
