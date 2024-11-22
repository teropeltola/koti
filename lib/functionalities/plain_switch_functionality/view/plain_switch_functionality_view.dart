
import 'package:flutter/material.dart';
import 'package:koti/devices/shelly/json/switch_get_status.dart';

import '../../../look_and_feel.dart';
import '../../functionality/functionality.dart';
import '../../functionality/view/functionality_view.dart';
import '../plain_switch_functionality.dart';

class PlainSwitchFunctionalityView extends FunctionalityView {

  late PlainSwitchFunctionality mySwitch;


  @override
  String viewName() {
    return PlainSwitchFunctionality.functionalityName;
  }

  @override
  String subtitle() {
    return mySwitch.myDevice().name;
  }


  PlainSwitchFunctionalityView(dynamic myFunctionality) : super(myFunctionality) {
    mySwitch = myFunctionality as PlainSwitchFunctionality;
  }

  PlainSwitchFunctionalityView.fromJson(Map<String, dynamic> json) : super(allFunctionalities.noFunctionality()) {
    super.fromJson(json);
    mySwitch = myFunctionality as PlainSwitchFunctionality;
  }


  @override
  Widget gridBlock(BuildContext context, Function callback) {

    return ElevatedButton(
        style: mySwitch.switchStatusPeak()
          ? buttonStyle(Colors.green, Colors.white)
          : buttonStyle(Colors.grey, Colors.white),
        onPressed: () async {
          await mySwitch.toggle();
          callback();
        },
        onLongPress: () async {
          await _switchStatistics(context, mySwitch, 0);

        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          Text(
          mySwitch.myDevice().name,
          style: const TextStyle(
          fontSize: 12)),
          Icon(
            mySwitch.switchStatusPeak()
            ? Icons.power
            : Icons.power_off,
            size: 50,
            color:
              mySwitch.switchStatusPeak()
                ? Colors.yellowAccent
                : Colors.white,

          )
            ])
    );
  }
}

Future <void> _switchStatistics(BuildContext context, PlainSwitchFunctionality mySwitch, int switchNumber) async {

  // TODO: THIS IS NOT WORKING ANYMORE - NEEDS TO BE RETHINKED
  /*
  ShellySwitchStatus status = await mySwitch.shellyTimerSwitch.switchGetStatus(switchNumber);
  String header = status.output ? 'Kytkin $switchNumber päällä' : 'Kytkin $switchNumber suljettu';
  String body = status.id == -1 ? 'ei statusta' : status.toString();
  await informMatterToUser(context, header, body );

   */
}

