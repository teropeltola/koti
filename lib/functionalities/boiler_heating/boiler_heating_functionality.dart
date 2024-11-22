import 'dart:async';

import 'package:flutter/material.dart';

import 'package:koti/functionalities/boiler_heating/view/boiler_heating_functionality_view.dart';
import 'package:koti/functionalities/boiler_heating/view/edit_boiler_heating_view.dart';
import 'package:koti/logic/statistics_collection.dart';
import 'package:koti/service_catalog.dart';
import '../../devices/device/device.dart';
import '../../estate/estate.dart';
import '../../logic/device_attribute_control.dart';
import '../../logic/state_broker.dart';
import '../../look_and_feel.dart';
import '../../operation_modes/conditional_operation_modes.dart';
import '../../operation_modes/operation_modes.dart';
import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';
import 'view/edit_boiler_heating_view.dart';

const int _noStats = -1;

class BoilerHeatingFunctionality extends Functionality {

  static const String functionalityName = 'lämminvesivaraaja';

  bool fullLogOn = true;

  int statIntervalInMinutes = _noStats;

  StatisticsCollection<double> boilerTemperatureTrend = StatisticsCollection();

  bool _noTimer() {
    return (statIntervalInMinutes != _noStats);
  }

  void initStructures() {

    operationModes.initModeStructure(
       estate: myEstates.currentEstate(),
       parameterSettingFunctionName: '',
       deviceId: connectedDevices.isEmpty ? '' : connectedDevices[0].id,
       deviceAttributes: [DeviceAttributeCapability.directControl],
       setFunction: boilerHeatingSetOperationParametersOn,
       getFunction: getFunction );

   operationModes.addType(ConditionalOperationModes().typeName());
   operationModes.addType(BoolServiceOperationMode().typeName());
  }

  BoilerHeatingFunctionality() {
  }

  @override
  Future<void> init () async {
    initStructures();
  }


  void boilerHeatingSetOperationParametersOn(Map<String, dynamic> parameters) {
    log.info('boilerHeating set ');
  }

  Map<String, dynamic> getFunction() {
    Map<String, dynamic> map = {};
//    map[temperatureParameterId] = myPumpDevice().setTemperature();
    return map;
  }

  void _handleTimerClick() {
    // todo: this should be generalized
    double boilerTemperature = myEstates.currentEstate().stateBroker.getDoubleValue(currentRadiatorWaterTemperatureService);
    log.info('pannun lämpötila: $boilerTemperature');
    fullLog();
  }

  void fullLog() {
    if (fullLogOn) {
      StateBroker s = myEstates.currentEstate().stateBroker;
      log.info('Pannun lämpötila: ${s.getDoubleValue(currentRadiatorWaterTemperatureService)}');
      log.info('Ulkolämpötila: ${s.getDoubleValue(outsideTemperatureService)}');
      log.info('Venttiili: ${s.getDoubleValue(radiatorValvePositionService)}');
    }
  }

  void _setTimer() {
    if (_noTimer()) {
      return;
    }
    Timer t = Timer(
        Duration(minutes: statIntervalInMinutes),
        () {
          _handleTimerClick();
            _setTimer();
        });
  }

  Future<void> setOn() async {
    _handleTimerClick();
    _setTimer();
  }

  Future<void> setOff() async {

  }

  @override
  FunctionalityView myView() {
    return BoilerHeatingFunctionalityView(this);
  }

  BoilerHeatingFunctionality clone() {
    BoilerHeatingFunctionality b = BoilerHeatingFunctionality.fromJson(toJson());
    b.initStructures();
    return b;
  }


  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['statIntervalInMinutes'] = statIntervalInMinutes;
    return json;
  }

  @override
  BoilerHeatingFunctionality.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    statIntervalInMinutes = json['statIntervalInMinutes'] ?? _noStats;
  }


  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: functionalityName,
        textLines: [
          'tunnus: $id',
        ],
        widgets: [
          dumpDataMyDevices(formatterWidget: formatterWidget)
        ]
    );
  }

  @override
  Future<bool> editWidget(BuildContext context, bool createNew, Estate estate, Functionality functionality, Device device) async {
    bool success = await Navigator.push(context, MaterialPageRoute(
        builder: (context)
    {
      return EditBoilerHeatingView(
          estate: estate,
          createNew: createNew,
          boilerHeating: this
      );
    }));
    return success;
  }
}


Future <BoilerHeatingFunctionality> createBoilerWarmingSystem(BuildContext context, Estate estate, String serviceName) async {
  BoilerHeatingFunctionality boilerHeating = BoilerHeatingFunctionality();
  await boilerHeating.init();

  bool success = await Navigator.push(context, MaterialPageRoute(
    builder: (context)
      {
        return EditBoilerHeatingView(
            estate: estate,
            createNew: true,
            boilerHeating: boilerHeating,
        );
      }
  ));

  if (! success) {
    boilerHeating.setFailed();
  }
  return boilerHeating;

}
