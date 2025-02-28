import 'package:flutter/material.dart';
import 'package:koti/devices/shelly_blu_trv/shelly_blu_trv.dart';
import 'package:koti/devices/shelly_pro2/shelly_pro2.dart';
import 'package:koti/functionalities/boiler_heating/boiler_heating_functionality.dart';
import 'package:koti/functionalities/boiler_heating/view/edit_boiler_heating_view.dart';
import 'package:koti/logic/services.dart';
import 'package:koti/view/temperature_setting_widget.dart';
import '../../../devices/mixins/on_off_switch.dart';
import '../../../devices/ouman/ouman_device.dart';
import '../../../devices/ouman/trend_ouman.dart';
import '../../../estate/estate.dart';
import '../../../logic/state_broker.dart';
import '../../../look_and_feel.dart';
import '../../../operation_modes/view/operation_modes_selection_view.dart';
import '../../../service_catalog.dart';
import '../../../trend/trend.dart';
import '../../../trend/trend_switch.dart';
import '../../../view/battery_level_widget.dart';
import '../../functionality/view/functionality_view.dart';

class BoilerHeatingOverview extends StatefulWidget {
  final BoilerHeatingFunctionality boilerHeating;
  const BoilerHeatingOverview({Key? key, required this.boilerHeating}) : super(key: key);

  @override
  _BoilerHeatingState createState() => _BoilerHeatingState();
}

class _BoilerHeatingState extends State<BoilerHeatingOverview> {

  StateBroker myStateBroker = myEstates.currentEstate().stateBroker;
  late BoilerHeatingFunctionality boilerHeating;
  late OumanDevice oumanDevice;//boiler heating can be updated with editing
  List<TrendData> boilerTrendList = [];
  List<TrendOuman> oumanTrendList = [];
  List<TrendSwitch> switchTrendList = [];

  late DeviceServiceClass<OnOffSwitchService> mySwitch;

  List<ThermostatControlService> thermostatList = [];


  @override
  void initState() {
    super.initState();
    boilerHeating = widget.boilerHeating;
    oumanDevice = myEstates.currentEstate().findDeviceWithService(deviceService: waterTemperatureService) as OumanDevice;
    mySwitch = boilerHeating.connectedDevices[0].services.getService(powerOnOffWaitingService) as DeviceServiceClass<OnOffSwitchService>;

    thermostatList = _getThermostatList();

    refresh();
  }

  List<ThermostatControlService> _getThermostatList() {
    List <ThermostatControlService> services = [];
    List <String> deviceNames = myEstates.currentEstate().findPossibleDevices(deviceService: thermostatService);
    for (var deviceName in deviceNames) {
      DeviceServiceClass<ThermostatControlService> deviceServiceClass =
        myEstates
            .currentEstate()
            .myDeviceFromName(deviceName)
            .services
            .getService(thermostatService) as DeviceServiceClass<ThermostatControlService>;
      services.add(deviceServiceClass.services);
    }
    return services;
  }

