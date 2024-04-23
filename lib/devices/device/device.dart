import 'package:flutter/material.dart';
import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';

import 'package:koti/functionalities/functionality/functionality.dart';

import '../../estate/estate.dart';
import '../../logic/observation.dart';
import '../../look_and_feel.dart';
import '../ouman/ouman_device.dart';
import '../porssisahko/porssisahko.dart';
import '../shelly_pro2/shelly_pro2.dart';
import '../shelly_timer_switch/shelly_timer_switch.dart';
import '../wifi/wifi.dart';
import 'device_state.dart';

const double temperatureNotAvailable = -99.9;

List<Device> _allDevices = [];

class Device {
  String _name = '';
  String id = '';
  String description = '';
  DeviceState state = DeviceState();
  List<Functionality> connectedFunctionalities = [];
  List <Estate> myEstates = [];
  ObservationMonitor observationMonitor = ObservationMonitor();

  Device() {
    _allDevices.add(this);
    observations.add(observationMonitor);
  }

  String get name => _name;
  set name(String newName) { this._name = newName; this.observationMonitor.name = newName; }

  String detailsDescription() {
    return description;
  }

  Device clone() {
    Device newDevice = Device();
    newDevice.name = name;
    newDevice.id = id;
    newDevice.description = description;
    newDevice.state = state.clone();
    connectedFunctionalities.forEach((e){newDevice.connectedFunctionalities.add(e);});
    for (int i=0; i<myEstates.length; i++) {
      newDevice.myEstates.add(myEstates[i]);
    }
    newDevice.observationMonitor = observationMonitor;

    return newDevice;
  }

  void fromJson(Map<String, dynamic> json){
    name = json['name'] ?? '';
    id = json['id'] ?? '';
    description = json['description'] ?? '';
  }

  Device.fromJson(Map<String, dynamic> json){
    _allDevices.add(this);
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

  ObservationLevel observationLevel() {
    return ObservationLevel.ok;
  }


  double temperatureFunction() {
    return temperatureNotAvailable;
  }

  Future<void> editWidget(BuildContext context, Estate estate, Functionality functionality, Device device) async {
  }

  dispose() {
    _allDevices.remove(this);
  }
}

Device findDevice(String id) {
  for (int i = 0; i<_allDevices.length; i++) {
    if (id == _allDevices[i].id) {
      return _allDevices[i];
    }
  }
  return noDevice;
}

void clearAllDevices() {
  _allDevices.clear();
}

final Device noDevice = Device();

Device extendedDeviceFromJson(Map<String, dynamic> json) {
  switch (json['type'] ?? '') {
    case 'Device': return Device.fromJson(json);
    case 'OumanDevice': return OumanDevice.fromJson(json);
    case 'ShellyTimerSwitch': return ShellyTimerSwitch.fromJson(json);
    case 'Wifi': return Wifi.fromJson(json);
    case 'Porssisahko': return Porssisahko.fromJson(json);
    case 'MitsuHeatPumpDevice' : return MitsuHeatPumpDevice.fromJson(json);
    case 'ShellyPro2': return ShellyPro2.fromJson(json);
  }
  log.error('unknown jsonObject: ${json['type'] ?? '- not found at all-'}');
  return noDevice;
}

