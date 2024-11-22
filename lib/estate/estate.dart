import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:koti/operation_modes/conditional_operation_modes.dart';
import 'package:koti/operation_modes/hierarcical_operation_mode.dart';

import '../devices/device/device.dart';
import '../devices/wifi/wifi.dart';
import '../functionalities/electricity_price/electricity_price.dart';
import '../functionalities/functionality/functionality.dart';
import '../functionalities/functionality/view/functionality_view.dart';
import '../interfaces/estate_data_storage.dart';
import '../logic/state_broker.dart';
import '../logic/unique_id.dart';
import '../operation_modes/operation_modes.dart';
import '../look_and_feel.dart';
import 'environment.dart';

const String estateOperationParameterSettingFunction = 'estateParameterSetting';

class Estate extends Environment {
  String id = '';

  // Environment env = Environment();

  List <Device> devices = [];
  List <Functionality> features = [];
  List <FunctionalityView> views = [];

  OperationModes operationModes = OperationModes();

  StateBroker stateBroker = StateBroker();

  Estate() {
    id = UniqueId('e').get();
  }

  Estate.undefined() {
    name = '#undefined#';
    id = '#undefined';
  }

  String get myWifi => myWifiDevice().name;
  set myWifi(String newName) { this.myWifiDevice().name = newName; }

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

  void initOperationModes() {
    operationModes.initModeStructure(
        estate: this,
        parameterSettingFunctionName: estateOperationParameterSettingFunction,
        deviceId: '',
        deviceAttributes: [],
        setFunction: _setOperationModeOn,
        getFunction: _getParameters);

    operationModes.addType(HierarchicalOperationMode().typeName());
    operationModes.addType(ConditionalOperationModes().typeName());
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
    newEstate.initDevicesAndFunctionalities(); // TODO: no waiting - check the risk?

    return newEstate;
  }

  // note: this is called both with and without waiting
  Future<void> initDevicesAndFunctionalities() async {
    // first non waiting activities
    for (var d in devices) {
      d.myEstateId = id;
    }
    for (var f in features) {
      for (var d2 in f.connectedDevices) {
        d2.connectedFunctionalities.add(f);
      }
    }
    for (var d in devices) {
      await d.init();
    }
    for (var f in features) {
      await f.init();
    }
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

  Functionality functionality(String functionalityId) {
    for (var f in features) {
      if (f.id == functionalityId) {
        return f  ;
      }
    }
    return allFunctionalities.noFunctionality();
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
    newDevice.myEstateId = this.id;

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
    // todo: pitäiskö poistaa myös device linkki?
  }

  int _functionalityIndex(String id) {
    return features.indexWhere((e)=>e.id == id);
  }

  void removeFunctionality(Functionality functionality) {

    int index = _functionalityIndex(functionality.id);
    if (index >= 0) {
      features.removeAt(index);
    }
    else {
      log.error('estate.removeFunctionality ${functionality.id} not found');
    }
  }

  void addView(FunctionalityView newFunctionalityView) {
    views.add(newFunctionalityView);
  }

  void removeView(FunctionalityView functionalityView) {
    views.remove(functionalityView);
  }

  void removeData(){

    for (var d in devices) {
      d.remove();
    }

    for (var f in features) {
      f.remove();
    }

    operationModes.clear();
  }

  void setViews() {
    views.clear();
  }

  List<String> operationModeNames() {
    List<String> names = operationModes.operationModeNames();
    features.forEach((e)=>names += e.operationModes.operationModeNames());
    names.sort();
    return names;
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


  Estate.fromJson(Map<String, dynamic> json){
    name = json['name'] ?? '';
    id = json['id'] ?? '';

    devices = List.from(json['devices']).map((e)=>extendedDeviceFromJson(e)).toList();
    features = List.from(json['features']).map((e)=>extendedFunctionalityFromJson(this.name, e)).toList();
    views = List.from(json['views']).map((e)=>extendedFunctionalityViewFromJson(e)).toList();
    operationModes = OperationModes.fromJson(json['operationModes'] ?? {});

  }

  Map<String, dynamic> toJson() {


    final json = <String, dynamic>{};

    json['name'] = name;
    json['id'] = id;
    json['devices'] = devices.map((e)=>e.toJson()).toList();
    json['features'] = features.map((e)=>e.toJson()).toList();
    json['views'] = views.map((e)=>e.toJson()).toList();
    json['operationModes'] = operationModes.toJson();

    return json;
  }

}

void _setOperationModeOn(Map<String, dynamic> parameters) {
  log.info('Estate set operation parameters ${parameters.toString()}');
}

Map<String, dynamic> _getParameters() {
  return {};
}




class Estates {
  List <Estate> estates = [];
  final EstateDataStorage _estateDataStorage =  EstateDataStorage();
  int currentIndex = -1;
  final Estate noEstates = Estate.undefined();

  Estates();

  Estate currentEstate () => ((currentIndex >= 0) && (currentIndex < nbrOfEstates()))
                                ? estates [currentIndex]
                                : noEstates;

  int nbrOfEstates() => estates.length;

  Estate _candidateEstate = Estate();

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
      for (var f in e.features) {
        for (var d2 in f.connectedDevices) {
          d2.connectedFunctionalities.add(f);
        }
        await f.init();
      }
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
    } else if (estates.length == 1) {
      currentIndex = 0;
    } else if (storedIndex < estates.length) {
      currentIndex = storedIndex;
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
    if (id == _candidateEstate.id) {
      return _candidateEstate;
    }
    for (int index = 0; index <estates.length; index++) {
      if (estates[index].id == id) {
        return estates[index];
      }
    }
    return noEstates;
  }
}

Estates myEstates = Estates();


