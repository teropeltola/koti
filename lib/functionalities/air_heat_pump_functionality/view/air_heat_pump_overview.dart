import 'package:flutter/material.dart';
import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';
import 'package:koti/operation_modes/view/operation_modes_selection_view.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../air_heat_pump.dart';
import 'edit_air_pump_view.dart';

class AirHeatPumpOverview extends StatefulWidget {
  final AirHeatPump airHeatPump;
  final Function callback;
  const AirHeatPumpOverview({Key? key, required this.airHeatPump, required this.callback}) : super(key: key);

  @override
  _AirHeatPumpState createState() => _AirHeatPumpState();
}

class _AirHeatPumpState extends State<AirHeatPumpOverview> {
  late MitsuHeatPumpDevice myAirHeatPumpDevice;
  String estateName = '';

  @override
  void initState() {
    super.initState();

    myAirHeatPumpDevice = widget.airHeatPump.myPumpDevice();
    estateName = myEstates.estateFromId(myAirHeatPumpDevice.myEstateId).name;

    refresh();
  }

  void refresh() {
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Palaa takaisin asuntonäytölle',
                onPressed: () async {
                  widget.callback();
                  Navigator.pop(context, true);
                }),
            title: appIconAndTitle(estateName, myAirHeatPumpDevice.name),
          ), // new line
          body: SingleChildScrollView(
              child: Column(children: <Widget>[
                OperationModesSelectionView(
                  operationModes: widget.airHeatPump.operationModes,
                  topHierarchy: false,
                    callback: () {setState(() {}); }
                ),
                airHeatPumpSummary(myAirHeatPumpDevice),
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
                        icon: const Icon(Icons.edit,
                            color: myPrimaryFontColor, size: 40),
                        tooltip: 'muokkaa näytön tietoja',
                        onPressed: () async {
                          await Navigator.push(
                              context, MaterialPageRoute(
                            builder: (context) {
                              return EditAirPumpView(
                                  environment: myEstates.currentEstate().findEnvironmentFor(widget.airHeatPump),
                                  airHeatPumpInput: widget.airHeatPump,
                                  callback: (){});
                            }
                          ));
                          widget.callback();
                          setState(() {});
                        }),
                  ]),
            )

        );
  }
}

Widget airHeatPumpSummary(MitsuHeatPumpDevice myAirHeatPumpDevice) {
  String labelText = '${myAirHeatPumpDevice.name} ${AirHeatPump.functionalityName}';
  return Container(
    margin: const EdgeInsets.fromLTRB(2,10,2,2),
    padding: myContainerPadding,
    //alignment: AlignmentDirectional.topStart,
    child: InputDecorator(
      decoration: const InputDecoration(labelText: 'lpo ilmalämpöpumppu'), //k
      child: myAirHeatPumpDevice.noData()
          ? const Text('Tietoa ei ole vielä vastaanotettu')
          : Row(children:<Widget> [
        Expanded(
          flex: 3,
          child: Icon(
            Icons.heat_pump_rounded,
            size: 60,
            color: observationSymbolColor(myAirHeatPumpDevice.observationLevel()),
          ),
        ),
        Expanded(
          flex: 6,
          child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                myAirHeatPumpDevice.peekPower() ? Text('Päällä') : Text('Pois päältä'),
                Text('Ulkolämpötila:'),
                Text('Sisälämpötila: '),
                Text('Haluttu lämpötila: '),
                Text('Tuuletusteho:'),
                Text('Aikaleima:')
              ]),
        ),
        Expanded(
            flex: 2,
            child:
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(''),
                  Text(temperatureString(myAirHeatPumpDevice.outsideTemperature())),
                  Text(temperatureString(myAirHeatPumpDevice.measuredTemperature())),
                  Text(temperatureString(myAirHeatPumpDevice.targetTemperature())),
                  Text(' ${myAirHeatPumpDevice.fanSpeed()}/5'),
                  Text(' ${myAirHeatPumpDevice.fetchingTime().hour.toString().padLeft(2,'0')}:${myAirHeatPumpDevice.fetchingTime().minute.toString().padLeft(2,'0')}'),
                ])
        )
      ]),
    ),
  );
}