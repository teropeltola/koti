import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koti/devices/weather_service_provider/weather_service_provider.dart';
import 'package:koti/functionalities/weather_forecast/view/weather_forecast_view.dart';
import 'package:koti/interfaces/weather_forecast_provider_data.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../../../view/ready_widget.dart';
import '../weather_forecast.dart';

class _WeatherServiceItem {
  String serviceName = '';
  String webAddress = '';
  String title = '';

  _WeatherServiceItem(this.serviceName, this.webAddress, this.title);
}

class _WeatherServices {
  List <_WeatherServiceItem> items = [];

  void init(WeatherForecast weatherForecast) {
    clear();
    for (var w in weatherForecast.weatherServices) {
      items.add(_WeatherServiceItem(w.name, w.weatherPage(), w.title()));
    }
  }

  int itemCount() {
    return items.length;
  }

  void clear() {
    items.clear();
  }

  void add(_WeatherServiceItem item) {
    items.add(item);
  }

  void delete(int index) {
    items.removeAt(index);;
  }

  String serviceName(int index) {
    return items[index].serviceName;
  }

  String locationName(int index) {
    return items[index].serviceName;
  }

}


class EditWeatherForecastView extends StatefulWidget {
  final bool createNew;
  final Estate estate;
  final WeatherForecast originalWeatherForecast;

  const EditWeatherForecastView({Key? key,
    required this.createNew,
    required this.estate,
    required this.originalWeatherForecast}) : super(key: key);
  @override
  _EditWeatherForecastViewState createState() => _EditWeatherForecastViewState();
}

class _EditWeatherForecastViewState extends State<EditWeatherForecastView> {
  final FocusNode _focusNode = FocusNode();
  final myLocationNameController = TextEditingController();

  late WeatherForecast weatherForecast;

  WeatherForecastProviderData availableServices = WeatherForecastProviderData();

  @override
  void initState() {
    super.initState();
    if (widget.createNew) {
      weatherForecast = WeatherForecast();
    }
    else {
      weatherForecast = widget.originalWeatherForecast.clone();
    }
    myLocationNameController.text = weatherForecast.locationName;

    availableServices.get();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();

  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Palaa takaisin tallentamatta muutoksia',
              onPressed: () async {
                // check if the user wants to cancel all the changes
                bool doExit = await askUserGuidance(context,
                    'Poistuttaessa muutokset eivät säily.',
                    'Haluatko poistua muutossivulta ?'
                );
                if (doExit) {
                  Navigator.of(context).pop();
                }
              }),
          title: appIconAndTitle('', 'muokkaa sääsivuja'),
        ), // new line
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
              Container(
                margin: myContainerMargin,
                padding: myContainerPadding,
                child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Paikkatieto'), //k
                    child: Column(children: <Widget>[
                      TextField(
                          key: const Key('locationName'),
                          decoration: const InputDecoration(
                            labelText: 'paikkanimi',
                            hintText: 'kirjoita tähän paikkakunnan nimi, esim. "Helsinki"',
                          ),
                          focusNode: _focusNode,
                          autofocus: false,
                          textInputAction: TextInputAction.done,
                          controller: myLocationNameController,
                          maxLines: 1,
                          onChanged: (String newText) {
                            weatherForecast.locationName = newText;
                            availableServices.setLocationValue(newText);
                            setState(() { });
                          },
                          onEditingComplete: () {
                            _focusNode.unfocus();
                          }),
                    ])
                ),
              ),
              Container(
                  margin: myContainerMargin,
                  padding: myContainerPadding,
                  child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Käytetyt sääennustepalvelut'),
                      child:
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: weatherForecast.weatherServices.length,
                          itemBuilder: (context, index) => Card(
                              elevation: 6,
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                  title: Text(weatherForecast.weatherServices[index].name),
                                  subtitle: Text(weatherForecast.weatherServices[index].locationName),
                                  trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      tooltip: 'poista sääpalvelu',
                                      onPressed: () async {
                                        var weatherService = weatherForecast.weatherServices.removeAt(index);
                                        weatherForecast.connectedDevices.remove(weatherService);
                                        weatherService.dispose();
                                        refresh();
                                      })
                              )
                          )
                      )
                  )
              ),
              Container(
                  margin: myContainerMargin,
                  //padding: myContainerPadding,
                  child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Mahdollisia sääpalveluita'),
                      child:
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: availableServices.itemCount(),
                          itemBuilder: (context, index) => Card(
                              elevation: 6,
                              margin: const EdgeInsets.all(1),
                              child: ExpansionTile(
                                  title: Text(availableServices.items[index].name),
                                  //initiallyExpanded: true,
                                  trailing: IconButton(
                                      icon: Icon(Icons.add),
                                      tooltip: 'Lisää sääpalvelu',
                                      onPressed: () async {
                                        WeatherServiceProvider weatherServiceProvider =
                                            WeatherServiceProvider(
                                              availableServices.items[index].internetPageAddress(),
                                              availableServices.items[index].title(),
                                              availableServices.locationName(index));
                                        weatherServiceProvider.name = availableServices.items[index].name;
                                        weatherForecast.pair(weatherServiceProvider);
                                        weatherForecast.weatherServices.add(weatherServiceProvider);
                                        refresh();
                                        setState(() {});
                                      }),
                                children: availableServices.items[index].parameterListWidget(),

                              )
                          )
                      )
                  )
              ),
              readyWidget(() async {
                if (weatherForecast.locationName == '') {
                  informMatterToUser(context,'Paikan nimi ei voi olla tyhjä', 'Korjaa nimi!');
                }
                else if (weatherForecast.weatherServices.isEmpty) {
                  informMatterToUser(context,'Sinulla ei ole yhtään sääpalvelua määritelty', 'Lisää sääpalvelu!');
                }
                else {
                  if (widget.createNew) {
                    // OumanDevice ouman = await getOuman(context, estate);
                    // todo: create temperature device that connects all temp sources
                    // weatherForecast.pair(ouman);
                  }
                  else {
                    for (var weatherService in widget.originalWeatherForecast.weatherServices) {
                      widget.estate.removeDevice(weatherService.id);
                    }
                    widget.estate.removeView(widget.originalWeatherForecast.myView());
                    widget.estate.removeFunctionality(widget.originalWeatherForecast);
                  }
                  widget.estate.addFunctionality(weatherForecast);
                  for (var weatherService in weatherForecast.weatherServices) {
                    widget.estate.addDevice(weatherService);
                  }
                  widget.estate.addView(WeatherForecastView(weatherForecast));

                  // weatherForecast.
                  showSnackbarMessage(
                      'Muutokset talletettu!');
                  Navigator.pop(context, true);
                }

              })
            ])
        )
    );
  }
}

