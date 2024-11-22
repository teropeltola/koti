import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';
import 'package:koti/devices/ouman/ouman_device.dart';
import 'package:koti/devices/wlan/active_wifi_name.dart';
import 'package:koti/functionalities/boiler_heating/boiler_heating_functionality.dart';
import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/functionalities/general_agent/view/edit_general_agent_view.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';
import 'package:koti/functionalities/radiator_water_circulation/radiator_water_circulation.dart';
import 'package:koti/logic/dropdown_content.dart';
import 'package:koti/operation_modes/view/edit_operation_mode_view.dart';
import 'package:koti/operation_modes/view/operation_modes_selection_view.dart';

import '../../app_configurator.dart';
import '../../devices/device/device.dart';
import '../../devices/device/view/short_device_view.dart';
import '../../devices/porssisahko/porssisahko.dart';
import '../../devices/shelly/shelly_scan.dart';
import '../../devices/vehicle/vehicle.dart';
import '../../functionalities/air_heat_pump_functionality/air_heat_pump.dart';
import '../../functionalities/air_heat_pump_functionality/view/air_heat_pump_view.dart';
import '../../functionalities/electricity_price/electricity_price.dart';
import '../../functionalities/electricity_price/view/edit_electricity_view.dart';
import '../../functionalities/electricity_price/view/electricity_price_view.dart';
import '../../functionalities/heating_system_functionality/heating_system.dart';
import '../../functionalities/heating_system_functionality/view/heating_system_view.dart';
import '../../functionalities/plain_switch_functionality/view/edit_plain_switch_view.dart';
import '../../functionalities/vehicle_charging/vehicle_charging.dart';
import '../../functionalities/vehicle_charging/view/vehicle_charging_view.dart';
import '../../functionalities/weather_forecast/view/edit_weather_forecast_view.dart';
import '../../functionalities/weather_forecast/weather_forecast.dart';
import '../../operation_modes/conditional_operation_modes.dart';
import '../../operation_modes/hierarcical_operation_mode.dart';
import '../../operation_modes/operation_modes.dart';
import '../../operation_modes/view/conditional_option_list_view.dart';
import '../../service_catalog.dart';
import '../../view/my_dropdown_widget.dart';
import '../../view/ready_widget.dart';
import '../estate.dart';
import '../../look_and_feel.dart';

class _DevicePrototypes {
  List <Device> list = [];

  List <String> currentShellyServices = [];

  void init(Estate editedEstate) {
    list.addAll(_findPossibleDevices(editedEstate));
    scanPossibleShellyServices(editedEstate);
  }

  void refresh(Estate editedEstate) {
    scanPossibleShellyServices(editedEstate);
  }

  void remove() {
    for (var device in list) {
      device.remove();
    }
    list.clear();
    currentShellyServices.clear();
  }

  void removeFromList(List <String> removedNames) {
    for (var device in list) {
      if (removedNames.contains(device.id)) {
        list.remove(device);
        device.remove();
      }
    }

  }

  void scanPossibleShellyServices(Estate editedEstate) {

    List <String> newShellyServices = shellyScan.listPossibleServices();

    // remove shelly services that are already installed
    for (int index = newShellyServices.length-1; index >= 0; index--) {
      if (editedEstate.deviceExists(newShellyServices[index])) {
        newShellyServices.removeAt(index);
      }
    }

    if (! listEquals(newShellyServices, currentShellyServices)) {

      removeFromList(currentShellyServices);

      for (var shellyName in newShellyServices) {
        Device shellyDevice = deviceFromTypeName(
            findShellyTypeName(shellyName));
        shellyDevice.id = shellyName;
        list.add(shellyDevice);
      }
    }
  }


  List <Device> _findPossibleDevices(Estate estate) {
    List <Device> devices = applicationDeviceConfigurator.getDevicesWithAttribute(deviceWithManualCreation);

    // remove existing devices that are not allowed to be several times
    for (int index = devices.length-1; index>=0; index--) {
      var device = devices[index];
      if (! device.isReusableForFunctionalities()) {
        if (estate.hasDeviceOfType(devices[index].runtimeType)) {
          devices.removeAt(index);
          device.remove();
        }
      }
    }
    return devices;
  }
}

class EditEstateView extends StatefulWidget {
   final String estateName;
   EditEstateView({Key? key, required this.estateName}) : super(key: key);

  @override
  _EditEstateViewState createState() => _EditEstateViewState();
}

class _EditEstateViewState extends State<EditEstateView> {
  late Estate editedEstate;

  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  final myEstateNameController = TextEditingController();
  _Services availableServices = _Services();
  List<Functionality> existingServices = [];
  _DevicePrototypes foundDevices = _DevicePrototypes();

