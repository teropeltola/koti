import 'package:flutter/material.dart';
import 'package:koti/devices/shelly_pro2/shelly_pro2.dart';
import 'package:koti/functionalities/boiler_heating/boiler_heating_functionality.dart';
import 'package:koti/functionalities/boiler_heating/view/edit_boiler_heating_view.dart';
import 'package:koti/functionalities/heating_system_functionality/view/edit_heating_system_view.dart';
import 'package:koti/logic/services.dart';
import '../../../estate/estate.dart';
import '../../../logic/state_broker.dart';
import '../../../look_and_feel.dart';
import '../../../operation_modes/view/operation_modes_selection_view.dart';
import '../../../service_catalog.dart';
import '../../functionality/view/functionality_view.dart';

class BoilerHeatingOverview extends StatefulWidget {
  final BoilerHeatingFunctionality boilerHeating;
  const BoilerHeatingOverview({Key? key, required this.boilerHeating}) : super(key: key);

  @override
  _BoilerHeatingState createState() => _BoilerHeatingState();
}

class _BoilerHeatingState extends State<BoilerHeatingOverview> {

  StateBroker myStateBroker = myEstates.currentEstate().stateBroker;
  late BoilerHeatingFunctionality boilerHeating;//boiler heating can be updated with editing

  @override
  void initState() {
    super.initState();
    boilerHeating = widget.boilerHeating;

    refresh();
  }

  void refresh() async {

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
    bool powerOn = myStateBroker.getBoolValue(powerOnOffService, boilerHeating.connectedDevices[0].name);
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
            ? Icon(Icons.electric_bolt)
            : Icon(Icons.flash_off),
            Container(
              margin: EdgeInsets.fromLTRB(2,10,2,2),
              padding: myContainerPadding,
              //alignment: AlignmentDirectional.topStart,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Ouman lämmönsäädin'), //
        child: Column(children: <Widget>[
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Pannun lämpötila: ${_getFormattedValue(currentRadiatorWaterTemperatureService)} $celsius'),
                Text('Venttiilin asento: ${_getFormattedValue(radiatorValvePositionService)} %'),
                Text('Ohjattu lämpötilatarve: ${_getFormattedValue(requestedRadiatorWaterTemperatureService)} $celsius'),
                Text('Ulkolämpötila: ${_getFormattedValue(outsideTemperatureService)} $celsius'),

              ]),
                ),
              ])
          )
      )
    ])
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
                                  createNew: false,
                                  boilerHeating: boilerHeating
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
    margin: EdgeInsets.fromLTRB(2,10,2,2),
    padding: myContainerPadding,
    //alignment: AlignmentDirectional.topStart,
    child: InputDecorator(
      decoration: const InputDecoration(labelText: 'Lämminvesivaraaja ohjaus'), //k
      child: ! shellyPro2.connected()
          ? Text('Tietoa ei ole vielä vastaanotettu')
          : Column(children:<Widget> [
              Text('SwitchConfig'),
              Row(children:<Widget> [
                Expanded(
                    flex: 8,
                    child:
                    Text('${shellyPro2.switchConfigList[0].toString()}'
                    )
                ),
                Expanded(
                    flex: 8,
                    child:
                    Text('${shellyPro2.switchConfigList[1].toString()}'
                    )
                )
              ]),
              Text('SwitchStatus'),
              Row(children:<Widget> [
                Expanded(
                  flex: 8,
                  child:
                    Text('${shellyPro2.switchStatusList[0].toString()}'
                    )
                ),
                Expanded(
                  flex: 8,
                  child:
                    Text('${shellyPro2.switchStatusList[1].toString()}'
                      )
                )
              ]),
              Text('InputStatus'),
              Row(children:<Widget> [
                Expanded(
                    flex: 8,
                    child:
                    Text('${shellyPro2.inputConfigList[0].toString()}'
                    )
                ),
                Expanded(
                    flex: 8,
                    child:
                    Text('${shellyPro2.inputConfigList[1].toString()}'
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
