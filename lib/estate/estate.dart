import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../devices/device/device.dart';
import '../devices/wifi/wifi.dart';
import '../devices/wlan/active_wifi_name.dart';
import '../functionalities/functionality/functionality.dart';
import '../functionalities/functionality/view/functionality_view.dart';
import '../interfaces/estate_data_storage.dart';
import '../look_and_feel.dart';

class Estate extends ChangeNotifier {
  String name = '';
  String id = '';
  late Wifi myWifiDevice = Wifi();

  List <Device> devices = [];
  List <Functionality> features = [];
  List <FunctionalityView> views = [];

  Estate() {
  }

  String get myWifi => myWifiDevice.name;
  set myWifi(String newName) { this.myWifiDevice.name = newName; }

  bool get myWifiIsActive => myWifiDevice.iAmActive;

  void init(String initName, String initId, String initMyWifi) {
    name = initName;
    id = initId;
    myWifiDevice = Wifi();
    devices.add(myWifiDevice);
    myWifiDevice.initWifi(initMyWifi);
  }

  void addDevice(Device newDevice) {
    newDevice.myEstate = this;

    if ( !deviceExists(newDevice.id)) {
      devices.add(newDevice);
    }
  }

  bool deviceExists(String deviceId) {
    for (int i = 0; i < devices.length; i++) {
      if (devices[i].id == deviceId) {
        return true;
      }
    }
    return false;
  }

  void addFunctionality(Functionality newFunctionality) {

    allFunctionalities.addFunctionality(newFunctionality);
    features.add(newFunctionality);
  }

  void removeDevice(String deviceId) {
    devices.removeWhere((e) => e.id == deviceId);
  }

  void addView(FunctionalityView newFunctionality) {
    views.add(newFunctionality);
  }

  void setViews() {
    views.clear();
    // views.add()
  }

  Estate.fromJson(Map<String, dynamic> json){
    name = json['name'] ?? '';
    id = json['id'] ?? '';

    myWifiDevice = Wifi();
    devices.add(myWifiDevice);
    myWifiDevice.initWifi(json['myWifi'] ?? '');

    devices = List.from(json['devices']).map((e)=>extendedDeviceFromJson(e)).toList();
    features = List.from(json['features']).map((e)=>extendedFunctionalityFromJson(e)).toList();
    views = List.from(json['views']).map((e)=>extendedFunctionalityViewFromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {


    final json = <String, dynamic>{};

    json['name'] = name;
    json['id'] = id;
    json['myWifi'] = myWifi;
    json['devices'] = devices.map((e)=>e.toJson()).toList();
    json['features'] = features.map((e)=>e.toJson()).toList();
    json['views'] = views.map((e)=>e.toJson()).toList();

    return json;
  }
}

Estate noEstates = Estate();

class Estates {
  List <Estate> estates = [];
  List <Estate> currentStack = [Estate()];
  final EstateDataStorage _estateDataStorage =  EstateDataStorage();

  Estates();

  Estate currentEstate () => (nbrOfEstates() > 0)
                                ? currentStack.last
                                : noEstates;

  int nbrOfEstates() => estates.length;


  Future<void> init() async {
    await _estateDataStorage.init('estates.json');

    if (_estateDataStorage.estateFileExists()) {
      await load();
    }
    else {
      await store();
    }

  }

  void clearDataStructures() {
    estates.clear();
    currentStack = [Estate()];
  }


  void addEstate(Estate newLocation) {
    estates.add(newLocation);
  }

  void removeEstate(String estateId) {
    int index = estates.indexWhere((e) => e.id == estateId);
    if (index >= 0) {
      estates[index].dispose();
      estates.removeWhere((e) => e.id == estateId);
    }

    currentStack.removeWhere((e) => e.id == estateId);
  }

  void pushCurrent(Estate newCurrent) {
    currentStack.add(newCurrent);
  }

  void popCurrent() {
    if (currentStack.length > 1) {
      currentStack.removeLast();
    }
  }

  bool validEstateName(String newName) {
    return (newName.isNotEmpty);
  }

  bool estateNameExists(String newName) {
   for (int i=0; i<estates.length; i++) {
      if (newName == estates[i].name) {
        return true;
      }
    }
    return false;
  }

  bool validWifiName(String newName) {
    return (newName.isNotEmpty);
  }

  bool wifiNameExists(String newName) {
    for (int i=0; i<estates.length; i++) {
      if (newName == estates[i].myWifi) {
        return true;
      }
    }
    return false;
  }

  Future<void> activateDataStructure() async {
    for (int i=0; i<estates.length; i++) {
      for (int j=0; j<estates[i].devices.length; j++) {
        estates[i].devices[j].myEstate = estates[i];
        await estates[i].devices[j].init();
      }
      for (int k=0; k<estates[i].features.length; k++) {
        await estates[i].features[k].init();
      }
    }
  }

  Future <void> load() async {
    clearDataStructures();
    try {
      var estateData = _estateDataStorage.readObservationData();
      fromJson(jsonDecode(estateData));
      await activateDataStructure();
    }
    catch (e, st) {
      log.handle(e, st, 'exception in loading estate file');
      clearDataStructures();
    }
  }

  Future <void> store() async {
    await _estateDataStorage.storeEstateFile(jsonEncode(this));
  }

  void fromJson(Map<String, dynamic> json){
    estates = List.from(json['estates']).map((e)=>Estate.fromJson(e)).toList();
    estates.forEach((e){currentStack.add(e);});
  }

  Estates.fromJson(Map<String, dynamic> json){
    estates = List.from(json['estates']).map((e)=>Estate.fromJson(e)).toList();
    estates.forEach((e){currentStack.add(e);});
  }

  Map<String, dynamic> toJson() {

    final json = <String, dynamic>{};

    json['estates'] = estates.map((e)=>e.toJson()).toList();

    return json;
  }

  Future<void> resetAll() async {
    _estateDataStorage.delete();
    clearDataStructures();
  }
}