  @override
  void initState() {
    super.initState();

    if (_createNewEstate()) {
      editedEstate = myEstates.candidateEstate();
      editedEstate.init('',activeWifiName.activeWifiName);
      addElectricityPriceWithoutEditing(editedEstate);
    }
    else {
      editedEstate = myEstates.cloneCandidate(widget.estateName);
    }
    availableServices.init(editedEstate);

    myEstateNameController.text = editedEstate.name;
    foundDevices.init(editedEstate);
    updateExistingServices();
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


  void refresh() {
    updateExistingServices();
    foundDevices.refresh(editedEstate);
    setState(() { });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeWifi.dispose();

    super.dispose();
  }

  void _removeTemporaryDevicePrototypes() {
    foundDevices.remove();
  }

  bool _createNewEstate() {
    return widget.estateName == '';
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
                    _removeTemporaryDevicePrototypes();
                    editedEstate.removeData();
                    Navigator.of(context).pop();
                  }
                }),
            title: _createNewEstate()
              ? appIconAndTitle('Syötä', 'asunnon tiedot')
              : appIconAndTitle(widget.estateName, 'muuta tietoja'),
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
                        initialValue: editedEstate.myWifi,
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        maxLines: 1,
                        onChanged: (String newWifi) {
                          editedEstate.myWifiDevice().changeWifiName(newWifi);
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
                Container(
                    margin: myContainerMargin,
                    padding: myContainerPadding,
                    child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Laitteet'),
                        child:
                        Column(children: [
                          devicesGrid(
                              context,
                              'käytössä olevat laitteet',
                              Colors.blue,
                              editedEstate,
                              editedEstate.devices,
                              refresh
                          ),
                          devicesGrid(context,
                              'lisää uusia laitteita:',
                              Colors.lightBlue,
                              editedEstate,
                              foundDevices.list,
                              refresh
                          ),
                        ]
                        )
                    )
                ),

                operationModeHandling(
                  context,
                  editedEstate,
                  editedEstate.operationModes,
                  _estateOperationModes,
                  refresh
              ),

              Container(
                margin: myContainerMargin,
                padding: myContainerPadding,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Asunnon olemassaolevat toiminnot'),
                  child:
                    (existingServices.isEmpty)
                      ? const Text('Asunnossa ei ole vielä lisättyjä toimintoja')
                      : ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: existingServices.length,
                            itemBuilder: (context, index) => Card(
                                elevation: 6,
                                margin: const EdgeInsets.all(10),
                                child: ListTile(
                                  title: Text(
                                      '${existingServices[index].myView().viewName()} ('
                                      '${existingServices[index].myView().subtitle()})'),
                                  trailing:
                                    Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        tooltip: 'muokkaa toimintoa',
                                        onPressed: () async {
                                          await  existingServices[index].editWidget(
                                              context,
                                              false,
                                              editedEstate,
                                              existingServices[index],
                                              existingServices[index].connectedDevices[0]
                                          );
                                          refresh();
                                        }),
                                      IconButton(
                                          icon: Icon(Icons.delete),
                                          tooltip: 'poista toiminto',
                                          onPressed: () async {
                                            editedEstate.removeView(existingServices[index].myView());
                                            editedEstate.removeFunctionality(existingServices[index]);
                                            existingServices[index].remove();
                                            refresh();
                                          }),
                                    ])
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
                      labelText: 'Mahdolliset toiminnot'),
                    child:
                      Column(children: [
                        Text('Lisää uusia toimintoja:'),
                        for (var optionWidget in availableServices.optionWidgets(context, editedEstate, refresh))
                          optionWidget,
                      ]
                      )
                  )
              ),
                      readyWidget(() async {
                        // todo tee kattava tarkistus parametreistä
                        if (editedEstate.name == '') {
                          informMatterToUser(context,'Asunnon nimi ei voi olla tyhjä', 'Korjaa nimi!');
                        }
                        else {
                          String problems = editedEstate.operationModes.searchConditionLoops();
                          if (problems.isNotEmpty) {
                            informMatterToUser(context,'Toimintotila "$problems" viittaa kehässä itseensä', 'Poista kehäviittaukset!');
                          }
                          else {
                            myEstates.replaceEstateWithCandidate(
                                  widget.estateName);
                            myEstates.setCurrent(editedEstate.id);
                            await storeChanges();
                            _removeTemporaryDevicePrototypes();
                            Navigator.pop(context, true);
                          }
                        }
                      })
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
  bool multifunction = false;
  List <String> categories = [];

  _ServiceItem(String initServiceName, bool initAdded, Function initAddFunction, List<String> initCategories,  {bool multiFunction = true, bool editData = false}) {
    serviceName = initServiceName;
    added = initAdded;
    dataEditing = editData;
    addFunction = initAddFunction;
    categories = initCategories;
  }
}

