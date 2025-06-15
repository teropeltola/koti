import 'package:flutter/material.dart';
import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';

import '../../../logic/color_palette.dart';
import '../../../logic/observation.dart';
import '../../../look_and_feel.dart';
import '../../functionality/view/functionality_view.dart';

import '../air_heat_pump.dart';
import 'air_heat_pump_overview.dart';

const String airHeatParameterFunction = 'airHeatParameterFunction';
const String temperatureParameterId = 'temperature';

class _AirHeatPumpPalette extends ColorPalette {
  _AirHeatPumpPalette() : super() {
    modify(ColorPaletteMode.workingOn, newIcon: Icons.heat_pump_rounded);
    modify(ColorPaletteMode.workingOff, newIcon: Icons.heat_pump_rounded);
  }

}

class AirHeatPumpView extends FunctionalityView {

  AirHeatPumpView();

  @override
  Widget gridBlock(BuildContext context, Function callback) {

    MitsuHeatPumpDevice myPump = (myFunctionality() as AirHeatPump).myPumpDevice();


    _AirHeatPumpPalette currentPalette = _AirHeatPumpPalette();
    currentPalette.setCurrentPalette(
        myPump.observationLevel() == ObservationLevel.alarm,
        myPump.connected(),
        myPump.onOffService.peek()
    );

    return ElevatedButton(
        style: buttonStyle(currentPalette.backgroundColor(), currentPalette.textColor()),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return AirHeatPumpOverview(airHeatPump:myFunctionality() as AirHeatPump, callback: callback);
            },
          ));
        },
        onLongPress: () {
        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                  (myFunctionality() as AirHeatPump).myPumpDevice().name,
                  style: const TextStyle(
                      fontSize: 12)),
              shortOperationModeText(currentPalette.textColor()),
              currentPalette.iconWidget(),
/*              const Icon(
                Icons.heat_pump_rounded,
                size: 50,
                color: Colors.white,
              ),*/
            ])
    );
  }

  @override


  AirHeatPumpView.fromJson(Map<String, dynamic> json)  {
    super.fromJson(json);
  }

  @override
  String viewName() {
    return 'Ilmalämpöpumppu';
  }

  @override
  String subtitle() {
    return myFunctionality().connectedDevices[0].name;
  }

}


