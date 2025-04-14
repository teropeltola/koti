import 'package:flutter/material.dart';
import 'package:thermostat/thermostat.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../../../operation_modes/conditional_operation_modes.dart';
import '../../../operation_modes/operation_modes.dart';
import '../../../operation_modes/view/conditional_option_list_view.dart';
import '../../air_heat_pump_functionality/view/air_heat_pump_view.dart';

List<String> possibleParameterTypes = [constWarming, relativeWarming ];

Widget temperatureSelectionForm(String parameterName, Map <String, dynamic> parameters) {
  double currentValue = parameters[parameterName] ?? 24.0;

  return Thermostat(
      formatCurVal: (val) { return 'Lämpötila';},
      curVal: currentValue,
      setPoint: currentValue,
      setPointMode: SetPointMode.displayAndEdit,
      formatSetPoint: (val) { return '${val.toStringAsFixed(1)} $celsius';},
      themeType: ThermostatThemeType.light,
      maxVal: 40.0,
      minVal: 15.0,
      size: 300.0,
      turnOn: true,
      onChanged: (val) {currentValue = val; parameters[parameterName] = val; }
  );
}

Widget boilerHeatingParameterSetting(
    OperationMode operationMode,
    Estate estate,
    OperationModes operationModes
    )
{
  Widget myWidget;
  if (operationMode is ConstantOperationMode) {
    ConstantOperationMode cOM = operationMode;
    myWidget=temperatureSelectionForm(temperatureParameterId, cOM.parameters);
  }
  else if (operationMode is ConditionalOperationModes) {
    myWidget = ConditionalOperationView(
        conditions: operationMode
    );
  }
  else if (operationMode is BoolServiceOperationMode) {
    BoolServiceOperationMode bOS = operationMode;
    myWidget = Text('ei oo toteutettu, käytä jo määriteltyjä tiloja');
  }
  else
  {
    myWidget=const Text('ei oo toteutettu, mutta ideana on antaa +/- arvoja edelliseen verrattuna');
  }
  return myWidget;
}
