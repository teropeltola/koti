import 'package:flutter/material.dart';
import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';
import 'package:koti/devices/shelly_blu_gw/shelly_blu_gw.dart';
import 'package:koti/devices/weather_service_provider/weather_service_provider.dart';

import 'package:koti/functionalities/functionality/functionality.dart';

import '../../app_configurator.dart';
import '../../estate/estate.dart';
import '../../logic/observation.dart';
import '../../logic/services.dart';
import '../../look_and_feel.dart';
import '../ouman/ouman_device.dart';
import '../porssisahko/porssisahko.dart';
import '../shelly_blu_trv/shelly_blu_trv.dart';
import '../shelly_pro2/shelly_pro2.dart';
import '../shelly_timer_switch/shelly_timer_switch.dart';
import '../testing_switch_device/testing_switch_device.dart';
import '../testing_thermostat_device/testing_thermostat_device.dart';
import '../vehicle/vehicle.dart';
import '../wifi/wifi.dart';
import 'device_state.dart';

const double temperatureNotAvailable = -99.9;

const String _deviceFailure = 'deviceFailure';

DeviceList allDevices = DeviceList();

class Device {
  String _name = '';
  String id = '';
  String description = '';
  DeviceState state = DeviceState();
  List<Functionality> connectedFunctionalities = [];
  String myEstateId = ''; // A device is always connected to one estate. If not
                        // initialized then it's empty string
  ObservationMonitor observationMonitor = ObservationMonitor();
  Services services = Services([]);

  Device() {
    allDevices.add(this);
    observations.add(observationMonitor);
  }

  Device.noDevice() {
    // not added to all devices
    setFailed();
  }

  void addClassIntoApp() {
    applicationDeviceConfigurator.add(this);
  }

  Device.failed() {
    setFailed();
  }

  void setFailed() {
    id = _deviceFailure;
  }

  void _setUniqueId() {
    id = '';
  }

  void setOk() {
    _setUniqueId();
  }

  bool isNotOk() {
    return id == _deviceFailure;
  }

  bool isOk() {
    return id != _deviceFailure;
  }

  String get name => _name;
  set name(String newName) { _name = newName; observationMonitor.name = newName; }

  String detailsDescription() {
    return description;
  }

  void remove() {
    connectedFunctionalities.clear();
    allDevices.remove(this);
    observationMonitor.dispose();
    state.dispose();
  }

  Device clone2() {
    final json = toJson();

    Device newDevice = extendedDeviceFromJson(json);

    newDevice.myEstateId = myEstateId;
    newDevice.observationMonitor = observationMonitor;
    newDevice.services = services.clone();
    newDevice.state = state.clone();
    for (var c in connectedFunctionalities) {
      newDevice.connectedFunctionalities.add(c);
    }
    newDevice.myEstateId = myEstateId;
    newDevice.observationMonitor = observationMonitor;

    return newDevice;
  }

  Device clone() {
    Device newDevice = Device();
    newDevice.name = name;
    newDevice.id = id;
    newDevice.description = description;
    newDevice.state = state.clone();
    for (var c in connectedFunctionalities) {
      newDevice.connectedFunctionalities.add(c);
    }
    newDevice.myEstateId = myEstateId;
    newDevice.observationMonitor = observationMonitor;
    newDevice.services = services.clone();

    return newDevice;
  }

  void fromJson(Map<String, dynamic> json){
    name = json['name'] ?? '';
    id = json['id'] ?? '';
    description = json['description'] ?? '';
  }

  Device.fromJson(Map<String, dynamic> json){
    allDevices.add(this);
    fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['name'] = name;
    json['id'] = id;
    json['description'] = description;
    json['type'] = runtimeType.toString();

    return json;
  }

  Future<void> init() async {
  }

  bool connected() {
    return state.connected();
  }

  bool alarmOn() {
    return observationMonitor.currentLevel() == ObservationLevel.alarm;
  }

  ObservationLevel observationLevel() {
    return ObservationLevel.ok;
  }


  double outsideTemperatureFunction() {
    return temperatureNotAvailable;
  }

