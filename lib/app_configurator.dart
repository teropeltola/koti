
import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';
import 'package:koti/devices/shelly_pro2/shelly_pro2.dart';
import 'package:koti/devices/shelly_timer_switch/shelly_timer_switch.dart';
import 'package:koti/devices/testing_switch_device/testing_switch_device.dart';
import 'package:koti/devices/vehicle/vehicle.dart';
import 'package:koti/devices/weather_service_provider/weather_service_provider.dart';

import 'devices/device/device.dart';
import 'devices/ouman/ouman_device.dart';
import 'devices/porssisahko/porssisahko.dart';
import 'devices/wifi/wifi.dart';
import 'estate/estate.dart';

void initDeviceTypes() {
  OumanDevice().addClassIntoApp();
  Porssisahko().addClassIntoApp();
  ShellyPro2().addClassIntoApp();
  ShellyTimerSwitch().addClassIntoApp();
  MitsuHeatPumpDevice().addClassIntoApp();
  Device().addClassIntoApp();
  TestingSwitchDevice().addClassIntoApp();
  Vehicle().addClassIntoApp();
  WeatherServiceProvider('', '', '').addClassIntoApp();
  Wifi().addClassIntoApp();
}

void initConfiguration() {
  initDeviceTypes();
}

ApplicationDeviceTypes applicationDeviceConfigurator = ApplicationDeviceTypes();

class ApplicationDeviceTypes {
  List <DeviceTypeStructure> typeList = [];

  void add(Device device) {
    device.setFailed();
    typeList.add(DeviceTypeStructure(device.runtimeType.toString(), device));
  }

  bool deviceExists(Device device) {
    String typeName = device.runtimeType.toString();
    bool found = typeList.indexWhere((element) => element.runtimeTypeName == typeName) >= 0;
    return found;
  }

  List <Device> getDevicesWithAttribute(String attribute) {
    List <Device> deviceList = [];
    for (var element in typeList) {
      if (element.devicePrototype.services.offerService(attribute)) {
        Device newDevice = element.devicePrototype.clone();
        newDevice.setOk();
        newDevice.myEstateId = myEstates.currentEstate().id;
        deviceList.add(newDevice);
      }
    }
    return deviceList;
  }
}

class DeviceTypeStructure {
  late String runtimeTypeName;
  late Device devicePrototype;

  DeviceTypeStructure(this.runtimeTypeName, this.devicePrototype);
}