  void refresh() async {
    oumanTrendList = await oumanDevice.getHistoryData();
    switchTrendList = mySwitch.services.trendBox().getAll();
    boilerTrendList = [...oumanTrendList.cast<TrendData>(), ... switchTrendList.cast<TrendData>()];
    boilerTrendList.sort((a,b) => b.timestamp - a.timestamp);

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getFormattedValue(String id) {
    double val = myStateBroker.getDoubleValue(id);
    if (val == noValueDouble) {
      return '??';
    }
    else {
      return val.toStringAsFixed(1);
    }
  }

  bool _powerOn()  {
    bool powerOn = myStateBroker.getBoolValue(powerOnOffStatusService, boilerHeating.connectedDevices[0].name);
    return powerOn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appIconAndTitle(myEstates.currentEstate().name, BoilerHeatingFunctionality.functionalityName ),
      ), // new line
      body: SingleChildScrollView(
        child:
          Column(children: <Widget>[
            OperationModesSelectionView(
                operationModes: boilerHeating.operationModes,
                topHierarchy: false,
                callback: () {setState(() {}); }
            ),
            _powerOn()
            ? const Icon(Icons.electric_bolt)
            : const Icon(Icons.flash_off),
            Container(
                margin: const EdgeInsets.fromLTRB(2,10,2,2),
                padding: myContainerPadding,
                //alignment: AlignmentDirectional.topStart,
                child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Patterit'), //
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (var thermostat in thermostatList)
                            Container(
                              margin: const EdgeInsets.fromLTRB(2,10,2,2),
                              padding: myContainerPadding,
                              //alignment: AlignmentDirectional.topStart,
                              child: InputDecorator(
                                decoration: InputDecoration(labelText: thermostat.device.name), //
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ThermostatView(
                                        thermostat: thermostat,
                                      callback: () {setState((){});}
                                    ),
                                  ]
                                )
                              )
                            ),
                        ]
                    )
                )
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(2,10,2,2),
              padding: myContainerPadding,
              //alignment: AlignmentDirectional.topStart,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Ouman lämmönsäädin'), //
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                        Text('Veden lämpötila: ${_getFormattedValue(currentRadiatorWaterTemperatureService)} $celsius'),
                        Text('Venttiilin asento: ${_getFormattedValue(radiatorValvePositionService)} %'),
                        Text('Ohjattu lämpötilatarve: ${_getFormattedValue(requestedRadiatorWaterTemperatureService)} $celsius'),
                        Text('Ulkolämpötila: ${_getFormattedValue(outsideTemperatureService)} $celsius'),
                  ]
                )
              )
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(2,10,2,2),
              padding: myContainerPadding,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'historia'), //
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text('päiväys veden lämpö haluttu lämpö venttiili ulkolämpö', textScaleFactor: 0.9),
                    for (var boilerTrendItem in boilerTrendList)
                      boilerTrendItem.showInLine(),
                  ]
                )
              )
            )
    ]

    )
          ),
        bottomNavigationBar: Container(
          height: bottomNavigatorHeight,
          alignment: AlignmentDirectional.topCenter,
          color: myPrimaryColor,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                    icon: const Icon(
                        Icons.edit,
                        color: myPrimaryFontColor,
                        size: 40),
                    tooltip: 'muokkaa lämmitysohjauksen tietoja',
                    onPressed: () async {
                      bool successfullyEdited = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EditBoilerHeatingView(
                                  estate: myEstates.currentEstate(),
                                  boilerHeating: boilerHeating,
                                  callback: () {}
                              );
                            },
                          )
                      );
                      if (successfullyEdited) {
                        storeChanges();
                      }
                      setState(() {});
                    }
                ),

              ]),
        )

    );
  }
}

Widget boilerHeatingSummary(ShellyPro2 shellyPro2) {
  return Container(
    margin: const EdgeInsets.fromLTRB(2,10,2,2),
    padding: myContainerPadding,
    //alignment: AlignmentDirectional.topStart,
    child: InputDecorator(
      decoration: const InputDecoration(labelText: 'Lämminvesivaraaja ohjaus'), //k
      child: ! shellyPro2.connected()
          ? const Text('Tietoa ei ole vielä vastaanotettu')
          : Column(children:<Widget> [
              const Text('SwitchConfig'),
              Row(children:<Widget> [
                Expanded(
                    flex: 8,
                    child:
                    Text(shellyPro2.switchConfigList[0].toString()
                    )
                ),
                Expanded(
                    flex: 8,
                    child:
                    Text(shellyPro2.switchConfigList[1].toString()
                    )
                )
              ]),
              const Text('SwitchStatus'),
              Row(children:<Widget> [
                Expanded(
                  flex: 8,
                  child:
                    Text(shellyPro2.switchStatusList[0].toString()
                    )
                ),
                Expanded(
                  flex: 8,
                  child:
                    Text(shellyPro2.switchStatusList[1].toString()
                      )
                )
              ]),
              const Text('InputStatus'),
              Row(children:<Widget> [
                Expanded(
                    flex: 8,
                    child:
                    Text(shellyPro2.inputConfigList[0].toString()
                    )
                ),
                Expanded(
                    flex: 8,
                    child:
                    Text(shellyPro2.inputConfigList[1].toString()
                    )
                )
              ])
    ,]),
    ),
  );
}

ShellyPro2Id _id(int id) {
  return ShellyPro2Id.values[id];
}
Widget _shellyProToggleButton(FunctionalityView myView, ShellyPro2 myShellyPro, int id, Function refresh) {
  return _myOnOffButton(
    myView,
    myShellyPro.switchConfigList[id].name,
    myShellyPro.switchStatus(_id(id)),
    () {myShellyPro.switchToggle(_id(id)); refresh();});
}

