
import 'package:flutter/material.dart';

import '../../../logic/observation.dart';
import '../../../look_and_feel.dart';

import '../../functionality/functionality.dart';
import '../../functionality/view/functionality_view.dart';

import '../air_heat_pump.dart';
import 'air_heat_pump_overview.dart';

class AirHeatPumpView extends FunctionalityView {

  AirHeatPumpView(dynamic myFunctionality) : super(myFunctionality) {
  }

  ButtonStyle myButtonStyle() {
    ObservationLevel observationLevel = (myFunctionality as AirHeatPump).myPumpDevice().observationLevel();
    return (observationLevel == ObservationLevel.alarm) ? buttonStyle(Colors.red, Colors.white) :
    (observationLevel == ObservationLevel.warning) ? buttonStyle(Colors.yellow, Colors.white) :
    buttonStyle(Colors.green, Colors.white);
  }

  @override
  Widget gridBlock(BuildContext context, Function callback) {

    return ElevatedButton(
        style:myButtonStyle(),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return AirHeatPumpOverview(airHeatPump:myFunctionality);
            },
          ));
          callback();

        },
        onLongPress: () {
        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                  (myFunctionality as AirHeatPump).myPumpDevice().name,
                  style: const TextStyle(
                      fontSize: 12)),
              Icon(
                Icons.heat_pump_rounded,
                size: 50,
                color: Colors.white,
              ),
            ])
    );
  }

  AirHeatPumpView.fromJson(Map<String, dynamic> json) : super(allFunctionalities.noFunctionality()) {
    //super.fromJson(json);
    myFunctionality = allFunctionalities.findFunctionality(json['myFunctionalityId'] ?? '') as AirHeatPump;
  }

}
