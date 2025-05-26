
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:koti/devices/shelly_blu_trv/shelly_blu_trv.dart';

import 'package:koti/functionalities/thermostat/view/edit_thermostat_view.dart';
import 'package:koti/functionalities/thermostat/view/thermostat_view.dart';
import '../../devices/device/device.dart';
import '../../estate/environment.dart';
import '../../estate/estate.dart';
import '../../logic/device_attribute_control.dart';
import '../../logic/services.dart';
import '../../look_and_feel.dart';
import '../../operation_modes/conditional_operation_modes.dart';
import '../../service_catalog.dart';
import '../functionality/functionality.dart';

enum ThermostatMode { simple, average  }

class Thermostat extends Functionality {

  static const String functionalityName = 'termostaatti';
  String thermoName = '';
  ThermostatMode thermostatMode = ThermostatMode.simple;

  List<double> _currentTemperatures = [];
  List<double> _targetTemperatures = [];
  double minAccuracy = 1.0;

  Timer? timer;

  Thermostat() {
    myView = ThermostatView();
    myView.setFunctionality(this);
  }

  void initStructures() {

    operationModes.initModeStructure(
        environment: myEstates.currentEstate(),
        parameterSettingFunctionName: '',
        deviceId: connectedDevices.isEmpty ? '' : connectedDevices[0].id,
        deviceAttributes: [DeviceAttributeCapability.directControl],
        setFunction: thermostatSetOperationParametersOn,
        getFunction: getFunction );

    operationModes.addType(ConditionalOperationModes().typeName());
    //operationModes.addType(DoubleServiceOperationMode().typeName());
  }

  Future<void> fetchTemperatures() async {
    List<double> currentTemperatures = [];
    List<double> targetTemperatures = [];

    for (var device in connectedDevices) {
      if ((device.connected()) && (device.services.offerService(thermostatService))) {
        ThermostatControlService thermostatControlService =
            (device.services.getService(thermostatService) as DeviceServiceClass<ThermostatControlService>)
                .services;
        double currTemp = await thermostatControlService.temperature();
        if (currTemp != noValueDouble) {
          currentTemperatures.add(await thermostatControlService.temperature());
        }
        double targetTemp = await thermostatControlService.targetTemperature();
        if (targetTemp != noValueDouble) {
          targetTemperatures.add(await thermostatControlService.targetTemperature());
        }
        if (thermostatControlService.targetAccuracy < minAccuracy) {
          minAccuracy = thermostatControlService.targetAccuracy;
        }
      }
    }
    _currentTemperatures = currentTemperatures;
    _targetTemperatures = targetTemperatures;
  }

  void setTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      await fetchTemperatures();
    });
  }

  void thermostatSetOperationParametersOn(Map<String, dynamic> parameters) {
    log.error('thermostat setFunction not implemented ');
  }

  Map<String, dynamic> getFunction() {
    Map<String, dynamic> map = {};
//    map[temperatureParameterId] = myPumpDevice().setTemperature();
    log.error('thermostat getFunction not implemented ');
    return map;
  }

  @override
  Future<void> init () async {
    initStructures();
    await fetchTemperatures();
    setTimer();
  }

  double temperature(List<double> temperatures) {
    if (temperatures.isEmpty) {
      return noValueDouble;
    }
    if (thermostatMode == ThermostatMode.simple) {
      return temperatures.first;
    }
    else if (thermostatMode == ThermostatMode.average) {
      double sum = 0.0;
      for (var temperature in temperatures) {
        sum += temperature;
      }
      return sum / temperatures.length;
    }
    return noValueDouble;
  }

  double currentTemperature() {
    return temperature(_currentTemperatures);
  }

  double targetTemperature() {
    return temperature(_targetTemperatures);
  }

  Future<void> setTargetTemperature(double newTarget) async {
    double delta = newTarget - targetTemperature();
    if (delta.abs() >= 0.1) {
      for (var device in connectedDevices) {
        if (device.services.offerService(thermostatService)) {
          ThermostatControlService thermostatControlService =
              (device.services.getService(thermostatService) as DeviceServiceClass<ThermostatControlService>)
                  .services;
          double current = await thermostatControlService.targetTemperature();
          await thermostatControlService.setTargetTemperature(current + delta, 'manual');
        }
      }
      await fetchTemperatures();
    }
  }


  @override
  Future<bool> Function(BuildContext context, Environment environment, Functionality functionality, Function callback)  myEditingFunction() {
    return editThermostatFunctionality;
  }

  @override
  Future<bool> editWidget(BuildContext context, bool createNew, Environment environment, Functionality functionality, Device device) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return EditThermostatView(
                environment: environment,
                thermostat: this,
                callback: () {}
            );
          },
        )
    );
  }

  @override
  Thermostat clone() {
    Thermostat t = Thermostat.fromJson(toJson());
    t.initStructures();
    return t;
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: functionalityName,
        textLines: [
          'tunnus: $id',
          'nimi: $thermoName',
//          switchStatus() ? 'päällä' : 'suljettu',
        ],
        widgets: [
          dumpDataMyDevices(formatterWidget: formatterWidget)
        ]
    );
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['thermoName'] = thermoName;
    json['thermostatMode'] = thermostatMode.index;
    return json;
  }

  @override
  Thermostat.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    thermoName = json['thermoName'] ?? '';
    thermostatMode = ThermostatMode.values[json['thermostatMode'] ?? 0];
    myView = ThermostatView();
    myView.setFunctionality(this);
  }
}

Future<bool> editThermostatFunctionality(BuildContext context, Environment environment, Functionality functionality, Function callback) async {
  bool success = await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return EditThermostatView(
            environment: environment,
            thermostat: functionality as Thermostat,
            callback: callback
        );
      }));
  return success;
}


Future <bool> createThermostatSystem(BuildContext context, Environment environment) async {

  Thermostat thermostat = Thermostat();

  bool success = await Navigator.push(context, MaterialPageRoute(
      builder: (context)
      {
        return EditThermostatView(
            environment: environment,
            thermostat: thermostat,
            callback: () {}
        );
      }
  ));

  return success;
}