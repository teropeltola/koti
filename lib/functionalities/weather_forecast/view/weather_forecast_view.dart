
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';

import '../../functionality/functionality.dart';
import '../../functionality/view/functionality_view.dart';
import '../weather_forecast.dart';

class WeatherForecastView extends FunctionalityView {

  late WeatherForecast myForecast;
  WeatherForecastView(dynamic myFunctionality) : super(myFunctionality) {
    myForecast = myFunctionality as WeatherForecast;
  }

  WeatherForecastView.fromJson(Map<String, dynamic> json) : super(allFunctionalities.noFunctionality()) {
    super.fromJson(json);
    myForecast = myFunctionality as WeatherForecast;
  }

  @override
  Widget gridBlock(BuildContext context, Function callback) {

    return ElevatedButton(
        style:buttonStyle(Colors.lightBlue, Colors.white),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return WeatherPageCollection(weatherForecast: myForecast);
            },
          ));
          callback();

          //if (!context.mounted) return;
          //Navigator.pop(context);

        },
        onLongPress: () {
        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                  myForecast.locationName,
                  style: const TextStyle(
                      fontSize: 12)),
              Icon(
                Icons.cloud,
                size: 50,
                color: Colors.white,
              ),
              Text(myForecast.currentTemperature() + " $celsius")
            ])
    );
  }

  @override
  String viewName() {
    return 'Säätila';
  }

  @override
  String subtitle() {
    return myForecast.locationName;
  }


}

const String networkServiceProblemInfo = 'Emme saa yhteyttä säätietoihin, joten tätä palvelua ei voi käyttää.';


const weatherUrl2 = 'https://foreca.fi/Finland/Helsinki/Tapanila';
const weatherUrl3 =
"https://weather.com/fi-FI/weather/today/l/f06a0a973cc86361c99cb45d2879d2049e5b25f0984d98c4459c0ad8a31ae1c4";
const weatherUrl = "https://saaennuste.fi/?place=Central%20Helsinki";

class WeatherExplorer extends StatelessWidget {
  final String title;
  final String weatherUrl;
  const WeatherExplorer( {Key? key,
    required this.title,
    required this.weatherUrl
  }) : super(key: key);

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
        title: appIconAndTitle(myEstates.currentEstate().name, this.title),
      ),// new line
      body: WebViewWidget( controller: controller ),
    );
  }
}

class WeatherPageCollection extends StatelessWidget {
  final WeatherForecast weatherForecast;
  const WeatherPageCollection( {Key? key, required this.weatherForecast
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = PageController(
    );
    List<Widget> widgets = List.generate(weatherForecast.weatherServices.length, (int index) => WeatherExplorer(
      title: weatherForecast.weatherServices[index].title(),
      weatherUrl: weatherForecast.weatherServices[index].weatherPage(),
    ));
    return PageView(
      controller: controller,
      children: widgets
      ,
    );
  }
}


