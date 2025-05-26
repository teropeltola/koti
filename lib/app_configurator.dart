
import 'package:hive/hive.dart';
import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';
import 'package:koti/devices/shelly_pro2/shelly_pro2.dart';
import 'package:koti/devices/shelly_timer_switch/shelly_timer_switch.dart';
import 'package:koti/devices/testing_switch_device/testing_switch_device.dart';
import 'package:koti/devices/testing_thermostat_device/testing_thermostat_device.dart';
import 'package:koti/devices/vehicle/vehicle.dart';
import 'package:koti/devices/weather_service_provider/weather_service_provider.dart';
import 'package:koti/functionalities/electricity_price/trend_electricity.dart';
import 'package:koti/trend/trend.dart';
import 'package:koti/trend/trend_event.dart';
import 'package:koti/trend/trend_switch.dart';

import 'devices/device/device.dart';
import 'devices/ouman/ouman_device.dart';
import 'devices/ouman/trend_ouman.dart';
import 'devices/porssisahko/porssisahko.dart';
import 'devices/shelly_blu_gw/shelly_blu_gw.dart';
import 'devices/shelly_blu_trv/shelly_blu_trv.dart';
import 'devices/wifi/wifi.dart';
import 'estate/estate.dart';

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

  void clear() {
    typeList.clear();
  }

  void _initDeviceTypes() {
    OumanDevice().addClassIntoApp();
    Porssisahko().addClassIntoApp();
    ShellyPro2().addClassIntoApp();
    ShellyTimerSwitch().addClassIntoApp();
    MitsuHeatPumpDevice().addClassIntoApp();
    Device().addClassIntoApp();
    TestingSwitchDevice().addClassIntoApp();
    TestingThermostatDevice().addClassIntoApp();
    Vehicle().addClassIntoApp();
    WeatherServiceProvider('', '', '').addClassIntoApp();
    Wifi().addClassIntoApp();
    ShellyBluGw().addClassIntoApp();
    ShellyBluTrv.empty().addClassIntoApp();
  }

  void initConfiguration() {
    clear();
    initHiveAdapters();
    _initDeviceTypes();
  }
}

class DeviceTypeStructure {
  late String runtimeTypeName;
  late Device devicePrototype;

  DeviceTypeStructure(this.runtimeTypeName, this.devicePrototype);
}


// Hive structures
//TODO: reset values when you will start from the beginning
const int hiveTypeTrendData = 1;
const int hiveTypeTrendEvent = 2;
const int hiveTypeTrendMitsu = 4;
const int hiveTypeTrendElectricityPrice = 5;
const int hiveTypeTrendOuman = 6;
const int hiveTypeTrendOnOffSwitch = 7;

const String hiveTrendDataName = 'trendData';
const String hiveTrendEventName = 'trendEvent';
const String hiveTrendOumanName = 'trendOuman2';
const String hiveTrendMitsuName = 'trendMitsu';
const String hiveTrendElectricityPriceName = 'trendElectricityPrice';
const String hiveTrendOnOffSwitch = 'trendOnOffSwitch';

void initHiveAdapters() {
  try {
    Hive.registerAdapter(TrendDataAdapter());
    Hive.registerAdapter(TrendEventAdapter());
    Hive.registerAdapter(TrendOumanAdapter());
    Hive.registerAdapter(TrendSwitchAdapter());
    Hive.registerAdapter(TrendElectricityAdapter());
  }
  catch (e) {
    print('Hive adapter registration failed: $e');
  }
}

// workmanager structures
// 1. add const task name
// 2. add it to the workmanagerTasks
// 3. add function that is called from workmanager

const String oumanWorkmanagerTask = 'oumanWorkmanagerTask';

const List<String> workmanagerTasks = [
  oumanWorkmanagerTask
];

const List<Function> workmanagerFunctions = [
  // oumanWorkmanagerFunction
];
