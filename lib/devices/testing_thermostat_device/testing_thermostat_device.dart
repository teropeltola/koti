import 'package:flutter/material.dart';
import 'package:koti/devices/testing_thermostat_device/view/edit_testing_thermostat_view.dart';
import '../../../estate/estate.dart';
import '../../../logic/services.dart';
import '../../../service_catalog.dart';
import '../../logic/unique_id.dart';
import '../device/device.dart';
import '../shelly_blu_trv/shelly_blu_trv.dart';

const double _targetAccuracy = 1.0;

class TestingThermostatDevice extends Device {

  late ThermostatControlService thermostatControlService;

  DateTime statusFetched = DateTime(0);

  double _currentTargetTemperature = 22.2;

  TestingThermostatDevice(){
    _setUniqueId();
    _initOfferedServices();
  }

  TestingThermostatDevice.empty();

  @override
  _setUniqueId() {
    id = UniqueId('testing').get();
  }

  @override
  setOk() {
    _setUniqueId();
  }


  @override
  bool isReusableForFunctionalities() {
    return true;
  }


  void _initOfferedServices() {
    services = Services([
      AttributeDeviceService(attributeName: deviceWithManualCreation),
    ]);
  }

  @override
  Future<void> init() async {

    thermostatControlService = ThermostatControlService(
        _temperatureFunction, _targetTemperature, _setTargetTemperature,
        _peekTemperature, _batteryLevel, _showMessage, _targetAccuracy, this);

    services.addService(
        DeviceServiceClass<ThermostatControlService>(serviceName: thermostatService, services: thermostatControlService));

    state.setConnected();
  }

  Future<void> updateData() async {
    statusFetched = DateTime.now();
  }


  Future <double> _temperatureFunction() async {
    return 21.1;
  }

  Future <double> _targetTemperature() async {
    return _currentTargetTemperature;
  }

  Future <void> _setTargetTemperature(double newTarget, String caller) async {
    double roundedNewTarget = (newTarget / _targetAccuracy).round() * _targetAccuracy;
    _currentTargetTemperature = roundedNewTarget;
  }

  Future <void> _showMessage(String message) async {
    String shortMessage = message.length > 10 ? message.substring(0,9) : message;
    print(shortMessage);
  }

  int _batteryLevel()  {
    return (100);
  }

  double _peekTemperature() {
    return 21.2;
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: name,
        textLines: [
          'tunnus: $id',
          'tila: ${state.stateText()}',
        ],
        widgets: [
          dumpDataMyFunctionalities(formatterWidget: formatterWidget),
        ]
    );
  }

  @override
  IconData icon() {
    return Icons.thermostat;
  }

  @override
  String shortTypeName() {
    return 'test thermo';
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  TestingThermostatDevice.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    _initOfferedServices();
  }


  @override
  TestingThermostatDevice clone() {
    return TestingThermostatDevice.fromJson(toJson());
  }

  @override
  Future<bool> editWidget(BuildContext context, Estate estate) async {
    return await Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return EditTestingThermostatView(
              estate: estate,
              thermostat: this,
              callback: () {}
          );
        }));
  }
}
