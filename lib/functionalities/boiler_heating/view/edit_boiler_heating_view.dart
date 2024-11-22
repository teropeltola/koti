import 'dart:math';

import 'package:flutter/material.dart';
import 'package:koti/view/no_needed_resources_widget.dart';
import 'package:thermostat/thermostat.dart';

import '../../../devices/device/device.dart';
import '../../../estate/estate.dart';
import '../../../logic/dropdown_content.dart';
import '../../../look_and_feel.dart';
import '../../../operation_modes/conditional_operation_modes.dart';
import '../../../operation_modes/operation_modes.dart';
import '../../../operation_modes/view/conditional_option_list_view.dart';
import '../../../operation_modes/view/edit_generic_operation_modes_view.dart';
import '../../../view/my_dropdown_widget.dart';
import '../../../view/ready_widget.dart';
import '../../../view/interrupt_editing_widget.dart';
import '../../air_heat_pump_functionality/view/air_heat_pump_view.dart';
import '../boiler_heating_functionality.dart';

class EditBoilerHeatingView extends StatefulWidget {
  final Estate estate;
  final bool createNew;
  final BoilerHeatingFunctionality boilerHeating;
  const EditBoilerHeatingView({Key? key,
    required this.estate,
    required this.createNew,
    required this.boilerHeating}) : super(key: key);

  @override
  _EditBoilerHeatingViewState createState() => _EditBoilerHeatingViewState();
}

class _EditBoilerHeatingViewState extends State<EditBoilerHeatingView> {
  late BoilerHeatingFunctionality boilerHeatingFunctionality;
  List <String> foundDeviceNames = [''];
  late DropdownContent possibleDevicesDropdown;

  @override
  void initState() {
    super.initState();
    if (widget.createNew) {
      boilerHeatingFunctionality = widget.boilerHeating;
      boilerHeatingFunctionality.addPredefinedOperationMode('Päällä', "powerOnOffService" , true);
      boilerHeatingFunctionality.addPredefinedOperationMode('Pois', "powerOnOffService" , false);
    }
    else {
      boilerHeatingFunctionality = widget.boilerHeating.clone();
    }
    refresh();
  }

  void refresh() {
    foundDeviceNames = widget.estate.findPossibleDevices(deviceService: 'powerOnOffService');
    int index = max(0, foundDeviceNames.indexOf(boilerHeatingFunctionality.id));
    possibleDevicesDropdown = DropdownContent(foundDeviceNames, '', index);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: interruptEditingWidget(context, () async {boilerHeatingFunctionality.remove();}),
        title: appIconAndTitle(widget.estate.name, widget.createNew ? 'luo lämminvesivaraaja' : 'muokkaa lämminvesivaraajaa'),
      ), // new line
      body: SingleChildScrollView(
        child:
          foundDeviceNames.isEmpty
            ? noNeededResources(context, 'Asunnossa ei ole laitteita, jossa tarvittava virtakytkin.'
                                         'Lisää ensin asuntoon vaadittava laite')
            : Column(children: <Widget>[
                    Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      height: 200,
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: 'Ohjattavat laitteet'), //k
                        child:
                          Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              margin: myContainerMargin,
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Lämminvesivaraajan sähköohjaus'),
                                child: SizedBox(
                                  height: 30,
                                  width: 120,
                                  child: MyDropdownWidget(
                                    keyString: 'boilerDropdown',
                                    dropdownContent: possibleDevicesDropdown,
                                    setValue: (newValue) {
                                      possibleDevicesDropdown
                                                        .setIndex(newValue);
                                                    setState(() {});
                                                  }
                                              )
                                          ),
                              ),
                            ),
                            Container(
                                  margin: myContainerMargin,
                                  padding: myContainerPadding,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                        labelText: 'Patteriveden ohjaus'),
                                    child: Text('Tässä voisi olla vaihtoehtoja. Nyt suoraan käytetään Oumania')
                                )
                            ),
                          ]),
                      ),
                    ),
                    operationModeHandling2(
                      context,
                      widget.estate,
                      boilerHeatingFunctionality.operationModes,
                      boilerHeatingParameterSetting,
                      refresh
                    ),
                    readyWidget(
                        () async {
                          Device device = widget.estate.myDeviceFromName(possibleDevicesDropdown.currentString());
                          if ( widget.createNew) {
                            boilerHeatingFunctionality.pair(device);
                            widget.estate.addFunctionality(boilerHeatingFunctionality);
                            widget.estate.addView(boilerHeatingFunctionality.myView());
                            await boilerHeatingFunctionality.init();
                            await boilerHeatingFunctionality.operationModes.selectIndex(0);
                            log.info('${widget.estate.name}: laite "${device.name}" liitetty lämminvesivaraajaan');
                          }
                          else {
                            widget.boilerHeating.unPairAll();
                            widget.estate.addFunctionality(boilerHeatingFunctionality);
                            boilerHeatingFunctionality.pair(device);
                            log.info('${widget.estate.name}: lämmivesivaraajaa päivitetty');
                          }
                          Navigator.pop(context, true);
                        }
                    )
                  ])
              )
          );
  }
}

List<String> possibleParameterTypes = [constWarming, relativeWarming ];

Widget boilerHeatingParameterSetting(
    OperationMode operationMode,
    Estate estate,
    OperationModes operationModes
    )
{
  Widget myWidget;
  if (operationMode is ConstantOperationMode) {
    ConstantOperationMode cOM = operationMode as ConstantOperationMode;
    myWidget=temperatureSelectionForm(temperatureParameterId, cOM.parameters);
  }
  else if (operationMode is ConditionalOperationModes) {
    myWidget = ConditionalOperationView(
        conditions: operationMode as ConditionalOperationModes
    );
  }
  else {
    myWidget=Text('ei oo toteutettu, mutta ideana on antaa +/- arvoja edelliseen verrattuna');
  }
  return myWidget;
}

Widget temperatureSelectionForm(String parameterName, Map <String, dynamic> parameters) {
  double currentValue = parameters[parameterName] ?? 24.0;

  return Thermostat(
      formatCurVal: (val) { return 'Lämpötila';},
      curVal: currentValue,
      setPoint: currentValue,
      setPointMode: SetPointMode.displayAndEdit,
      formatSetPoint: (val) { return '${val.toStringAsFixed(1)} $celsius';},
      themeType: ThermostatThemeType.light,
      maxVal: 40.0,
      minVal: 15.0,
      size: 300.0,
      turnOn: true,
      onChanged: (val) {currentValue = val; parameters[parameterName] = val; }
  );
}

