import 'package:flutter/material.dart';
import 'package:koti/devices/ouman/ouman_device.dart';
import 'package:koti/functionalities/air_heat_pump_functionality/view/air_heat_pump_overview.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../heating_system.dart';
import 'edit_heating_system_view.dart';

class HeatingOverview extends StatefulWidget {
  final HeatingSystem heatingSystem;
  final Function callback;
  const HeatingOverview({Key? key, required this.heatingSystem, required this.callback}) : super(key: key);

  @override
  _HeatingOverviewState createState() => _HeatingOverviewState();
}

class _HeatingOverviewState extends State<HeatingOverview> {
  late OumanDevice myOuman;

  @override
  void initState() {
    super.initState();

    myOuman = widget.heatingSystem.myOuman();

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
            title: appIconAndTitle(myEstates.currentEstate().name,'lämmitys'),
          ), // new line
          body: SingleChildScrollView(
              child: Column(children: <Widget>[
                Container(
                margin: const EdgeInsets.fromLTRB(2,10,2,2),
                padding: myContainerPadding,
                //alignment: AlignmentDirectional.topStart,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Ouman EH-800 lämmönsäädin'), //k
                  child: myOuman.noData()
                      ? const Text('Oumanin tietoa ei ole vielä vastaanotettu')
                   : Row(children:<Widget> [
                    Expanded(
                      flex: 3,
                      child: Icon(
                        Icons.water_damage,
                        size: 60,
                        color: observationSymbolColor(myOuman.observationLevel()),
                      ),
                    ),
                  const Expanded(
                      flex: 6,
                      child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                                  Text('Ulkolämpötila:'),
                                  Text('Veden lämpötila: '),
                                  Text('Haluttu veden lämpötila: '),
                                  Text('Venttiilin asento:'),
                                  Text('Aikaleima:')
                        ]),
                  ),
                  Expanded(
                      flex: 2,
                      child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${myOuman.outsideTemperature().toStringAsFixed(1)} $celsius'),
                          Text('${myOuman.measuredWaterTemperature().toStringAsFixed(1)} $celsius'),
                          Text('${myOuman.requestedWaterTemperature().toStringAsFixed(1)} $celsius'),
                          Text(' ${myOuman.valve().toStringAsFixed(0)} %'),
                          Text(' ${myOuman.fetchingTime().hour.toString().padLeft(2,'0')}:${myOuman.fetchingTime().minute.toString().padLeft(2,'0')}'),
                        ])
                  )
                  ]),
                ),
              ),
              airHeatPumpSummary(widget.heatingSystem.myAirPump),
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
                        tooltip: 'muokkaa näytön tietoja',
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return EditHeatingSystemView(
                                    environment: myEstates.currentEstate().findEnvironmentFor(widget.heatingSystem),
                                    heatingSystem: widget.heatingSystem,
                                  );
                                },
                              )
                          );
                          setState(() {});
                        }
                    ),
                  ]),
            )

        );
  }
}
