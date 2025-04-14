import 'package:flutter/material.dart';

import 'package:koti/functionalities/radiator_water_circulation/view/edit_radiator_water_circulation_view.dart';
import 'package:koti/functionalities/radiator_water_circulation/view/radiator_water_circulation_view.dart';
import '../../devices/device/device.dart';
import '../../devices/ouman/ouman_device.dart';
import '../../estate/environment.dart';
import '../../estate/estate.dart';
import '../../logic/device_attribute_control.dart';
import '../../look_and_feel.dart';
import '../../operation_modes/conditional_operation_modes.dart';
import '../../operation_modes/operation_modes.dart';
import '../functionality/functionality.dart';

const String radiatorParameterFunction = 'radiatorParameterFunction';
const String temperatureParameterId = 'temperature';


class RadiatorWaterCirculation extends Functionality {

  static const String functionalityName = 'patterijärjestelmä';

  RadiatorWaterCirculation() {
    myView = RadiatorWaterCirculationView();
    myView.setFunctionality(this);
  }

  RadiatorWaterCirculation.failed() {
    myView = RadiatorWaterCirculationView();
    myView.setFunctionality(this);
    setFailed();
  }

  @override
  Future<void> init () async {
    operationModes.initModeStructure(
        environment: myEstates.currentEstate(),
        parameterSettingFunctionName: radiatorParameterFunction,
        deviceId: '',
        deviceAttributes: [DeviceAttributeCapability.directControl],
        setFunction: radiatorSetOperationParametersOn,
        getFunction: getFunction );

    operationModes.addType(ConstantOperationMode().typeName());
    operationModes.addType(ConditionalOperationModes().typeName());
  }

  void radiatorSetOperationParametersOn(Map<String, dynamic> parameters) {
    log.info('Airpump set temperature as ${parameters[temperatureParameterId].toString()}');
  }

  Map<String, dynamic> getFunction() {
    Map<String, dynamic> map = {};
    map[temperatureParameterId] = myOuman().measuredWaterTemperature();
    return map;
  }


  OumanDevice myOuman() {
    return connectedDeviceOf('OumanDevice') as OumanDevice;
  }

  /*
  @override
  FunctionalityView myView() {
    return RadiatorWaterCirculationView(this.id);
  }

   */


  @override
  Future<bool> editWidget(BuildContext context, bool createNew, Environment environment, Functionality functionality, Device device) async {
    return await Navigator.push(context, MaterialPageRoute(
        builder: (context)
        {
          return EditRadiatorWaterCirculationView(
              environment: environment,
              radiatorSystem: functionality as RadiatorWaterCirculation
          );
        }
    ));
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
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  RadiatorWaterCirculation.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    myView = RadiatorWaterCirculationView();
    myView.setFunctionality(this);
  }

}

Future <bool> createNewRadiatorWaterCirculation(BuildContext context, Environment environment) async {
  RadiatorWaterCirculation radiatorSystem = RadiatorWaterCirculation();
  await radiatorSystem.init();

  bool success = await Navigator.push(context, MaterialPageRoute(
      builder: (context)
      {
        return EditRadiatorWaterCirculationView(
            environment: environment,
            radiatorSystem: radiatorSystem
        );
      }
  ));

  return success;

}
