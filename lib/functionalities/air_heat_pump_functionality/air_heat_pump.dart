
import 'package:flutter/material.dart';

import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';
import 'package:koti/functionalities/air_heat_pump_functionality/view/air_heat_pump_view.dart';
import 'package:koti/functionalities/air_heat_pump_functionality/view/edit_air_pump_view.dart';
import 'package:koti/operation_modes/operation_modes.dart';
import '../../devices/device/device.dart';
import '../../estate/estate.dart';
import '../../logic/device_attribute_control.dart';
import '../../look_and_feel.dart';
import '../../operation_modes/conditional_operation_modes.dart';
import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class AirHeatPump extends Functionality {

  static const String functionalityName = 'ilmalämpöpumppu';

  AirHeatPump() {
  }

  AirHeatPump.failed() {
    super.setFailed();
  }


  initStructures() {
    operationModes.initModeStructure(
        estate: myEstates.currentEstate(),
        parameterSettingFunctionName: airHeatParameterFunction,
        deviceId: '',
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
  FunctionalityView myView() {
    return AirHeatPumpView(this);
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
    initStructures();
  }

  void airpumpSetOperationParametersOn(Map<String, dynamic> parameters) {
    log.info('Airpump set temperature as ${parameters[temperatureParameterId].toString()}');
  }

  Map<String, dynamic> getFunction() {
    Map<String, dynamic> map = {};
    map[temperatureParameterId] = myPumpDevice().setTemperature();
    return map;
  }


  @override
  Future<bool> editWidget(BuildContext context, bool createNew, Estate estate, Functionality functionality, Device device) async {
    bool success = await Navigator.push(context, MaterialPageRoute(
        builder: (context)
        {
          return EditAirPumpView(
              estate: estate,
              createNew: createNew,
              airHeatPumpInput: this
          );
        }));
    return success;
  }
}

Future <AirHeatPump> createAirHeatPumpSystem(BuildContext context, Estate estate, String serviceName) async {
  AirHeatPump airHeatPump = AirHeatPump();
  await airHeatPump.init();

  bool success = await Navigator.push(context, MaterialPageRoute(
      builder: (context)
      {
        return EditAirPumpView(
          estate: estate,
          createNew: true,
          airHeatPumpInput: airHeatPump,
        );
      }
  ));

  if (! success) {
    airHeatPump.setFailed();
  }
  return airHeatPump;

}
