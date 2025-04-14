import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/functionalities/general_agent/view/edit_general_agent_view.dart';
import 'package:koti/logic/dropdown_content.dart';

import '../../../devices/device/device.dart';
import '../../../devices/vehicle/vehicle.dart';
import '../../../estate/environment.dart';
import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../../../view/my_dropdown_widget.dart';
import '../../air_heat_pump_functionality/view/create_air_heat_pump_view.dart';
import '../../boiler_heating/view/create_boiler_heating_view.dart';
import '../../plain_switch_functionality/view/create_plain_switch_view.dart';
import '../../thermostat/thermostat.dart';
import '../../vehicle_charging/vehicle_charging.dart';
import '../../weather_forecast/view/edit_weather_forecast_view.dart';


class EditEnvironmentFunctionalitiesView extends StatefulWidget {
  final Environment environment;
  final Function callback;
  const EditEnvironmentFunctionalitiesView({Key? key, required this.environment, required this.callback}) : super(key: key);

  @override
  _EditEnvironmentFunctionalitiesViewState createState() => _EditEnvironmentFunctionalitiesViewState();
}

class _EditEnvironmentFunctionalitiesViewState extends State<EditEnvironmentFunctionalitiesView> {
  _Services availableServices = _Services();
  List<Functionality> existingServices = [];

  @override
  void initState() {
    super.initState();

    availableServices.init(widget.environment);

    refresh();
  }

  void updateExistingServices() {
    existingServices.clear();
    for (var e in widget.environment.features) {
      if (e.runtimeType.toString() != 'ElectricityPrice') {
        existingServices.add(e);
      }
    }
  }

  Future<void> refresh() async {
    updateExistingServices();
    //widget.callback();
    setState(() { });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
            return Column(children: <Widget>[
              Container(
                  margin: myContainerMargin,
                  padding: myContainerPadding,
                  child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Olemassaolevat toiminnot'),
                      child:
                      (existingServices.isEmpty)
                          ? const Text('Ei ole vielä lisättyjä toimintoja')
                          : ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: existingServices.length,
                          itemBuilder: (context, index) => Card(
                              elevation: 6,
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                  title: Text(
                                      '${existingServices[index].myView.viewName()} ('
                                          '${existingServices[index].myView.subtitle()})'),
                                  trailing:
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                            icon: const Icon(Icons.edit),
                                            tooltip: 'muokkaa toimintoa',
                                            onPressed: () async {
                                              await  existingServices[index].myEditingFunction()(
                                                  context,
                                                  widget.environment,
                                                  existingServices[index],
                                                      () {refresh();}
                                              );
                                              //TODO: SHOULD REFRESH BE HERE?
                                            }),
                                        IconButton(
                                            icon: const Icon(Icons.delete),
                                            tooltip: 'poista toiminto',
                                            onPressed: () async {
                                              widget.environment.removeFunctionality(existingServices[index]);
                                              existingServices[index].remove();
                                              await refresh();
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
                        const Text('Lisää uusia toimintoja:'),
                        for (var optionWidget in availableServices.optionWidgets(context, widget.environment, refresh))
                          optionWidget,
                      ]
                      )
                  )
              ),
            ]
    );
  }
}

class _ServiceItem {
  String serviceName = '';
  late Function addFunction;
  Icon serviceIcon = const Icon(Icons.abc);
  bool added = false;
  bool dataEditing = false;
  bool multifunction = false;
  List <String> categories = [];

  _ServiceItem(String initServiceName, bool initAdded, Function initAddFunction, List<String> initCategories,  {bool editData = false}) {
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
  final List <String> _serviceCategories = [ _networkCategory, _warmingCategory, _deviceCategory, _socketCategory];

  void init(Environment environment) {
    clear();
    addConstServices(environment);
  }

  int itemCount() {
    return items.length;
  }

  void addConstServices(Environment environment) {
    Estate estate = environment.myEstate();
    items.add(_ServiceItem('Säätila', estate.deviceExists('Säätila'), createWeatherForecastSystem, [_networkCategory]));
    items.add(_ServiceItem('Termostaatti', false, createThermostatSystem, [_warmingCategory]));
    items.add(_ServiceItem('Ilmalämpöpumppu', estate.deviceExists('Ilpo'), createAirHeatPumpSystem, [_warmingCategory, _deviceCategory]));
    items.add(_ServiceItem('Auton lataus', estate.deviceExists('Tesla'), addTesla, [_deviceCategory]));
    items.add(_ServiceItem('Sähkökatkaisin', false, createPlainSwitchSystem, [_socketCategory]));
    items.add(_ServiceItem('Ajastinkatkaisin', false, createPlainSwitchSystem, [_socketCategory]));
    items.add(_ServiceItem('Lämpötila', false, notYetImplemented, [_socketCategory]));
    items.add(_ServiceItem('Lämminvesivaraaja', false, createBoilerWarmingSystem, [_warmingCategory]));
    //items.add(_ServiceItem('Patterivesikierto', false, createNewRadiatorWaterCirculation, [_warmingCategory, _deviceCategory]));
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

  List <Widget> optionWidgets(BuildContext context, Environment environment, Function callback) {
    List <Widget> widgets = [];

    for (var categoryName in _serviceCategories) {
      List <_ServiceItem> options = [];
      for (var service in items) {
        if (service.categories.contains(categoryName)) {
          options.add(service);
        }
      }
      if (options.isNotEmpty) {
        widgets.add(_categoryOfFunctionalities(context, environment, callback, categoryName, options));
      }
    }
    return widgets;
  }
}

Widget _categoryOfFunctionalities(BuildContext context, Environment environment, Function callback, String name, List <_ServiceItem> options) {
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
                      bool success = await addingFunction(
                          context, environment);
                      if (success) {
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


Future<bool> addTesla(BuildContext context, Environment environment) async {
  Functionality vehicleCharging = VehicleCharging();
  Device teslaDevice = Vehicle();
  teslaDevice.name = 'Tesla';
  environment.myEstate().addDevice(teslaDevice);
  environment.addFunctionality(vehicleCharging);
  vehicleCharging.pair(teslaDevice);
  bool success = await vehicleCharging.editWidget(context, true, environment, vehicleCharging, teslaDevice);
  return success;
}

Future<bool> notYetImplemented(BuildContext context, Environment environment) async {
  return false;
}


class _SelectionOption {

}

Widget functionalitySelection(String title, List<_SelectionOption> selectionOptions) {
  return Text(title);
}



