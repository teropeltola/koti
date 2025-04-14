import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import '../devices/device/device.dart';
import '../devices/wifi/wifi.dart';
import '../functionalities/electricity_price/electricity_price.dart';
import '../functionalities/functionality/functionality.dart';
import '../interfaces/estate_data_storage.dart';
import '../logic/state_broker.dart';
import '../operation_modes/operation_modes.dart';
import '../look_and_feel.dart';
import 'environment.dart';

const String estateOperationParameterSettingFunction = 'estateParameterSetting';

class Estate extends Environment {

  List <Device> devices = [];

  StateBroker stateBroker = StateBroker();

  Estate();

  Estate.undefined() {
    name = '#undefined#';
    id = '#undefined';
  }

  String get myWifi => myWifiDevice().name;
//  set myWifi(String newName) { this.myWifiDevice().name = newName; }

  bool get myWifiIsActive => myWifiDevice().iAmActive.value;

  bool reactiveWifiIsActive(BuildContext context) {
    return myWifiDevice().iAmActive.reactiveValue(context);
  }

  Wifi myWifiDevice() {
    for (var device in devices) {
      if (device.runtimeType == Wifi) {
        return device as Wifi;
      }
    }
    log.error('Estate $name myWifiDevice is not found');
    Wifi failedWifi = Wifi();
    failedWifi.setFailed();
    return failedWifi;
  }


  void init(String initName, String initMyWifi) {
    name = initName;
    Wifi newWifiDevice = Wifi();
    addDevice(newWifiDevice);
    newWifiDevice.initWifi(initMyWifi);
    initOperationModes();
  }

  Estate clone() {
    Estate newEstate = Estate.fromJson(toJson());
    newEstate.initOperationModes();

    return newEstate;
  }

  void updateDeviceData() {
    for (var d in devices) {
      d.myEstateId = id;
    }
  }
  // note: this is called both with and without waiting
  Future<bool> initDevicesAndFunctionalities() async {

    // first non waiting activities
    updateDeviceData();
    connectFunctionalitiesToDevices();

    for (var d in devices) {
      await d.init();
    }
    await initFunctionalities();
    return true;
  }

  ElectricityPrice myDefaultElectricityPrice() {
    for (var functionality in features) {
      if (functionality is ElectricityPrice) {
        return functionality;
      }
    }
    log.error ('Estate myDefaultElectricityPrice: no ElectricityPrice functionality found!');
    return ElectricityPrice();
  }


  Device myDeviceFromName(String deviceName) {
    int deviceIndex = devices.indexWhere((device) => device.name == deviceName);
    if (deviceIndex < 0) {
      return noDevice;
    }
    else {
      return devices[deviceIndex];
    }
  }

  void addDevice(Device newDevice) {
    newDevice.myEstateId = id;

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

  void removeDevice(String deviceId) {
    devices.removeWhere((e) => e.id == deviceId);
    // todo: pitäiskö poistaa myös device linkki?
  }

  @override
  void removeData(){

    for (var d in devices) {
      d.remove();
    }

    super.removeData();
  }

  Device findDeviceWithService({required String deviceService}) {
    for (var device in devices) {
      if (device.services.offerService(deviceService)) {
        return device;
      }
    }
    return noDevice;
  }

  List<String> findPossibleDevices({required String deviceService}) {
    List<String> list = [];
    for (var device in devices) {
      if (device.services.offerService(deviceService)) {
        list.add(device.name);
      }
    }
    return list;
  }

  bool hasDeviceOfType(Type type) {
    for (var device in devices) {
      if (device.runtimeType == type) {
        return true;
      }
    }
    return false;
  }

  Widget dumpData({required Function formatterWidget}) {
    return
      formatterWidget(
        headline: name,
        textLines: [
          'Id: $id',
          'Wifi: $myWifi',
        ],
        widgets: [
          operationModes.dumpData(formatterWidget: formatterWidget),
          formatterWidget(
            headline: 'Laitteet',
            textLines: [
                'Laitteiden lukumäärä: ${devices.length}'
            ],
            widgets: [
                for (var device in devices)
                  device.dumpData(formatterWidget: formatterWidget),
            ]
          ) as Widget,
          formatterWidget(
              headline: 'Toiminnot',
              textLines: [
                'Toimintojen lukumäärä: ${features.length}'
              ],
              widgets: [
                for (var functionality in features)
                  functionality.dumpData(formatterWidget: formatterWidget),
              ]
          ) as Widget,
          stateBroker.dumpData(formatterWidget: formatterWidget)
        ]
      );
  }

  Estate.fromJson(Map<String, dynamic> json)  {
    name = json['name'] ?? '';
    id = json['id'] ?? '';

    // note: not used super.json because devices need to be initialized first

    devices = List.from(json['devices']).map((e)=>extendedDeviceFromJson(e)).toList();

    for (var e in json['subEnvironments'] ?? [] ) {
      environments.add(Environment.fromJson(e));
      environments.last.parentEnvironment = this;
    }

    features = List.from(json['features']).map((e)=>extendedFunctionalityFromJson(e)).toList();
    for (var f in features) {
      addView(f.myView);
    }
    operationModes = OperationModes.fromJson(json['operationModes'] ?? {});

  }

  Map<String, dynamic> toJson() {

    var json = super.toJson();
    json['devices'] = devices.map((e)=>e.toJson()).toList();
    return json;
  }

}



class Estates {
  List <Estate> estates = [];
  final EstateDataStorage _estateDataStorage =  EstateDataStorage();
  int currentIndex = -1;
  final Estate noEstates = Estate.undefined();

