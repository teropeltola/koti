
import 'package:flutter/material.dart';
import 'package:koti/devices/weather_service_provider/weather_service_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';

import '../../functionality/view/functionality_view.dart';
import '../weather_forecast.dart';

class WeatherForecastView extends FunctionalityView {

  WeatherForecast myForecast() {
    return myFunctionality() as WeatherForecast;
  }

  WeatherForecastView();

  WeatherForecastView.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }

  @override
  Widget gridBlock(BuildContext context, Function callback) {

    return ElevatedButton(
        style:buttonStyle(Colors.lightBlue, Colors.white),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return WeatherPageCollection(weatherForecast: myForecast());
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
                  myForecast().locationName,
                  style: const TextStyle(
                      fontSize: 12)),
              const Icon(
                Icons.cloud,
                size: 50,
                color: Colors.white,
              ),
              Text("${myForecast().currentTemperature()} $celsius")
            ])
    );
  }

  @override
  String viewName() {
    return 'Säätila';
  }

  @override
  String subtitle() {
    return myForecast().locationName;
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
              bool isForRequestedPage = error.isForMainFrame ?? true;
              if (isForRequestedPage) {
                await informMatterToUser(context, networkServiceProblemInfo,
                    'Voit muuten käyttää appia!');
                Navigator.of(context).pop();
              }
            }
        ),
      )
      ..loadRequest(Uri.parse(weatherUrl));
    return Scaffold(
      appBar: AppBar(
        title: appIconAndTitle(myEstates.currentEstate().name, title),
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
    List<Widget> widgets = List.generate(weatherForecast.connectedDevices.length, (int index) => WeatherExplorer(
      title: (weatherForecast.connectedDevices[index] as WeatherServiceProvider).title(),
      weatherUrl: (weatherForecast.connectedDevices[index] as WeatherServiceProvider).weatherPage(),
    ));
    return PageView(
      controller: controller,
      children: widgets
      ,
    );
  }
}


