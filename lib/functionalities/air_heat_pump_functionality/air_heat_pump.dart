
import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';
import 'package:koti/functionalities/air_heat_pump_functionality/view/air_heat_pump_view.dart';
import 'package:koti/operation_modes/operation_modes.dart';
import '../../look_and_feel.dart';
import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class AirHeatPump extends Functionality {

  AirHeatPump() {
    operationModes.selectFunction = airpumpSetOperationParametersOn;
  }

  @override
  Future<void> init () async {
  }

  MitsuHeatPumpDevice myPumpDevice() {
    return device as MitsuHeatPumpDevice;
  }

  @override
  FunctionalityView myView() {
    return AirHeatPumpView(this);
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  AirHeatPump.fromJson( Map<String, dynamic> json) : super.fromJson(json) {
    operationModes.selectFunction = airpumpSetOperationParametersOn;
  }

  Future<void> airpumpSetOperationParametersOn(Map<String, dynamic> parameters) async {
    log.info('Airpump set temperature as ${parameters[temperatureParameterId].toString()}');
  }


}

AirHeatPump createNewAirHeatPump(MitsuHeatPumpDevice mitsu) {

  AirHeatPump airHeatPump = AirHeatPump();
  allFunctionalities.addFunctionality(airHeatPump);
  airHeatPump.pair(mitsu);

  return airHeatPump;
}
