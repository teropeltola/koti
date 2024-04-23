
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
import '../../../look_and_feel.dart';
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
    return Consumer<Estate>(
        builder: (context, estate, childNotUsed) {
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
                    Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      // height: 150,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Toimintatilat'),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              airHeatPump.operationModes.nbrOfModes() == 0
                                ? Text('Toimintotiloja ei määritelty')
                                : OperationModesSelectionView(operationModes: airHeatPump.operationModes),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  airHeatPump.operationModes.nbrOfModes() == 0
                                    ? emptyWidget()
                                    : OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      backgroundColor: mySecondaryColor,
                                      side: const BorderSide(
                                          width: 2, color: mySecondaryColor),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(10))),
                                      elevation: 10),
                                  onPressed: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return EditOperationModeView(
                                                estate: estate,
                                                initOperationModeName: airHeatPump.operationModes.currentModeName(),
                                                operationModes: airHeatPump.operationModes,
                                                possibleTypes: possibleParameterTypes,
                                                parameterFunction: _myParameterReading,
                                                callback: (){});
                                          },
                                        )
                                    );
                                    setState(() {});
                                  },
                                  child: const Text(
                                    'Muokkaa',
                                    maxLines: 1,
                                    style: TextStyle(color: mySecondaryFontColor),
                                    textScaleFactor: 2.0,
                                  ),
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      backgroundColor: mySecondaryColor,
                                      side: const BorderSide(
                                          width: 2, color: mySecondaryColor),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(10))),
                                      elevation: 10),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return EditOperationModeView(
                                            estate: estate,
                                            initOperationModeName: '',
                                            operationModes: airHeatPump.operationModes,
                                            possibleTypes: possibleParameterTypes,
                                            parameterFunction: _myParameterReading,
                                            callback: (){});
                                        },
                                      )
                                    );
                                    setState(() {});
                                  },
                                  child: const Text(
                                    'Luo uusi',
                                    maxLines: 1,
                                    style: TextStyle(color: mySecondaryFontColor),
                                    textScaleFactor: 2.0,
                                  ),
                                )
                              ])
                            ]),
                      ),
                    ),
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
                                log.info('${widget.estate.name}: laite asetettu ...."');
                                showSnackbarMessage('laitteen tietoja päivitetty!');
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

const String constWarming = 'Kiinteä lämmitys';
const String spotWarming = 'Lämmitys/pörssisähkö';

List<String> possibleParameterTypes = [constWarming, spotWarming];

Widget _myParameterReading(
    String parameterTypeName,
    Map<String,dynamic> parameters,
    Function callback
)
{
  Widget myWidget;
  switch (parameterTypeName) {
    case constWarming: {
      myWidget=temperatureSelectionForm('dd', parameters, callback);
      /*
          Row(children: [
        Expanded(flex: 2, child: Text('Haluttu lämpötila:')),
        Expanded(flex: 2, child: _doubleFormatInput('lämpötila', parameters, callback))
      ]);

       */
    }
    default: myWidget = emptyWidget();
  }
  return myWidget;
}

Widget temperatureSelectionForm(String parameterName, Map <String, dynamic> parameters, Function callback) {
  double currentValue = parameters[parameterName] ?? 0.0;

  currentValue = 26.0;

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

/*
glowColor: theme.glowColor,
tickColor: theme.tickColor,
thumbColor: theme.thumbColor,
dividerColor: theme.dividerColor,
ringColor: theme.ringColor,
turnOnColor: theme.turnOnColor,

 */


