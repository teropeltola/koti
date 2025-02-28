
import 'package:flutter/material.dart';
import 'package:koti/functionalities/radiator_water_circulation/view/radiator_water_circulation_overview.dart';
import '../../../devices/ouman/ouman_device.dart';
import '../../../logic/observation.dart';

import '../../functionality/view/functionality_view.dart';
import '../radiator_water_circulation.dart';

class RadiatorWaterCirculationView extends FunctionalityView {

  RadiatorWaterCirculationView();

  ButtonStyle myButtonStyle() {
    // TODO: Tässä pitäisi laskea hälytystaso kaikille laitteille
    ObservationLevel observationLevel = (myFunctionality() as RadiatorWaterCirculation).myOuman().observationLevel();
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
              //RadiatorWaterCirculation heatingSystem = myFunctionality as RadiatorWaterCirculation;
              //return HeatingOverview(heatingSystem:heatingSystem);
              return RadiatorWaterCirculationOverview(radiator:myFunctionality() as RadiatorWaterCirculation, callback: callback);
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
                  viewName(),
                  style: const TextStyle(
                      fontSize: 12)),
              const Icon(
                Icons.cabin,
                size: 50,
                color: Colors.white,
              ),
            ])
    );
  }

/*
  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }
*/

  RadiatorWaterCirculationView.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }

  @override
  String viewName() {
    return 'Patterikierto';
  }

  @override
  String subtitle() {
    RadiatorWaterCirculation radiator = myFunctionality as RadiatorWaterCirculation;
    OumanDevice o = radiator.myOuman();

    if (o.isNotOk()) {
      return '';
    }
    else {
      return o.name;
    }
  }


}
