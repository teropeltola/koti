import 'package:flutter/material.dart';
import 'package:koti/functionalities/boiler_heating/boiler_heating_functionality.dart';

import 'package:koti/functionalities/functionality/view/functionality_view.dart';
import 'package:koti/functionalities/heating_system_functionality/heating_system.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';
import 'package:koti/functionalities/vehicle_charging/vehicle_charging.dart';
import 'package:koti/functionalities/weather_forecast/weather_forecast.dart';

import '../../devices/device/device.dart';
import '../../estate/estate.dart';
import '../../operation_modes/operation_modes.dart';
import '../../logic/unique_id.dart';
import '../../look_and_feel.dart';
import '../air_heat_pump_functionality/air_heat_pump.dart';
import '../electricity_price/electricity_price.dart';
import '../general_agent/general_agent.dart';
import '../radiator_water_circulation/radiator_water_circulation.dart';

const String _functionalityFailure = 'functionalityFailure';

FunctionalityList allFunctionalities = FunctionalityList();

class FunctionalityList {
  List<Functionality> _fl = [];

  FunctionalityList() {
    Functionality empty = Functionality.empty();
    empty._id.set('#noFunctionality#');
    _fl.add(empty);
  }

  Functionality noFunctionality() {
    return _fl[0];
  }

  void remove(Functionality functionality) {
    _fl.remove(functionality);
  }

  FunctionalitnewFunctionality() {
    Functionality functionality = Functionality();
    _fl.add(functionality);
    return functionality;
  }

  void addFunctionality(Functionality newFunctionality) {

      _fl.add(newFunctionality);
  }

