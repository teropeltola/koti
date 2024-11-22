
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../devices/ouman/ouman_device.dart';
import '../../../logic/observation.dart';
import '../../../look_and_feel.dart';

import '../../functionality/functionality.dart';
import '../../functionality/view/functionality_view.dart';
import 'heating_overview.dart';
import '../heating_system.dart';

class HeatingSystemView extends FunctionalityView {

  HeatingSystemView(dynamic myFunctionality) : super(myFunctionality) {
  }

  ButtonStyle myButtonStyle() {
    // TODO: Tässä pitäisi laskea hälytystaso kaikille laitteille
    ObservationLevel observationLevel = (myFunctionality as HeatingSystem).myOuman().observationLevel();
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
              //HeatingSystem heatingSystem = myFunctionality as HeatingSystem;
              //return HeatingOverview(heatingSystem:heatingSystem);
              return HeatingOverview(heatingSystem:myFunctionality, callback: callback);
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
                  'Lämmitys',
                  style: const TextStyle(
                      fontSize: 12)),
              Icon(
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

  HeatingSystemView.fromJson(Map<String, dynamic> json) : super(allFunctionalities.noFunctionality()) {
    //super.fromJson(json);
    myFunctionality = allFunctionalities.findFunctionality(json['myFunctionalityId'] ?? '') as HeatingSystem;
  }

  @override
  String viewName() {
    return 'Lämmitys';
  }

  @override
  String subtitle() {
    Functionality functionality = myFunctionality as Functionality;
    return functionality.connectedDevices[0].name;
  }


}
/*
const String networkServiceProblemInfo = 'Emme saa yhteyttä säätietoihin, joten tätä palvelua ei voi käyttää.';


const weatherUrl2 = 'https://foreca.fi/Finland/Helsinki/Tapanila';
const weatherUrl3 =
"https://weather.com/fi-FI/weather/today/l/f06a0a973cc86361c99cb45d2879d2049e5b25f0984d98c4459c0ad8a31ae1c4";
const weatherUrl = "https://saaennuste.fi/?place=Central%20Helsinki";

class WeatherExplorer extends StatelessWidget {
  const WeatherExplorer({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
            onWebResourceError: (WebResourceError error) async {
              await informMatterToUser(context, networkServiceProblemInfo,
                  'Voit muuten käyttää appia!');
              Navigator.of(context).pop();
            }
        ),
      )
      ..loadRequest(Uri.parse(weatherUrl));
    return Scaffold(
      appBar: AppBar(
        title: appIconAndTitle('','Sää'),
      ),// new line
      body: WebViewWidget( controller: controller ),
    );
  }
}
*/