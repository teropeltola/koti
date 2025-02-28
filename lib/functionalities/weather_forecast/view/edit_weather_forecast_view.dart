import 'package:flutter/material.dart';
import 'package:koti/devices/weather_service_provider/weather_service_provider.dart';
import 'package:koti/interfaces/weather_forecast_provider_data.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../../../view/interrupt_editing_widget.dart';
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
    for (var device in weatherForecast.connectedDevices) {
      WeatherServiceProvider w = device as WeatherServiceProvider;
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
    items.removeAt(index);
  }

  String serviceName(int index) {
    return items[index].serviceName;
  }

  String locationName(int index) {
    return items[index].serviceName;
  }

}


class EditWeatherForecastView extends StatefulWidget {
  final Estate estate;
  final WeatherForecast originalWeatherForecast;
  final Function callback;

  const EditWeatherForecastView({Key? key,
    required this.estate,
    required this.originalWeatherForecast,
    required this.callback}) : super(key: key);
  @override
  _EditWeatherForecastViewState createState() => _EditWeatherForecastViewState();
}

class _EditWeatherForecastViewState extends State<EditWeatherForecastView> {
  bool createNew = false;
  final FocusNode _focusNode = FocusNode();
  final myLocationNameController = TextEditingController();

  late WeatherForecast weatherForecast;

  WeatherForecastProviderData availableServices = WeatherForecastProviderData();

  @override
  void initState() {
    super.initState();
    // todo: hack - this way we know that we are creating a new functionality
    createNew = widget.originalWeatherForecast.locationName == '';

    if (createNew) {
      weatherForecast = widget.originalWeatherForecast;
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
          leading: interruptEditingWidget(context, () async {
            weatherForecast.remove();
            widget.callback();
          }),
          title: appIconAndTitle('muokkaa', 'sääsivuja'),
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
                          itemCount: weatherForecast.connectedDevices.length,
                          itemBuilder: (context, index) => Card(
                              elevation: 6,
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                  title: Text(weatherForecast.connectedDevices[index].name),
                                  subtitle: Text((weatherForecast.connectedDevices[index] as WeatherServiceProvider).locationName),
                                  trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'poista sääpalvelu',
                                      onPressed: () async {
                                        var weatherService = weatherForecast.connectedDevices.removeAt(index) as WeatherServiceProvider;
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
                                      icon: const Icon(Icons.add),
                                      tooltip: 'Lisää sääpalvelu',
                                      onPressed: () async {
                                        WeatherServiceProvider weatherServiceProvider =
                                            WeatherServiceProvider(
                                              availableServices.items[index].internetPageAddress(),
                                              availableServices.items[index].title(),
                                              availableServices.locationName(index));
                                        weatherServiceProvider.name = availableServices.items[index].name;
                                        weatherForecast.pair(weatherServiceProvider);
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
                else if (weatherForecast.connectedDevices.isEmpty) {
                  informMatterToUser(context,'Sinulla ei ole yhtään sääpalvelua määritelty', 'Lisää sääpalvelu!');
                }
                else {
                  // remove the old version
                  if (! createNew) {
                    for (var weatherService in widget.originalWeatherForecast.connectedDevices) {
                      widget.estate.removeDevice(weatherService.id);
                    }
                    widget.estate.removeFunctionality(widget.originalWeatherForecast);
                    widget.originalWeatherForecast.remove();
                  }
                  // create new version
                  // note: we don't call init because everything has been created already
                  widget.estate.addFunctionality(weatherForecast);
                  for (var weatherService in weatherForecast.connectedDevices) {
                    widget.estate.addDevice(weatherService);
                  }

                  // weatherForecast.
                  showSnackbarMessage('Muutokset talletettu!');
                  Navigator.pop(context, true);
                }

              })
            ])
        )
    );
  }
}


Future<bool> createWeatherForecastSystem(BuildContext context, Estate estate) async {

  bool success = await Navigator.push(
      context, MaterialPageRoute(
    builder: (context) {
      return EditWeatherForecastView(
          estate: estate,
          originalWeatherForecast: WeatherForecast(), // create a new one
          callback: () {}
      );
    },
  ));
  return success;
}


