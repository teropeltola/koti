
import 'package:flutter/material.dart';

import '../../functionality/functionality.dart';
import '../../functionality/view/functionality_view.dart';
import '../plain_switch_functionality.dart';

class PlainSwitchFunctionalityView extends FunctionalityView {

  late PlainSwitchFunctionality mySwitch;

  PlainSwitchFunctionalityView(dynamic myFunctionality) : super(myFunctionality) {
    mySwitch = myFunctionality as PlainSwitchFunctionality;
  }

  PlainSwitchFunctionalityView.fromJson(Map<String, dynamic> json) : super(allFunctionalities.noFunctionality()) {
    super.fromJson(json);
  }


  @override
  Widget gridBlock(BuildContext context, Function callback) {

    return ElevatedButton(
        style: mySwitch.switchStatus()
          ? buttonStyle(Colors.green, Colors.white)
          : buttonStyle(Colors.grey, Colors.white),
        onPressed: () {
          mySwitch.switchToggle();
          callback();
        },
        onLongPress: () {

        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          Text(
          mySwitch.device.name,
          style: const TextStyle(
          fontSize: 12)),
          Icon(
            mySwitch.switchStatus()
            ? Icons.power
            : Icons.power_off,
            size: 50,
            color:
              mySwitch.switchStatus()
                ? Colors.yellowAccent
                : Colors.white,

          )
            ])
    );
  }
}

