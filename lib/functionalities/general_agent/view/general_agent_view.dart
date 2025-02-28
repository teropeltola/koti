
import 'package:flutter/material.dart';
import '../../functionality/functionality.dart';
import '../../functionality/view/functionality_view.dart';
import '../general_agent.dart';
import 'general_agent_overview.dart';

class GeneralAgentView extends FunctionalityView {

  GeneralAgentView();

  ButtonStyle myButtonStyle() {
    // TODO: Tässä pitäisi laskea hälytystaso kaikille laitteille
    return buttonStyle(Colors.green, Colors.white);
  }

  @override
  Widget gridBlock(BuildContext context, Function callback) {

    return ElevatedButton(
        style:myButtonStyle(),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              //HeatingSystem heatingSystem = myFunctionality as HeatingSystem;
              //return HeatingOverview(heatingSystem:heatingSystem);
              return GeneralAgentOverview( generalAgent: myFunctionality as GeneralAgent, callback: callback);
            },
          ));
          callback();

        },
        onLongPress: () {
        },
        child: const Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                  'Lämmitys',
                  style: TextStyle(
                      fontSize: 12)),
              Icon(
                Icons.cabin,
                size: 50,
                color: Colors.white,
              ),
            ])
    );
  }

  GeneralAgentView.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }

  @override
  String viewName() {
    return 'Yleinen';
  }

  @override
  String subtitle() {
    Functionality functionality = myFunctionality as Functionality;
    return functionality.connectedDevices[0].name;
  }
}
