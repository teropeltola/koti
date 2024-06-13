import 'package:flutter/material.dart';
import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';
import 'package:koti/devices/ouman/ouman_device.dart';
import 'package:koti/devices/wlan/active_wifi_name.dart';
import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/operation_modes/view/edit_operation_mode_view.dart';
import 'package:koti/operation_modes/view/operation_modes_selection_view.dart';
import 'package:provider/provider.dart';

import '../../devices/device/device.dart';
import '../../devices/device/view/edit_device_view.dart';
import '../../devices/porssisahko/porssisahko.dart';
import '../../devices/shelly/shelly_device.dart';
import '../../devices/shelly/shelly_scan.dart';
import '../../devices/shelly/view/edit_shelly_device_view.dart';
import '../../functionalities/air_heat_pump_functionality/air_heat_pump.dart';
import '../../functionalities/air_heat_pump_functionality/view/air_heat_pump_view.dart';
import '../../functionalities/electricity_price/electricity_price.dart';
import '../../functionalities/electricity_price/view/edit_electricity_view.dart';
import '../../functionalities/electricity_price/view/electricity_price_view.dart';
import '../../functionalities/heating_system_functionality/heating_system.dart';
import '../../functionalities/heating_system_functionality/view/heating_system_view.dart';
import '../../functionalities/tesla_functionality/tesla_functionality.dart';
import '../../functionalities/tesla_functionality/view/tesla_functionality_view.dart';
import '../../functionalities/weather_forecast/view/weather_forecast_view.dart';
import '../../functionalities/weather_forecast/weather_forecast.dart';
import '../../operation_modes/conditional_operation_modes.dart';
import '../../operation_modes/hierarcical_operation_mode.dart';
import '../../operation_modes/operation_modes.dart';
import '../../operation_modes/view/conditional_option_list_view.dart';
import '../estate.dart';
import '../../look_and_feel.dart';
import '../../main.dart';

class EditEstateView extends StatefulWidget {
   String estateName;
   EditEstateView({Key? key, required this.estateName}) : super(key: key);

  @override
  _EditEstateViewState createState() => _EditEstateViewState();
}

class _EditEstateViewState extends State<EditEstateView> {
  Estate editedEstate = Estate();

  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  final myEstateNameController = TextEditingController();
  _Services availableServices = _Services();
  List<Functionality> existingServices = [];

  @override
  void initState() {
    super.initState();

    if (widget.estateName == '') {
      addElectricityPriceWithoutEditing(editedEstate);
    }
    else {
      editedEstate = myEstates.estate(widget.estateName).clone();
    }
    availableServices.init(editedEstate);
    List <String> shellyServices = shellyScan.listPossibleServices();
    getShellyServices(shellyServices);

    myEstateNameController.text = editedEstate.name;

    refresh();
  }

