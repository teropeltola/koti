import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:koti/devices/ouman/ouman_device.dart';
import 'package:koti/devices/shelly_timer_switch/shelly_timer_switch.dart';
import 'package:koti/devices/wlan/active_wifi_name.dart';
import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';
import 'package:provider/provider.dart';

import '../../devices/device/device.dart';
import '../../devices/device/view/edit_device_view.dart';
import '../../devices/porssisahko/porssisahko.dart';
import '../../devices/shelly/shelly.dart';
import '../../devices/shelly/shelly_scan.dart';
import '../../functionalities/electricity_price/electricity_price.dart';
import '../../functionalities/electricity_price/view/electricity_price_view.dart';
import '../../functionalities/heating_system_functionality/heating_system.dart';
import '../../functionalities/heating_system_functionality/view/heating_system_view.dart';
import '../../functionalities/tesla_functionality/view/tesla_functionality_view.dart';
import '../../functionalities/weather_forecast/view/weather_forecast_view.dart';
import '../../functionalities/weather_forecast/weather_forecast.dart';
import '../estate.dart';
import '../../look_and_feel.dart';
import '../../main.dart';

class AddNewEstateView extends StatefulWidget {
  const AddNewEstateView({Key? key}) : super(key: key);

  @override
  _AddNewEstateViewState createState() => _AddNewEstateViewState();
}

class _AddNewEstateViewState extends State<AddNewEstateView> {
  Estate newEstate = Estate();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  final myEstateNameController = TextEditingController();
  _Services services = _Services();

  @override
  void initState() {
    super.initState();

    newEstate.init('','e1',activeWifiName.activeWifiName);

    services.init(newEstate);
    List <String> shellyServices = shellyScan.listPossibleServices();
    getShellyServices(shellyServices);

    refresh();
  }

  Icon shellyIcon(bool deviceExists) {
  if (deviceExists) {
    return (const Icon(Icons.check,
                color: Colors.green, size: 40));
  }
  else {
    return const Icon(Icons.add_home_work,
              color: Colors.black, size: 40);
  }
  }

  void getShellyServices(List<String> shellyServiceNames) {

    for (int i=0; i<shellyServiceNames.length; i++) {
      services.add(
        _ServiceItem(
          shellyServiceNames[i],
          newEstate.deviceExists(shellyServiceNames[i]),
          addPlugIn));
    }
  }


  void refresh() {
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeWifi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Estate>(
      builder: (context, estate, childNotUsed) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Palaa takaisin lisäämättä uutta asuntoa',
                onPressed: () async {
                  // check if the user wants to cancel all the changes
                  bool doExit = await askUserGuidance(context,
                      'Poistuttaessa uusi kohde ei säily.',
                      'Haluatko poistua lisäyssivulta ?'
                      );
                  if (doExit) {
                    Navigator.of(context).pop();
                  }
                }),
            title: appTitle('uusi asunto'),
          ), // new line
          body: SingleChildScrollView(
              child: Column(children: <Widget>[
                Container(
                margin: myContainerMargin,
                padding: myContainerPadding,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Asunnon tiedot'), //k
                  child: Column(children: <Widget>[
                    TextField(
                        key: const Key('estateName'),
                        decoration: const InputDecoration(
                          labelText: 'asunnon nimi',
                          hintText: 'kirjoita tähän asunnolle nimi, esim. koti',
                        ),
                        focusNode: _focusNode,
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        controller: myEstateNameController,
                        maxLines: 1,
                        onChanged: (String newText) {
                          newEstate.name = newText;
                        },
                        onEditingComplete: () {
                          _focusNode.unfocus();
                        }),
                    const Text(''),
                    TextFormField(
                        key: const Key('wifiName'),
                        decoration: const InputDecoration(
                          labelText: 'wifi-verkon nimi (oletuksena nykyinen)',
                          hintText: 'oletusarvona on nykyinen wifi',
                        ),
                        focusNode: _focusNodeWifi,
                        initialValue: activeWifiName.activeWifiName,
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        maxLines: 1,
                        onChanged: (String newWifi) {
                          newEstate.myWifiDevice.changeWifiName(newWifi);
                          setState(() { });
                        },
                        onEditingComplete: () {
                          _focusNodeWifi.unfocus();
                        }),
                  ]),
                ),
              ),
              Container(
                  margin: myContainerMargin,
                  padding: myContainerPadding,
                  child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Asuntoon liitettävät toiminnot'),
                      child:
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: services.itemCount(),
                                  itemBuilder: (context, index) => Card(
                                    elevation: 6,
                                    margin: const EdgeInsets.all(10),
                                      child: ListTile(
                                        title: Text(services.items[index].serviceName),
                                        trailing: IconButton(
                                          icon: services.icon(index),
                                          tooltip: 'Lisää asunnon laitteisiin',
                                          onPressed: () async {
                                            if (services.added(index)) {

                                            }
                                            else {
                                              services.setAdded(index);
                                              Function addingFunction = services.addingFunction(index);
                                              Functionality functionality = await addingFunction(newEstate,services.items[index].serviceName);
                                              await functionality.editWidget(context,newEstate, functionality, functionality.device);
                                            }

                                            refresh();
                                            setState(() {});
                                              })
                                      )
                                  )
                              )
                  )
              ),
                      Container(
                          margin: myContainerMargin,
                          padding: myContainerPadding,
                          child: Tooltip(
                              message:
                              'Paina tästä tallettaessa havainto ja poistu näytöltä',
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    backgroundColor: mySecondaryColor,
                                    side: const BorderSide(
                                        width: 2, color: mySecondaryColor),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                    elevation: 10),
                                onPressed: () async {
                                  myEstates.addEstate(newEstate);
                                  myEstates.pushCurrent(newEstate);
                                  await myEstates.store();
                                  showSnackbarMessage('kohde lisätty!');
                                  Navigator.pop(context, true);
                                },
                                child: const Text(
                                  'Valmis',
                                  maxLines: 1,
                                  style: TextStyle(color: mySecondaryFontColor),
                                  textScaleFactor: 2.2,
                                ),
                              ))),
                      ])
              )
          );
      }
    );
  }
}

