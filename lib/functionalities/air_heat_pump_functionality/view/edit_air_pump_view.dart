
import 'package:thermostat/thermostat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:koti/main.dart';
import 'package:koti/operation_modes/view/edit_operation_mode_view.dart';
import 'package:koti/operation_modes/view/operation_modes_selection_view.dart';
import 'package:provider/provider.dart';

import '../../../devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';
import '../../../estate/estate.dart';
import '../../../functionalities/functionality/functionality.dart';
import '../../../logic/service_caller.dart';
import '../../../look_and_feel.dart';
import '../../../operation_modes/conditional_operation_modes.dart';
import '../../../operation_modes/operation_modes.dart';
import '../../../operation_modes/view/conditional_option_list_view.dart';
import '../air_heat_pump.dart';
import 'air_heat_pump_view.dart';

class EditAirPumpView extends StatefulWidget {
  final Estate estate;
  final Functionality airHeatPumpInput;
  final Function callback;
  const EditAirPumpView({Key? key, required this.estate, required this.airHeatPumpInput, required this.callback}) : super(key: key);

  @override
  _EditAirPumpViewState createState() => _EditAirPumpViewState();
}

class _EditAirPumpViewState extends State<EditAirPumpView> {
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  final myDeviceNameController = TextEditingController();

  String deviceName = '';
  late AirHeatPump airHeatPump;
  late MitsuHeatPumpDevice newMitsu;
  bool newMitsuAdded = false;

  @override
  void initState() {
    super.initState();
    if (widget.airHeatPumpInput == allFunctionalities.noFunctionality()) {
      initNewAirPump(widget.estate);
    }
    else {
      airHeatPump = widget.airHeatPumpInput as AirHeatPump;
      deviceName = airHeatPump.myPumpDevice().name;
    }
    refresh();
  }

  Future<void> initNewAirPump(Estate estate) async {
    initNewMitsu(estate);
    airHeatPump = createNewAirHeatPump(newMitsu);
    estate.addFunctionality(airHeatPump);
    estate.addView(AirHeatPumpView(airHeatPump));
    await airHeatPump.init();
  }

  Future<void> initNewMitsu(Estate estate) async {
    int index = estate.devices.indexWhere((e){return e.runtimeType == MitsuHeatPumpDevice;} );
    if (index >= 0) {
      newMitsu = estate.devices[index] as MitsuHeatPumpDevice;
    }
    else {
      newMitsu = MitsuHeatPumpDevice();
      newMitsuAdded = true;
      estate.addDevice(newMitsu);
      await newMitsu.init();
    }
  }


  void refresh() {
    myDeviceNameController.text = deviceName;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeWifi.dispose();
    myDeviceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Keskeytä laitteen tietojen muokkaus',
                    onPressed: () async {
                      // check if the user wants to cancel all the changes
                      bool doExit = await askUserGuidance(context,
                          'Poistuttaessa muutetut tiedot katoavat.',
                          'Haluatko poistua näytöltä?'
                      );
                      if (doExit) {
                        if (newMitsuAdded) {
                          //Todo: poista mitsu
                        }
                        Navigator.of(context).pop();
                      }
                    }),
                title: appTitle('muokkaa laitteen tietoja'),
              ), // new line
              body: SingleChildScrollView(
                  child: Column(children: <Widget>[
                    Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Laitteen tiedot'), //k
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              key: const Key('deviceName'),
                              decoration: const InputDecoration(
                                labelText: 'Laitteen nimi',
                                hintText: 'kirjoita tähän laitteen nimi',
                              ),
                              focusNode: _focusNode,
                              autofocus: false,

                              textInputAction: TextInputAction.done,
                              controller: myDeviceNameController,
                              maxLines: 1,
                              onChanged: (String newText) {
                                deviceName = newText;
                              },
                              onEditingComplete: () {
                                _focusNode.unfocus();
                          }),
                        ]),
                      ),
                    ),
                    operationModeHandling(
                      context,
                      widget.estate,
                      airHeatPump.operationModes,
                      possibleParameterTypes,
                      _myParameterReading,
                      (){setState(() {});} ),
                    Container(
                        margin: myContainerMargin,
                        padding: myContainerPadding,
                        child: Tooltip(
                            message:
                            'Paina tästä tallentaaksesi muutokset ja poistuaksesi näytöltä',
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
                                airHeatPump.device.name = deviceName;
                                await myEstates.store();
                                log.info('${widget.estate.name}: laitteen "$deviceName" tietoja muokattiin.');
                                showSnackbarMessage('laitteen $deviceName tietoja päivitetty!');
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
}

List<String> possibleParameterTypes = [constWarming, relativeWarming, dynamicOperationModeText];

Widget _myParameterReading(
    String parameterTypeName,
    OperationMode operationMode,
    Estate estate,
    OperationModes operationModes,
    Function updateOperationMode
)
{
  Widget myWidget;
  switch (parameterTypeName) {
    case constWarming: {
      ConstantOperationMode cOM = ConstantOperationMode();
      if (operationMode.runtimeType.toString() == 'ConstantOperationMode') {
        cOM = operationMode as ConstantOperationMode;
      }
      else {
        ConstantOperationMode cOM = ConstantOperationMode().cloneFrom(
            operationMode);
      }
      updateOperationMode(cOM);
      myWidget=temperatureSelectionForm(temperatureParameterId, cOM.parameters);
      break;
    }
    case relativeWarming:{
      myWidget=Text('ei oo toteutettu, mutta ideana on antaa +/- arvoja edelliseen verrattuna');
      break;
    }
    case dynamicOperationModeText: {
      ConditionalOperationModes conditionalModes = ConditionalOperationModes.fromJsonExtended(
          operationModes,
          operationMode.toJson()
      );
      updateOperationMode(conditionalModes);
      myWidget = ConditionalOperationView(
        conditions: conditionalModes
      );
      break;
    }
    default: myWidget = emptyWidget();
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


