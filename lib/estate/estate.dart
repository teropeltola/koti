import 'dart:async';
import 'dart:convert';

import '../devices/device/device.dart';
import '../devices/wifi/wifi.dart';
import '../functionalities/electricity_price/electricity_price.dart';
import '../functionalities/functionality/functionality.dart';
import '../functionalities/functionality/view/functionality_view.dart';
import '../interfaces/estate_data_storage.dart';
import '../logic/unique_id.dart';
import '../operation_modes/operation_modes.dart';
import '../look_and_feel.dart';
import 'environment.dart';

const String estateOperationParameterSettingFunction = 'estateParameterSetting';

class Estate extends Environment {
  String id = '';
  Wifi myWifiDevice = Wifi();

  // Environment env = Environment();

  List <Device> devices = [];
  List <Functionality> features = [];
  List <FunctionalityView> views = [];

  late OperationModes operationModes;

  Estate() {
    id = UniqueId('e').get();
    operationModes = OperationModes(id);
    operationModes.types.add(estateOperationParameterSettingFunction);
    operationModes.selectFunction = _setOperationModeOn;
  }

  String get myWifi => myWifiDevice.name;
  set myWifi(String newName) { this.myWifiDevice.name = newName; }

  bool get myWifiIsActive => myWifiDevice.iAmActive;

  void init(String initName, String initMyWifi) {
    name = initName;
    operationModes.estateName = name;
    myWifiDevice = Wifi();
    devices.add(myWifiDevice);
    myWifiDevice.initWifi(initMyWifi);
  }

  Estate clone() {
    Estate newEstate = Estate.fromJson(toJson());
    newEstate.operationModes.estateName = newEstate.name;
    return newEstate;
  }
  ElectricityPrice myDefaultElectricityPrice() {
    for (int functionalityIndex = 0; functionalityIndex < features.length; functionalityIndex++) {
      var functionality = features[functionalityIndex];
      if (functionality is ElectricityPrice) {
        return features[functionalityIndex] as ElectricityPrice;
      }
    }
    log.error ('Estate myDefaultElectricityPrice: no ElectricityPrice functionality found!');
    return ElectricityPrice();
  }

  Functionality functionality(String functionalityId) {
    for (int functionalityIndex = 0; functionalityIndex < features.length; functionalityIndex++) {
      if (features[functionalityIndex].id() == functionalityId) {
        return features[functionalityIndex];
      }
    }
    return allFunctionalities.noFunctionality();
  }

  void addDevice(Device newDevice) {
    newDevice.myEstates.add(this);

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

  List<String> operationModeNames() {
    List<String> names = operationModes.operationModeNames();
    features.forEach((e)=>names += e.operationModes.operationModeNames());
    names.sort();
    return names;
  }


  Estate.fromJson(Map<String, dynamic> json){
    name = json['name'] ?? '';
    id = json['id'] ?? '';

    myWifiDevice = Wifi();
    devices.add(myWifiDevice);
    myWifiDevice.initWifi(json['myWifi'] ?? '');

    devices = List.from(json['devices']).map((e)=>extendedDeviceFromJson(e)).toList();
    features = List.from(json['features']).map((e)=>extendedFunctionalityFromJson(this.name, e)).toList();
    views = List.from(json['views']).map((e)=>extendedFunctionalityViewFromJson(e)).toList();
    operationModes = OperationModes.fromJson(json['operationModes'] ?? {});

    operationModes.types.add(estateOperationParameterSettingFunction);
    operationModes.selectFunction = _setOperationModeOn;
  }

  Map<String, dynamic> toJson() {


    final json = <String, dynamic>{};

    json['name'] = name;
    json['id'] = id;
    json['myWifi'] = myWifi;
    json['devices'] = devices.map((e)=>e.toJson()).toList();
    json['features'] = features.map((e)=>e.toJson()).toList();
    json['views'] = views.map((e)=>e.toJson()).toList();
    json['operationModes'] = operationModes.toJson();

    return json;
  }

}

Future<void> _setOperationModeOn(Map<String, dynamic> parameters) async {
  log.info('Estate set operation parameters ${parameters.toString()}');
}

final Estate noEstates = Estate();

class Estates {
  List <Estate> estates = [];
  final EstateDataStorage _estateDataStorage =  EstateDataStorage();
  int _currentIndex = -1;

  Estates();

  Estate currentEstate () => ((_currentIndex >= 0) && (_currentIndex < nbrOfEstates()))
                                ? estates [_currentIndex]
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
    _currentIndex = -1;
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

    if (index <= _currentIndex) {
     _currentIndex--;
    }
  }

  void setCurrent(String estateId) {
    _currentIndex = estates.indexWhere((e) => e.id == estateId);
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
        estates[i].devices[j].myEstates.add(estates[i]);
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
    var json = jsonEncode(this);
    await _estateDataStorage.storeEstateFile(json);
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
      _currentIndex = -1;
    } else if (estates.length == 1) {
      _currentIndex = 0;
    } else if (storedIndex < estates.length) {
      _currentIndex = storedIndex;
    }
  }

  Map<String, dynamic> toJson() {

    final json = <String, dynamic>{};

    json['estates'] = estates.map((e)=>e.toJson()).toList();
    json['currentIndex'] = _currentIndex;

    return json;
  }

  Future<void> resetAll() async {
    _estateDataStorage.delete();
    clearDataStructures();
  }

  int noEstateIndex() {
    return -1;
  }

  void setEstate(String oldName, Estate estate) {
    int index = _findEstate(oldName);
    if (index >= 0) {
      estates[index] = estate;
    }
  }

  Estate estate(String name) {
    int index = _findEstate(name);
    if (index >= 0) {
      return estates[index];
    }
    else {
      return noEstates;
    }
  }

  int _findEstate (String name) {
    for (int index = 0; index <estates.length; index++) {
      if (estates[index].name == name) {
        return index;
      }
    }
    return -1;
  }
}