  void removeFunctionality(Functionality functionality) {
    int index = findFunctionalityIndex(functionality.id);
    if (index >= 0) {
      _fl.removeAt(index);
    }
    else {
      log.error('allFunctionalities.removeFunctionality "${functionality.runtimeType.toString()}/${functionality.id} failed');
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
      if (id == _fl[i].id) {
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

  // excluding noFunctionality
  int nbrOfFunctionalities() {
    return _fl.length - 1;
  }

  void clear() {
    _fl.clear();
  }
}


class Functionality {
  List<Device> connectedDevices = [];
  late UniqueId _id;
  static const String functionalityName = 'toiminnon nimi';
  late FunctionalityView myView;

  String get id => _id.get();

  OperationModes operationModes = OperationModes();

  Functionality() {
    _id = UniqueId('f');
    myView = FunctionalityView();
    myView.setFunctionality(this);
  }

  Functionality.withParameters(Device devicePar, UniqueId idPar) {
    connectedDevices.add(devicePar);
    _id = idPar;
    myView = FunctionalityView();
    myView.setFunctionality(this);
  }

  Functionality.empty() {
    connectedDevices.clear();
    _id = UniqueId.fromString('f#');
    myView = FunctionalityView();
    myView.setFunctionality(this);
  }

  Functionality.failed() {
    setFailed();
    myView = FunctionalityView();
    myView.setFunctionality(this);
  }

  void setFailed() {
    _id = UniqueId.fromString(_functionalityFailure);
  }

  bool notExist() {
    return _id.get() == _functionalityFailure;
  }

  bool creationSuccessful() {
    return _id.get() != _functionalityFailure;
  }


  void pair(Device newDevice) {
    connectedDevices.add(newDevice);
    newDevice.connectedFunctionalities.add(this);
  }

  void unPair(Device device) {
    device.connectedFunctionalities.remove(this);
    connectedDevices.remove(device);
  }

  void unPairAll() {
    for (int index = connectedDevices.length-1; index >= 0; index--) {
      unPair(connectedDevices[index]);
    }
  }

  void addPredefinedOperationMode(String modeName, String serviceName, bool value) {
    BoolServiceOperationMode boolServiceOperationMode = BoolServiceOperationMode();
    boolServiceOperationMode.name = modeName;
    boolServiceOperationMode.preDefined = true;
    boolServiceOperationMode.serviceName = serviceName;
    boolServiceOperationMode.value = value;
    operationModes.add(boolServiceOperationMode);
  }

  Future<void> init () async {
  }

  Future<bool> editWidget(BuildContext context, bool createNew, Estate estate, Functionality functionality, Device device) async {
    return await device.editWidget(context, estate);
  }

  // returns a function for functionality editing. Each inherited class should implement their own version of this
  Future<bool> Function(BuildContext context, Estate estate, Functionality functionality, Function callback)  myEditingFunction() {
    return editFunctionality;
  }

  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: id,
        textLines: [
          'tyyppiä ei määritelty',
        ],
        widgets: List<Widget>.empty(growable:true)
    );
  }

  //
  List <String> _connectedDeviceNames() {
    if (connectedDevices.isEmpty) {
      return ['-'];
    }
    else {
      return [
        for (var device in connectedDevices)
          device.name,
      ];
    }
  }

  // this function is used by the inherited classes for creating dumpData about
  // connected devices
  Widget dumpDataMyDevices({required Function formatterWidget}) {
    return formatterWidget(
        headline: 'liitetyt laitteet',
        textLines:
        _connectedDeviceNames(),
        widgets: List<Widget>.empty(growable: true)
    ) as Widget;
  }

  Device connectedDeviceOf(String typeName) {
    for (var device in connectedDevices) {
      if (device.runtimeType.toString() == typeName) {
        return device;
      }
    }
    log.error('connectedDeviceOf($typeName) not found');
    Device emptyDevice = deviceFromTypeName(typeName);
    emptyDevice.setFailed();
    return emptyDevice;
  }

  void remove() {
    unPairAll();
    connectedDevices.clear();
    operationModes.clear();
    allFunctionalities.remove(this);
  }

  void fromJson(Map<String, dynamic> json){
    List <String> connectedDeviceIds = List.from(json['connectedDeviceIds'] ?? []);
    for (var deviceId in connectedDeviceIds) {
      Device device = allDevices.findDevice(deviceId);
      if (device != noDevice) {
        connectedDevices.add(device);
      }
      else {
        log.error('Functionality connectedDevice id "$deviceId" is missing in functionality "$id"');
      }
    }
    operationModes = OperationModes.fromJson(json['operationModes'] ?? {});
  }

  Functionality.fromJson(Map<String, dynamic> json){
    _id = UniqueId.fromString(json['id'] ?? '');
    myView = FunctionalityView();
    myView.setFunctionality(this);
    fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['type'] = runtimeType.toString();
    json['id'] = _id.get();
    json['connectedDeviceIds'] = connectedDevices.map((device)=>device.id).toList();
    json['operationModes'] = operationModes.toJson();

    return json;
  }

}

Functionality extendedFunctionalityFromJson( Map<String, dynamic> json) {
  String myId = json['id'] ?? '';
  String myType = json['type'] ?? '';

  /*
    Functionality myFunctionality = allFunctionalities.findFunctionality(myId);

  if (myFunctionality == allFunctionalities.noFunctionality()) {
*/
  late Functionality myFunctionality;

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
      case 'VehicleCharging':
        myFunctionality = VehicleCharging.fromJson(json);
        break;
      case 'WeatherForecast':
        myFunctionality = WeatherForecast.fromJson(json);
        break;
      case 'AirHeatPump':
        myFunctionality = AirHeatPump.fromJson(json);
        break;
      case 'BoilerHeatingFunctionality':
        myFunctionality = BoilerHeatingFunctionality.fromJson(json);
        break;
      case 'RadiatorWaterCirculation':
        myFunctionality = RadiatorWaterCirculation.fromJson(json);
        break;
      case 'GeneralAgent':
        myFunctionality = GeneralAgent.fromJson(json);
        break;
      default:
        log.error('unknown functionality jsonObject($myType) not implemented');
        return allFunctionalities.noFunctionality();
    }
    allFunctionalities.addFunctionality(myFunctionality);
/*
}
  else {
    String foundType = myFunctionality.runtimeType.toString();
    if (foundType != myType) {
      log.error('different functionality classes (${myFunctionality.runtimeType}/$myType) with the same id ($myId).');
    }
  }

 */

  return myFunctionality;
}


Future<bool> editFunctionality(BuildContext context, Estate estate, Functionality functionality, Function callback) async {
  log.error('editFunctionality not implemented in ${functionality.runtimeType.toString()}');
  return false;
}