Widget _myOnOffButton( FunctionalityView myView, String switchName, bool switchOn, Function toggleCallback ) {
  return ElevatedButton(
      style: switchOn
          ? myView.buttonStyle(Colors.green, Colors.white)
          : myView.buttonStyle(Colors.red, Colors.white),
      onPressed: () {
        toggleCallback();
      },
      /*
      onLongPress: () async {
      },
       */
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
                switchName,
                style: const TextStyle(
                    fontSize: 12)),
            Icon(
              switchOn ? Icons.power : Icons.power_off,
              size: 50,
              color: switchOn
                  ? Colors.yellowAccent
                  : Colors.white,
            )
          ])
  );
}

Widget showOumanEvent(TrendOuman oumanEvent) {
  try {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget> [
        _item(timestampToDateTimeString(oumanEvent.timestamp, withoutYear: true)),
        _item('${_temperatureString(oumanEvent.measuredWaterTemperature)} $celsius'),
        _item('${_temperatureString(oumanEvent.requestedWaterTemperature)} $celsius'),
        _item('${_doubleToString(oumanEvent.valve)} %'),
        _item('${_temperatureString(oumanEvent.outsideTemperature)} $celsius')
      ]
    );
  }
  catch (e, st) {
    log.error('Unvalid oumanEvent', e, st);
    return const Text('Sisäinen virhe tietojen tulostuksessa',textScaleFactor:0.8);
  }
}

Widget _item(String text) {
  return Expanded( flex: 1, child: Text(text, textScaleFactor:0.8,textAlign:TextAlign.center));
}

String _temperatureString (double t) {
  return _doubleToString(t);
}

String _doubleToString (double t) {
  if (t == noValueDouble) {
    return '???';
  }
  else {
    return t.toStringAsFixed(1);
  }
}

int xxxx = 0 ;
Future<double> _testTemp() async {
  if (xxxx == 0) {
    xxxx++;
    return 5.0;
  } else if (xxxx == 1) {
    xxxx++;
    return 35.0;
  }
  else {
    xxxx = 0;
    return 20.0;
  }
}

class ThermostatView extends StatefulWidget {
  final ThermostatControlService thermostat;
  final Function callback;
  const ThermostatView(
      {super.key, required this.thermostat, required this.callback});

  @override
  State<ThermostatView> createState() => _ThermostatViewState();
}

class _ThermostatViewState extends State<ThermostatView> {

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Flexible(
        flex: 9,
        child:
          XTemperatureSettingWidget(
              currentTarget: widget.thermostat.targetTemperature(),
              currentTemperature: widget.thermostat.temperature(), //_testTemp(),
              returnValue: (newTarget) async {
                await widget.thermostat.setTargetTemperature(newTarget,'patterisäädin');
              })
      ),
      Flexible(
          flex: 1,
          child:
            BatteryLevelWidget(batteryLevel: widget.thermostat.batteryLevel())
      )
    ]);
  }
}

class XTemperatureSettingWidget extends StatefulWidget {
  final Future<double> currentTarget;
  final Future<double> currentTemperature;
  final Function returnValue;

  const XTemperatureSettingWidget({super.key,
    required this.currentTarget,
    required this.currentTemperature,
    required this.returnValue});

  @override
  State<XTemperatureSettingWidget> createState() => _FutureXState();
}

class _FutureXState extends State<XTemperatureSettingWidget> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
        future: widget.currentTarget, // a previously-obtained Future<bool> or null
        builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder<double>(
                future: widget.currentTemperature, // a previously-obtained Future<bool> or null
                builder: (BuildContext context, AsyncSnapshot<double> snapshot2) {
                  if (snapshot2.hasData) {
                    return TemperatureSettingWidget(
                        currentTarget: snapshot.data!,
                        currentTemperature: snapshot2.data!,
                        returnValue: widget.returnValue);
                  }
                  else if (snapshot2.hasError) {
                    return const Text('VIRHE2');
                  } else {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    );
                  }
                }
            );
          } else if (snapshot.hasError) {
            return const Text('VIRHE');
          } else {
            return const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            );
          }
        }
    );
  }
}

class FutureDouble extends StatefulWidget {
  final Future<double> value;

  const FutureDouble({super.key, required this.value});

  @override
  State<FutureDouble> createState() => _FutureDoubleState();
}

class _FutureDoubleState extends State<FutureDouble> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: widget.value, // a previously-obtained Future<bool> or null
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        if (snapshot.hasData) {
          return Text('${_doubleToString(snapshot.data!)} $celsius'
          );
        } else if (snapshot.hasError) {
          return const Text('VIRHE');
        } else {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          );
        }
      }
    );
  }
}