  Estates();

  Estate currentEstate () => _candidateActive ? candidateEstate() : ((currentIndex >= 0) && (currentIndex < nbrOfEstates()))
                                ? estates [currentIndex]
                                : noEstates;

  int nbrOfEstates() => estates.length;

  Estate _candidateEstate = Estate();
  bool _candidateActive = false;

  Estate candidateEstate() {
    return _candidateEstate;
  }

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
    currentIndex = -1;
  }

  void addEstate(Estate newLocation) {
    estates.add(newLocation);
  }

  void removeEstate(String estateId) {
    int index = estates.indexWhere((e) => e.id == estateId);
    if (index >= 0) {
      estates[index].dispose();
      estates.removeWhere((e) => e.id == estateId);

      if (estates.isEmpty) {
        currentIndex = -1;
      }
      else if (index <= currentIndex) {
        currentIndex--;
      }
    }
  }

  void setCurrentIndex(int estateIndex) {
    currentIndex = estateIndex;
  }

  void setCurrent(String estateId) {
    currentIndex = estates.indexWhere((e) => e.id == estateId);
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
    for (var e in estates) {
      for (var d in e.devices) {
        d.myEstateId = e.id;
        await d.init();
      }
      e.connectFunctionalitiesToDevices();
      await e.initFunctionalities();
      e.initOperationModes();
    }
  }

  Future <void> load() async {
    clearDataStructures();
    try {
      var estateData = _estateDataStorage.readObservationData();
      var json = jsonDecode(estateData);
      loadFromJson(json);
      await activateDataStructure();
    }
    catch (e, st) {
      log.handle(e, st, 'exception in loading estate file');
      clearDataStructures();
    }
  }

  Future <void> store() async {
    try {
      var json = jsonEncode(this);
      await _estateDataStorage.storeEstateFile(json);
    }
    catch (e, st) {
      log.error('json exception in store', e, st);
    }

  }

  void loadFromJson(Map<String, dynamic> json){
    _executeFromJson(json);
  }

  Estates.fromJson(Map<String, dynamic> json){
    _executeFromJson(json);
  }

  void _executeFromJson(Map<String, dynamic> json){
    estates = List.from(json['estates']).map((e)=>Estate.fromJson(e)).toList();
    int storedIndex = json['currentIndex'] ?? -1;
    if (estates.isEmpty) {
      currentIndex = -1;
    } else if (storedIndex < estates.length) {
      currentIndex = storedIndex;
    }
    else {
      currentIndex = 0;
    }
  }

  Map<String, dynamic> toJson() {

    final json = <String, dynamic>{};

    json['estates'] = estates.map((e)=>e.toJson()).toList();
    json['currentIndex'] = currentIndex;

    return json;
  }

  Future<void> resetAll() async {
    _estateDataStorage.delete();
    clearDataStructures();
  }

  int noEstateIndex() {
    return -1;
  }

  Estate cloneCandidate(String clonedEstateName) {
    int index = _findFromExistingEstates(clonedEstateName);
    if (index >= 0) {
      _candidateEstate = estates[index].clone();
    }
    else {
      log.error('Estate $clonedEstateName cloneCandidate failed');
    }
    _candidateActive = true;
    return _candidateEstate;
  }

  void replaceEstateWithCandidate(String oldName) {
    int index = _findFromExistingEstates(oldName);
    if (index >= 0) {
      // estate with old name found
      estates[index].removeData();
      estates[index] = _candidateEstate;
    }
    else {
      // this is a new estate
      estates.add(_candidateEstate);
    }
    // set new object for the next possible candidate
    _candidateEstate = Estate();
    _candidateActive = false;
  }

  void activateCandidate() {
    _candidateActive = true;
  }

  void deactivateCandidate() {
    _candidateActive = false;
  }

  Estate estate(String name) {
    if (name == _candidateEstate.name) {
      return _candidateEstate;
    }
    int index = _findFromExistingEstates(name);
    if (index >= 0) {
      return estates[index];
    }
    return noEstates;
  }

  int _findFromExistingEstates (String name) {
    for (int index = 0; index <estates.length; index++) {
      if (estates[index].name == name) {
        return index;
      }
    }
    return -1;
  }

  Estate estateFromId (String id) {
    if ((_candidateActive) && (id == _candidateEstate.id)) {
      return _candidateEstate;
    }
    for (int index = 0; index <estates.length; index++) {
      if (estates[index].id == id) {
        return estates[index];
      }
    }
    return noEstates;
  }

  Environment environmentFromId (String id) {
    if (_candidateActive) {
      Environment e = _candidateEstate.findEnvironmentId(id);
      if (e != noEnvironment) {
        return e;
      }
    }
    for (var estate in estates) {
      Environment e = estate.findEnvironmentId(id);
      if (e != noEnvironment) {
        return e;
      }
    }
    return noEnvironment;
  }

}

Estates myEstates = Estates();


