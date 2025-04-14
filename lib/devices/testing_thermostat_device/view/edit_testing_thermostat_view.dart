import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:koti/devices/testing_thermostat_device/testing_thermostat_device.dart';
import 'package:koti/service_catalog.dart';

import '../../../estate/estate.dart';
import '../../../logic/events.dart';
import '../../../logic/observation.dart';
import '../../../logic/services.dart';
import '../../../look_and_feel.dart';
import '../../../view/ready_widget.dart';
import '../../shelly_blu_gw/shelly_blu_gw.dart';

class EditTestingThermostatView extends StatefulWidget {
  final Estate estate;
  final TestingThermostatDevice thermostat;
  final Function callback;
  const EditTestingThermostatView({Key? key, required this.estate, required this.thermostat, required this.callback}) : super(key: key);

  @override
  _EditTestingThermostatViewState createState() => _EditTestingThermostatViewState();
}

class _EditTestingThermostatViewState extends State<EditTestingThermostatView> {
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  final myDeviceNameController = TextEditingController();
  late TestingThermostatDevice thermostat;
  bool creatingNewDevice = false;

  @override
  void initState() {
    super.initState();
    creatingNewDevice = widget.thermostat.name == '';
    thermostat = widget.thermostat.clone();

    myDeviceNameController.text = thermostat.name;
    refresh();
  }

  void refresh() {
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
                        Navigator.of(context).pop();
                      }
                    }),
                title: appTitleOld('muokkaa laitteen tietoja'),
              ), // new line
              body: SingleChildScrollView(
                  child: Column(children: <Widget>[
                    Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      height: 150,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Laitteen tiedot'), //k
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Spacer(),
                              Row(children: <Widget>[
                                const Flexible(flex:1, child: Text('Tunnus: ')),
                                Flexible(flex:5, child: AutoSizeText(thermostat.id, style:const TextStyle(fontSize:20,color:Colors.blue))),
                              ]),
                              const Spacer(),
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
                                    thermostat.name = newText;
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
                        child: InputDecorator(
                            decoration: const InputDecoration(
                                labelText: 'Laitteen yksityiskohtaiset tiedot'),
                            child: Column(
                              children: [
                              ]
                            )
                        )
                    ),
                    readyWidget(() async {

                      // remove earlier version
                      widget.estate.removeDevice(widget.thermostat.id);
                      widget.thermostat.remove();
                      // create new
                      await thermostat.init();
                      widget.estate.addDevice(thermostat);
                      events.write(widget.estate.id, thermostat.id, ObservationLevel.ok,
                          'laitetta (tunnus: "${thermostat.id}") muokattu');
                      showSnackbarMessage('laitteen tietoja päivitetty!');

                      Navigator.pop(context, true);

                    })
                  ])
              )
          );
  }
}