const String _networkCategory = 'verkko';
const String _warmingCategory = 'lämmitys';
const String _deviceCategory = 'laiteohjaus';
const String _socketCategory = 'katkaisimet';

class _Services {
  List <_ServiceItem> items = [];
  List <String> _serviceCategories = [ _networkCategory, _warmingCategory, _deviceCategory, _socketCategory];

  void init(Estate estate) {
    clear();
    addConstServices(estate);
  }

  int itemCount() {
    return items.length;
  }

  void addConstServices(Estate estate) {
    items.add(_ServiceItem('Säätila', estate.deviceExists('Säätila'), addWeatherForecast, [_networkCategory]));
    items.add(_ServiceItem('Lämmitys', estate.deviceExists('Lämmitys'), addHeatingSystem, [_warmingCategory]));
    items.add(_ServiceItem('Ilmalämpöpumppu', estate.deviceExists('Ilpo'), createAirHeatPumpSystem, [_warmingCategory, _deviceCategory]));
    items.add(_ServiceItem('Auton lataus', estate.deviceExists('Tesla'), addTesla, [_deviceCategory]));
    items.add(_ServiceItem('Sähkökatkaisin', false, addPlugInFunctionality, [_socketCategory]));
    items.add(_ServiceItem('Ajastinkatkaisin', false, addPlugInFunctionality, [_socketCategory]));
    items.add(_ServiceItem('Lämpötila', false, notYetImplemented, [_socketCategory]));
    items.add(_ServiceItem('Lämminvesivaraaja', false, createBoilerWarmingSystem, [_warmingCategory]));
    items.add(_ServiceItem('Patterivesikierto', false, createNewRadiatorWaterCirculation, [_warmingCategory, _deviceCategory]));
    items.add(_ServiceItem('Yleinen', false, createGeneralAgent, [_warmingCategory, _deviceCategory, _socketCategory]));

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

  List <Widget> optionWidgets(BuildContext context, Estate estate, Function callback) {
    List <Widget> widgets = [];

    for (var categoryName in _serviceCategories) {
      List <_ServiceItem> options = [];
      for (var service in items) {
        if (service.categories.contains(categoryName)) {
          options.add(service);
        }
      }
      if (options.isNotEmpty) {
        widgets.add(_categoryOfFunctionalities(context, estate, callback, categoryName, options));
      }
    }
    return widgets;
  }
}

Widget _categoryOfFunctionalities(BuildContext context, Estate estate, Function callback, String name, List <_ServiceItem> options) {
  List<String> optionNames = [''];
  for (var option in options) {
    optionNames.add(option.serviceName);
  }
  DropdownContent dropDownContent = DropdownContent(optionNames, '', 0);
  return
    Row(
        children: [
          Expanded(
              flex: 1,
              child: Text('$name:')
          ),
          Expanded(
              flex: 1,
              child: MyDropdownWidget(
                  keyString: '$name-options',
                  dropdownContent: dropDownContent,
                  setValue: (value) async {
                    if (value != 0) {
                       var option = options[value - 1];
                      Function addingFunction = option.addFunction;
                      Functionality functionality = await addingFunction(
                          context, estate, option.serviceName);
                      if (functionality.creationSuccessful()) {
                        option.added = true;
                      }
                      dropDownContent.setIndex(0);
                      callback();
                    }

                  }
              )
          )
        ]
    );
}

Future<Functionality> addPlugInFunctionality(BuildContext context, Estate estate, String serviceName) async {

  PlainSwitchFunctionality plainSwitchFunctionality = PlainSwitchFunctionality();
  await Navigator.push(
      context, MaterialPageRoute(
    builder: (context) {
      return EditPlainSwitchView(
          estate: estate,
          createNew: true,
          switchType: serviceName,
          switchFunctionality: plainSwitchFunctionality,
          callback: (newFunctionality) {plainSwitchFunctionality = newFunctionality;});
    },
  ));

  return plainSwitchFunctionality;
}

Future<OumanDevice> getOuman(BuildContext context, Estate estate) async {

  //check if I already have one
  int index = estate.devices.indexWhere((e){return e.runtimeType == OumanDevice;} );
  if (index >= 0) {
    return estate.devices[index] as OumanDevice;
  }
  else {
    bool success = await OumanDevice().editWidget(context, estate);
    if (success) {
      return await getOuman(context, estate);
    }
    else {
      return OumanDevice.failed();
    }
  }
}

Future<MitsuHeatPumpDevice> getMitsu(BuildContext context, Estate estate) async {

  //check if I already have one
  int index = estate.devices.indexWhere((e){return e.runtimeType == MitsuHeatPumpDevice;} );
  if (index < 0) {
    bool status = await MitsuHeatPumpDevice().editWidget(context, estate);
    if (status) {
      index = estate.devices.indexWhere((e) {
        return e.runtimeType == MitsuHeatPumpDevice;
      });
    }
    else {
      return MitsuHeatPumpDevice.failed();
    }
  }
  return estate.devices[index] as MitsuHeatPumpDevice;
}

Future <void> addElectricityPriceWithoutEditing(Estate estate) async {
  Porssisahko spot = Porssisahko();
  spot.name = 'spot';
  estate.addDevice(spot);

  ElectricityPrice electricityPrice = ElectricityPrice();
  electricityPrice.pair(spot);
  estate.addFunctionality(electricityPrice);
  estate.addView(ElectricityGridBlock(electricityPrice));

  // these are not waited in the initialization:
  await spot.init();
  await electricityPrice.init();

}

Future<WeatherForecast> addWeatherForecast(BuildContext context, Estate estate, String serviceName) async {

  await Navigator.push(
      context, MaterialPageRoute(
    builder: (context) {
      return EditWeatherForecastView(
        createNew: true,
        estate: estate,
        originalWeatherForecast: WeatherForecast()
      );
    },
  ));
  return WeatherForecast();
}

Future<HeatingSystem> addHeatingSystem(BuildContext context, Estate estate, String serviceName) async {
  OumanDevice ouman = await getOuman(context, estate);
  if (ouman.isOk()) {
    MitsuHeatPumpDevice mitsu = await getMitsu(context, estate);

    if (mitsu.isOk()) {
      HeatingSystem heatingSystem = createNewHeatingSystem(ouman, mitsu);

      if (heatingSystem.creationSuccessful()) {
        estate.addFunctionality(heatingSystem);
        estate.addView(HeatingSystemView(heatingSystem));
        await heatingSystem.init();
        return heatingSystem;
      }
    }
  }
  return HeatingSystem.failed();
}
/*
Future<AirHeatPump> addMitsu(BuildContext context, Estate estate, String serviceName) async {
  MitsuHeatPumpDevice mitsu = await getMitsu(context, estate);
  if (mitsu.isNotOk()) {
    return AirHeatPump.failed();
  }
  AirHeatPump airHeatPump = createNewAirHeatPump(mitsu);
  estate.addFunctionality(airHeatPump);
  estate.addView(AirHeatPumpView(airHeatPump));
  await airHeatPump.init();
  return airHeatPump;
}
*/
Future<Functionality> addTesla(BuildContext context, Estate estate, String serviceName) async {
  Functionality vehicleCharging = VehicleCharging();
  Device teslaDevice = Vehicle();
  teslaDevice.name = 'Tesla';
  estate.addDevice(teslaDevice);
  estate.addFunctionality(vehicleCharging);
  vehicleCharging.pair(teslaDevice);

  estate.addView(
      VehicleChargingView(vehicleCharging));
  await vehicleCharging.editWidget(context, true, estate, vehicleCharging, teslaDevice);
  return (vehicleCharging);
}

Future<Functionality> notYetImplemented(BuildContext context, Estate estate, String serviceName) async {
  return Functionality.failed();
}

Widget _estateOperationModes(
    OperationMode operationMode,
    Estate estate,
    OperationModes operationModes
) {

  Widget myWidget;

  if (operationMode is HierarchicalOperationMode) {
    HierarchicalOperationMode hierarchicalOperationMode = operationMode;
    List<Widget> featureTiles = [];
    for (int index=0; index<estate.features.length; index++) {
      if (estate.features[index].operationModes.nbrOfModes() > 0) {
        featureTiles.add(
          ListTile(
            title: Text(estate.features[index].connectedDevices[0].name),
            subtitle: OperationModesSelectionView2(
              operationModes: estate.features[index].operationModes,
              initSelectionName: hierarchicalOperationMode.operationCode(estate.features[index].id),
              returnSelectedModeName: (opName){
                  hierarchicalOperationMode.add(estate.features[index].id, opName );
                  // updateOperationMode(hierarchicalOperationMode);
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
  else if (operationMode is ConditionalOperationModes) {
    myWidget = ConditionalOperationView(
      conditions: operationMode as ConditionalOperationModes
    );
  }
  else {
    myWidget = emptyWidget();
  }
  return myWidget;
}

class _SelectionOption {

}

Widget functionalitySelection(String title, List<_SelectionOption> selectionOptions) {
  return Text(title);
}