  void updateExistingServices() {
    existingServices.clear();
    editedEstate.features.forEach((e) {
      if (e.runtimeType.toString() != 'ElectricityPrice') {
        existingServices.add(e);
      }
    }
    );
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
      availableServices.add(
        _ServiceItem(
          shellyServiceNames[i],
          editedEstate.deviceExists(shellyServiceNames[i]),
          addPlugIn));
    }
  }

  void refresh() {
    updateExistingServices();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeWifi.dispose();
    super.dispose();
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
            title: appTitle('muokkaa asuntoa'),
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
                          editedEstate.name = newText;
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
                          editedEstate.myWifiDevice.changeWifiName(newWifi);
                          setState(() { });
                        },
                        onEditingComplete: () {
                          _focusNodeWifi.unfocus();
                        }),
                    const Text(''),
                    EditElectricityShortView(
                      estate: editedEstate
                    )
                  ])
                ),
              ),
              operationModeHandling(
                  context,
                  editedEstate,
                  editedEstate.operationModes,
                  [HierarchicalOperationMode().typeName(), dynamicOperationModeText],
                  _estateOperationModes,
                  (){setState(() { });}),
                Container(
                    margin: myContainerMargin,
                    padding: myContainerPadding,
                    child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Asunnon olemassaolevat toiminnot'),
                        child:
                        ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: existingServices.length,
                            itemBuilder: (context, index) => Card(
                                elevation: 6,
                                margin: const EdgeInsets.all(10),
                                child: ListTile(
                                    title: Text(existingServices[index].myView().viewName()),
                                    subtitle: Text(existingServices[index].myView().subtitle()),
                                    trailing: IconButton(
                                        icon: Icon(Icons.edit),
                                        tooltip: 'muokkaa toimintoa',
                                        onPressed: () async {
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
                  child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Asuntoon liitettävät toiminnot'),
                      child:
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: availableServices.itemCount(),
                                  itemBuilder: (context, index) => Card(
                                    elevation: 6,
                                    margin: const EdgeInsets.all(10),
                                      child: ListTile(
                                        title: Text(availableServices.items[index].serviceName),
                                        trailing: IconButton(
                                          icon: availableServices.icon(index),
                                          tooltip: 'Lisää asunnon laitteisiin',
                                          onPressed: () async {
                                            if (availableServices.added(index)) {

                                            }
                                            else {
                                              availableServices.setAdded(index);
                                              Function addingFunction = availableServices.addingFunction(index);
                                              Functionality functionality = await addingFunction(context, editedEstate,availableServices.items[index].serviceName);
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
                                  // todo tee kattava tarkistus parametreistä
                                  if (editedEstate.name == '') {
                                    informMatterToUser(context,'Asunnon nimi ei voi olla tyhjä', 'Korjaa nimi!');
                                  }
                                  else {
                                    if (widget.estateName == '') {
                                      myEstates.addEstate(editedEstate);
                                      myEstates.setCurrent(editedEstate.id);
                                    }
                                    else {
                                      myEstates.setEstate(
                                          widget.estateName, editedEstate);
                                    }
                                    await myEstates.store();
                                    showSnackbarMessage(
                                        'Muutokset talletettu!');
                                    Navigator.pop(context, true);
                                  }
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

    items.add(_ServiceItem('Säätila', estate.deviceExists('Säätila'), addWeatherForecast));
    items.add(_ServiceItem('Lämmitys', estate.deviceExists('Lämmitys'), addHeatingSystem));
    items.add(_ServiceItem('Ilmalämpöpumppu', estate.deviceExists('Ilpo'), addMitsu));
    items.add(_ServiceItem('Auton lataus', estate.deviceExists('Tesla'), addTesla));
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

Future<Functionality> addPlugIn(BuildContext context, Estate estate, String serviceName) async {

  late Functionality shellyFunctionality;
  await Navigator.push(
      context, MaterialPageRoute(
    builder: (context) {
      return EditShellyDeviceView(
          estate: estate,
          shellyId: serviceName,
          callback: (newFunctionality) {shellyFunctionality = newFunctionality;});
    },
  ));

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

Future<MitsuHeatPumpDevice> getMitsu(Estate estate) async {

  //check if I already have one
  int index = estate.devices.indexWhere((e){return e.runtimeType == MitsuHeatPumpDevice;} );
  if (index >= 0) {
    return estate.devices[index] as MitsuHeatPumpDevice;
  }
  else {
    MitsuHeatPumpDevice mitsu = MitsuHeatPumpDevice();
    estate.addDevice(mitsu);
    await mitsu.init();
    return mitsu;
  }
}

Future <void> addElectricityPriceWithoutEditing(Estate estate) async {
  estate.init('',activeWifiName.activeWifiName);
  Porssisahko spot = Porssisahko();
  spot.name = 'spot';
  spot.id = 'spot-pörssisähkö';
  estate.addDevice(spot);

  ElectricityPrice electricityPrice = ElectricityPrice();
  electricityPrice.pair(spot);
  estate.addFunctionality(electricityPrice);
  estate.addView(ElectricityGridBlock(electricityPrice));

  // these are not waited in the initialization:
  await spot.init();
  await electricityPrice.init();

}

Future<ElectricityPrice> addElectricityPrice(BuildContext context, Estate estate, String serviceName) async {
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
  await ep.editWidget(context, estate, ep, spot);

  return ep;
}

Future<WeatherForecast> addWeatherForecast(BuildContext context, Estate estate, String serviceName) async {
  OumanDevice ouman = await getOuman(estate);
  WeatherForecast myForecast = WeatherForecast();
  myForecast.pair(ouman);
  estate.addFunctionality(myForecast);
  await myForecast.init();
  estate.addView(WeatherForecastView(myForecast));
  await myForecast.editWidget(context, estate, myForecast, ouman);

  return myForecast;
}

Future<HeatingSystem> addHeatingSystem(BuildContext context, Estate estate, String serviceName) async {
  OumanDevice ouman = await getOuman(estate);
  MitsuHeatPumpDevice mitsu = await getMitsu(estate);

  HeatingSystem heatingSystem = createNewHeatingSystem(ouman, mitsu);
  estate.addFunctionality(heatingSystem);
  estate.addView(HeatingSystemView(heatingSystem));
  await heatingSystem.init();
  await heatingSystem.editWidget(context, estate, heatingSystem, ouman);
  return heatingSystem;
}

Future<AirHeatPump> addMitsu(BuildContext context, Estate estate, String serviceName) async {
  MitsuHeatPumpDevice mitsu = await getMitsu(estate);
  AirHeatPump airHeatPump = createNewAirHeatPump(mitsu);
  estate.addFunctionality(airHeatPump);
  estate.addView(AirHeatPumpView(airHeatPump));
  await airHeatPump.init();
  await airHeatPump.editWidget(context, estate, airHeatPump, mitsu);
  return airHeatPump;
}

Future<Functionality> addTesla(BuildContext context, Estate estate, String serviceName) async {
  Functionality teslaFunctionality = TeslaFunctionality();
  Device teslaDevice = Device();
  teslaDevice.id = 'Tesla id';
  teslaDevice.name = 'Tesla';
  estate.addFunctionality(teslaFunctionality);
  teslaFunctionality.pair(teslaDevice);

  estate.addView(
      TeslaFunctionalityView(teslaFunctionality));
  await teslaFunctionality.editWidget(context, estate, teslaFunctionality, teslaDevice);
  return (teslaFunctionality);
}

Widget _estateOperationModes(
    String parameterTypeName,
    OperationMode operationMode,
    Estate estate,
    OperationModes operationModes,
    Function updateOperationMode
) {

  Widget myWidget;
  HierarchicalOperationMode hierarchicalOperationMode = HierarchicalOperationMode();

  if (parameterTypeName == hierarchicalOperationMode.typeName()) {
    if (operationMode.runtimeType.toString() == 'HierarchicalOperationMode') {
      hierarchicalOperationMode = operationMode as HierarchicalOperationMode;
    }
    List<Widget> featureTiles = [];
    for (int index=0; index<estate.features.length; index++) {
      if (estate.features[index].operationModes.nbrOfModes() > 0) {
        featureTiles.add(
          ListTile(
            title: Text(estate.features[index].device.name),
            subtitle: OperationModesSelectionView2(
              operationModes: estate.features[index].operationModes,
              initSelectionName: hierarchicalOperationMode.operationCode(estate.features[index].id()),
              returnSelectedModeName: (opName){
                  hierarchicalOperationMode.add(estate.features[index].id(), opName );
                  updateOperationMode(hierarchicalOperationMode);
                },)
          ));
        }
      }
      myWidget = Container(
          margin: myContainerMargin,
          padding: myContainerPadding,
          child: InputDecorator(
              decoration: const InputDecoration(
                  labelText: 'Asunnon toimintotila määritys'),
              child: (featureTiles.isEmpty)
                  ? Text('Asunnon toiminnoille ei ole määritelty toimintotiloja')
                  : Column(children: [
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: featureTiles.length,
                    itemBuilder: (context, index) => Card(
                        elevation: 6,
                        margin: const EdgeInsets.all(10),
                        child: featureTiles[index]
                    )
                )
              ])
          )
      );
    }
  else if (parameterTypeName == dynamicOperationModeText) {
    // dynamicOperationModeText:
      ConditionalOperationModes conditionalModes = ConditionalOperationModes.fromJsonExtended(
          operationModes,
          operationMode.toJson()
      );
      updateOperationMode(conditionalModes);
      myWidget = ConditionalOperationView(
          conditions: conditionalModes
      );
    }
  else {
    myWidget = emptyWidget();
  }
  return myWidget;
}