class _ServiceItem {
  String serviceName = '';
  late Function addFunction;
  Icon serviceIcon = Icon(Icons.abc);
  bool added = false;
  bool dataEditing = false;

  _ServiceItem(String initServiceName, bool initAdded, Function initAddFunction, {bool editData = false}) {
    serviceName = initServiceName;
    added = initAdded;
    dataEditing = editData;
    addFunction = initAddFunction;
  }
}

class _Services {
  List <_ServiceItem> items = [];

  void init(Estate estate) {
    clear();
    addConstServices(estate);
  }

  int itemCount() {
    return items.length;
  }

  void addConstServices(Estate estate) {

    items.add(_ServiceItem('Sähkön hinta', estate.deviceExists('Sähkön hinta'), addElectricityPrice, editData: true));
    items.add(_ServiceItem('Säätila', estate.deviceExists('Säätila'), addWeatherForecast));
    items.add(_ServiceItem('Lämmitys', estate.deviceExists('Lämmitys'), addHeatingSystem));
    items.add(_ServiceItem('Tesla', estate.deviceExists('Tesla'), addTesla));
  }

  void clear() {
    items.clear();
  }

  void add(_ServiceItem item) {
    items.add(item);
  }

  void setAdded(int index) {
    items[index].added = true;
  }

  bool added(int index) {
    return (items[index].added);
  }

  bool editData(int index) {
    return (items[index].dataEditing);
  }

  Function addingFunction(int index) {
    return (items[index].addFunction);
  }

  Icon icon(int index) {
    if (items[index].added) {
      return (const Icon(Icons.check,
          color: Colors.green, size: 40));
    }
    else {
      return const Icon(Icons.add_home_work,
          color: Colors.black, size: 40);
    }
  }
}

Future<PlainSwitchFunctionality> addPlugIn(Estate estate, String serviceName) async {
  ShellyTimerSwitch newDevice = ShellyTimerSwitch();
  PlainSwitchFunctionality shellyFunctionality = PlainSwitchFunctionality();
  shellyFunctionality.pair(newDevice);
  ResolvedBonsoirService bSData = shellyScan.resolveServiceData(serviceName);
  if (bSData.name != '') {
    newDevice.initFromScan(bSData);
  }
  return shellyFunctionality;
}

Future<OumanDevice> getOuman(Estate estate) async {

  //check if I already have one
  int index = estate.devices.indexWhere((e){return e.runtimeType == OumanDevice;} );
  if (index >= 0) {
    return estate.devices[index] as OumanDevice;
  }
  else {
    OumanDevice ouman = OumanDevice();
    estate.addDevice(ouman);
    await ouman.init();
    return ouman;
  }
}

Future<ElectricityPrice> addElectricityPrice(Estate estate, String serviceName) async {
  Porssisahko spot = Porssisahko();
  spot.name = 'spot';
  spot.id = 'spot-pörssisähkö';
  estate.addDevice(spot);
  await spot.init();

  ElectricityPrice ep = ElectricityPrice();
  ep.pair(spot);
  estate.addFunctionality(ep);
  estate.addView(ElectricityGridBlock(ep));
  await ep.init();

  return ep;
}

Future<WeatherForecast> addWeatherForecast(Estate estate, String serviceName) async {
  OumanDevice ouman = await getOuman(estate);
  WeatherForecast myForecast = WeatherForecast();
  myForecast.pair(ouman);
  estate.addFunctionality(myForecast);
  await myForecast.init();
  estate.addView(WeatherForecastView(myForecast));
  return myForecast;
}

Future<HeatingSystem> addHeatingSystem(Estate estate, String serviceName) async {
  OumanDevice ouman = await getOuman(estate);
  HeatingSystem heatingSystem = createNewHeatingSystem(ouman);
  estate.addFunctionality(heatingSystem);
  estate.addView(HeatingSystemView(heatingSystem));
  await heatingSystem.init();
  return heatingSystem;
}

Future<Functionality> addTesla(Estate estate, String serviceName) async {
  Functionality teslaFunctionality = Functionality();
  Device teslaDevice = Device();
  teslaDevice.id = 'Tesla id';
  teslaDevice.name = 'Tesla';
  teslaFunctionality.pair(teslaDevice);

  estate.addView(
      TeslaFunctionalityView(teslaFunctionality));
  return (teslaFunctionality);
}