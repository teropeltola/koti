
import 'package:flutter/material.dart';

import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';
import 'package:koti/functionalities/air_heat_pump_functionality/view/air_heat_pump_view.dart';
import 'package:koti/functionalities/air_heat_pump_functionality/view/edit_air_pump_view.dart';
import 'package:koti/operation_modes/operation_modes.dart';
import '../../devices/device/device.dart';
import '../../estate/environment.dart';
import '../../estate/estate.dart';
import '../../logic/device_attribute_control.dart';
import '../../look_and_feel.dart';
import '../../operation_modes/conditional_operation_modes.dart';
import '../functionality/functionality.dart';

class AirHeatPump extends Functionality {

  static const String functionalityName = 'ilmalämpöpumppu';

  AirHeatPump() {
    myView = AirHeatPumpView();
    myView.setFunctionality(this);
  }

  AirHeatPump.failed() {
    super.setFailed();
  }


  initStructures() {
    operationModes.initModeStructure(
        environment: myEstates.currentEstate(),
        parameterSettingFunctionName: airHeatParameterFunction,
        deviceId: connectedDevices.isNotEmpty ? connectedDevices[0].id : '',
        deviceAttributes: [DeviceAttributeCapability.directControl],
        setFunction: airpumpSetOperationParametersOn,
        getFunction: getFunction );

    operationModes.addType(ConstantOperationMode().typeName());
    operationModes.addType(ConditionalOperationModes().typeName());
  }

  @override
  Future<void> init () async {
    initStructures();
  }

  MitsuHeatPumpDevice myPumpDevice() {
    return connectedDevices[0] as MitsuHeatPumpDevice;
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

  AirHeatPump clone() {
    AirHeatPump newAirHeatPump = AirHeatPump.fromJson(toJson());
    newAirHeatPump.initStructures();
    return newAirHeatPump;
  }
  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  AirHeatPump.fromJson( Map<String, dynamic> json) : super.fromJson(json) {
    myView = AirHeatPumpView();
    myView.setFunctionality(this);
    initStructures();
  }

  void airpumpSetOperationParametersOn(Map<String, dynamic> parameters) {
    log.info('Airpump set temperature as ${parameters[temperatureParameterId].toString()}');
  }

  Map<String, dynamic> getFunction() {
    Map<String, dynamic> map = {};
    map[temperatureParameterId] = myPumpDevice().targetTemperature();
    return map;
  }


  @override
  Future<bool> editWidget(BuildContext context, bool createNew, Environment environment, Functionality functionality, Device device) async {
    bool success = await Navigator.push(context, MaterialPageRoute(
        builder: (context)
        {
          return EditAirPumpView(
              environment: environment,
              airHeatPumpInput: this,
              callback: (){}
         );
        }));
    return success;
  }
}
