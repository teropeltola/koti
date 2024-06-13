
import 'package:flutter/material.dart';
import 'package:koti/functionalities/boiler_heating/view/boiler_heating_overview.dart';

import '../../../devices/shelly_pro2/shelly_pro2.dart';
import '../../functionality/functionality.dart';
import '../../functionality/view/functionality_view.dart';
import '../boiler_heating_functionality.dart';

class BoilerHeatingFunctionalityView extends FunctionalityView {

  late BoilerHeatingFunctionality myBoilerFunctionality;

  BoilerHeatingFunctionalityView(dynamic myFunctionality) : super(myFunctionality) {
    myBoilerFunctionality = myFunctionality as BoilerHeatingFunctionality;
  }

  BoilerHeatingFunctionalityView.fromJson(Map<String, dynamic> json) : super(allFunctionalities.noFunctionality()) {
    super.fromJson(json);
    myBoilerFunctionality = myFunctionality as BoilerHeatingFunctionality;
  }


  @override
  Widget gridBlock(BuildContext context, Function callback) {

    return ElevatedButton(
        style: myBoilerFunctionality.shellyPro2.switchStatus(ShellyPro2Id.both)
          ? buttonStyle(Colors.green, Colors.white)
          : buttonStyle(Colors.grey, Colors.white),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return BoilerHeatingOverview(boilerHeating: myBoilerFunctionality);
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
              myBoilerFunctionality.device.name,
              style: const TextStyle(
                fontSize: 12)),
            _heaterIcon(myBoilerFunctionality.shellyPro2),
          ]),

    );
  }

  @override
  String viewName() {
    return 'Lämmityskattila';
  }

}

Icon _heaterIcon(ShellyPro2 myShelly) {
  return Icon(
         Icons.thermostat,
          size: 50,
          color: myShelly.switchStatus(ShellyPro2Id.id0)
            ? Colors.yellowAccent
            : Colors.white,
  );
}

