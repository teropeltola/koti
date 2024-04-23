import 'package:flutter/material.dart';
import 'package:koti/devices/shelly_pro2/shelly_pro2.dart';
import 'package:koti/functionalities/boiler_heating/boiler_heating_functionality.dart';
import 'package:provider/provider.dart';

import '../../../devices/shelly/json/switch_get_status.dart';
import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../../functionality/view/functionality_view.dart';

class BoilerHeatingOverview extends StatefulWidget {
  final BoilerHeatingFunctionality boilerHeating;
  const BoilerHeatingOverview({Key? key, required this.boilerHeating}) : super(key: key);

  @override
  _BoilerHeatingState createState() => _BoilerHeatingState();
}

class _BoilerHeatingState extends State<BoilerHeatingOverview> {
  late ShellyPro2 myShellyPro;

  @override
  void initState() {
    super.initState();

    myShellyPro = widget.boilerHeating.shellyPro2;

    refresh();
  }

  void refresh() async {
    await myShellyPro.getDataFromDevice();
    await myShellyPro.getDeviceInfo();
    await myShellyPro.sysGetConfig();

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Estate>(
      builder: (context, estate, childNotUsed) {
        return Scaffold(
          appBar: AppBar(
            title: appTitle('Lämminvesivaraaja'),
          ), // new line
          body: SingleChildScrollView(
              child: Column(children: <Widget>[
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    _shellyProToggleButton(widget.boilerHeating.myView(), myShellyPro, 0, refresh),
                    _shellyProToggleButton(widget.boilerHeating.myView(), myShellyPro, 1, refresh),
                  ]),
                ),
                boilerHeatingSummary(myShellyPro),
                TextButton(
                  key: const Key('testi virkistys'),
                  child: const Text('Testivirkistys'),
                  onPressed: () {
                    refresh();
                    setState(() {});
                  }
                )
              ])
          )
          );
      }
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