  Future<bool> editWidget(BuildContext context, Estate estate) async {
    return false;
  }

  dispose() {
    allDevices.remove(this);
  }

  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: name,
        textLines: [
          'tyyppiä ei määritelty',
        ],
        widgets: List<Widget>.empty(growable:true)
    );
  }

  //
  List <String> _connectedFunctionalityIds() {
    if (connectedFunctionalities.isEmpty) {
      return ['-'];
    }
    else {
      return [
        for (var functionality in connectedFunctionalities)
          functionality.id,
      ];
    }
  }
  // this function is used by the inherited classes for creating dumpData about
  // connected functionalities
  Widget dumpDataMyFunctionalities({required Function formatterWidget}) {
    return formatterWidget(
        headline: 'liitetyt toiminnot',
        textLines:
          _connectedFunctionalityIds(),
        widgets: List<Widget>.empty(growable: true)
    ) as Widget;
  }

  IconData icon() {
    return Icons.device_unknown;
  }

  Color ownColor() {
    return Colors.blue;
  }

  String shortTypeName() {
    return 'laite';
  }

  // this function is used by the inherited classes for checking it the device
  // is allowed to create several times (default is no). If yes then the inherited
  // class should override this function
  bool isReusableForFunctionalities() {
    return false;
  }
}

class DeviceList {

  List<Device> list = [];

  // returns the last device that has the id (there can be cloning cases when
  // there are more than one device with the same id)
  Device findDevice(String id) {
    for (int index=list.length-1; index>=0; index--) {
      if (list[index].id == id) {
        return list[index];
      }
    }
    return noDevice;
  }

  void add(Device newDevice) {
    list.add(newDevice);
  }

  void remove(Device device) {
    list.remove(device);
  }

  void clear() {
    list.clear();
  }

  List <Device> allDevices() {

    return list;
  }

}

final Device noDevice = Device.noDevice();

Device deviceFromTypeName(String typeName) {
  switch (typeName) {
    case 'Device':
      return Device();
    case 'OumanDevice':
      return OumanDevice();
    case 'ShellyTimerSwitch':
      return ShellyTimerSwitch();
    case 'Wifi':
      return Wifi();
    case 'Porssisahko':
      return Porssisahko();
    case 'MitsuHeatPumpDevice' :
      return MitsuHeatPumpDevice();
    case 'ShellyPro2':
      return ShellyPro2();
    case 'Vehicle':
      return Vehicle();
    case  'ShellyBluGw':
      return ShellyBluGw();
    case 'ShellyBluTrv':
      return ShellyBluTrv.empty();
    case  'WeatherServiceProvider':
      return WeatherServiceProvider('','','');
    case 'TestingSwitchDevice':
      return TestingSwitchDevice();
    case 'TestingThermostatDevice':
      return TestingThermostatDevice();

  }
  log.error('unknown type name "$typeName"');
  return Device();
}

Device extendedDeviceFromJson(Map<String, dynamic> json) {

  switch (json['type'] ?? '') {
    case 'Device': return Device.fromJson(json);
    case 'OumanDevice': return OumanDevice.fromJson(json);
    case 'ShellyTimerSwitch': return ShellyTimerSwitch.fromJson(json);
    case 'Wifi': return Wifi.fromJson(json);
    case 'Porssisahko': return Porssisahko.fromJson(json);
    case 'MitsuHeatPumpDevice' : return MitsuHeatPumpDevice.fromJson(json);
    case 'ShellyPro2': return ShellyPro2.fromJson(json);
    case 'WeatherServiceProvider': return WeatherServiceProvider.fromJson(json);
    case 'Vehicle': return Vehicle.fromJson(json);
    case 'TestingSwitchDevice': return TestingSwitchDevice.fromJson(json);
    case 'TestingThermostatDevice': return TestingThermostatDevice.fromJson(json);
    case 'ShellyBluGw': return ShellyBluGw.fromJson(json);
    case 'ShellyBluTrv': return ShellyBluTrv.fromJson(json);
  }
  log.error('unknown jsonObject: ${json['type'] ?? '- not found at all-'}');
  return noDevice;
}

