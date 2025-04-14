import 'dart:math';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';

import '../../../devices/device/device.dart';
import '../../../estate/environment.dart';
import '../../../estate/estate.dart';
import '../../../logic/dropdown_content.dart';
import '../../../logic/events.dart';
import '../../../logic/observation.dart';
import '../../../look_and_feel.dart';
import '../../../operation_modes/view/edit_generic_operation_modes_view.dart';
import '../../../service_catalog.dart';
import '../../../view/interrupt_editing_widget.dart';
import '../../../view/my_dropdown_widget.dart';
import '../../../view/no_needed_resources_widget.dart';
import '../../../view/ready_widget.dart';
import '../../boiler_heating/view/boiler_heating_parameter_setting.dart';
import '../../boiler_heating/view/controlled_devices_widget.dart';
import '../thermostat.dart';

class EditThermostatView extends StatefulWidget {
  final Environment environment;
  final Thermostat thermostat;
  final Function callback;

  const EditThermostatView({Key? key,
    required this.environment,
    required this.thermostat,
    required this.callback}) : super(key: key);

  @override
  _EditThermostatViewState createState() => _EditThermostatViewState();
}

class _EditThermostatViewState extends State<EditThermostatView> {
  late Thermostat thermostat;
  late Estate estate;

  List <String> foundDeviceNames = [''];
  late DropdownContent possibleDevicesDropdown;
  DropdownContent thermostatModeDropdown = DropdownContent(['perus', 'keskiarvo'], 'simple', 0);

  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  final myDeviceNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    estate = widget.environment.myEstate();
    thermostat = widget.thermostat.clone();
    myDeviceNameController.text = thermostat.thermoName;
    thermostatModeDropdown
        .setIndex(thermostat.thermostatMode.index);
    refresh();
  }

  List<String> findPossibleDevices(List<Device> devices) {
    List<String> list = [];
    for (var device in devices) {
      if ((device.services.offerService(thermostatService)) &&
              (!thermostat.connectedDevices.contains(device))){
        list.add(device.name);
      }
    }
    return list;
  }

  void refresh() {
    foundDeviceNames = findPossibleDevices(estate.devices);
    possibleDevicesDropdown = DropdownContent(foundDeviceNames, '', 0);
    setState(() {});
  }

  DropdownContent getPossibleDevicesDropdown() {
    foundDeviceNames = findPossibleDevices(estate.devices);
    possibleDevicesDropdown = DropdownContent(foundDeviceNames, '', 0);
    return possibleDevicesDropdown;
  }

  void addNewDevice()  {
    Device device = estate.myDeviceFromName(possibleDevicesDropdown.currentString());
    if (! thermostat.connectedDeviceNames().contains(device.name)){
      thermostat.pair(device);
    }
    //refresh();
    setState(() {});
    thermostat.init(); // not waiting for init
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
          leading: interruptEditingWidget(context, () async {
            thermostat.remove();
            widget.callback();
          }),
          title: appIconAndTitle(widget.environment.name, 'muokkaa termostaattia'),
        ), // new line
      body: SingleChildScrollView(
        child: foundDeviceNames.isEmpty
          ? noNeededResources(context, 'Asunnossa ei ole laitteita, jossa tarvittava termostaatti-toiminto.'
                'Lisää ensin asuntoon sopiva laite')
          : Column(children: <Widget>[
          Container(
            margin: myContainerMargin,
            padding: myContainerPadding,
            height: 170,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Termostaatin tiedot'), //k
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Spacer(),
                    TextField(
                        key: const Key('thermostatName'),
                        decoration: const InputDecoration(
                          labelText: 'nimi',
                          hintText: 'kirjoita tähän termostaatin nimi',
                        ),
                        focusNode: _focusNode,
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        controller: myDeviceNameController,
                        maxLines: 1,
                        onChanged: (String newText) {
                          thermostat.thermoName = newText;
                        },
                        onEditingComplete: () {
                          _focusNode.unfocus();
                        }
                    ),
                    const Spacer(),
                    InputDecorator(
                      decoration: InputDecoration(labelText: 'laskentatapa'),
                      child: SizedBox(
                          height: 30,
                          width: 120,
                          child: MyDropdownWidget(
                              keyString: 'boilerDropdown',
                              dropdownContent: thermostatModeDropdown,
                              setValue: (newValue) {
                                thermostatModeDropdown
                                    .setIndex(newValue);
                                thermostat.thermostatMode = ThermostatMode.values[newValue];
                              }
                          )
                      ),
                    ),
                  ]),
            ),
          ),
          InputDecorator(
            decoration: InputDecoration(labelText: 'laitteet'),
            child:
              thermostat.connectedDevices.isEmpty
              ? Text('ei laitteita, lisää laitteet alla olevasta valikosta')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: thermostat.connectedDevices.length,
                  itemBuilder:  (context, index) => Card(
                      elevation: 6,
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                          title: Text(
                              '${thermostat.connectedDevices[index].name}'),
                          trailing:
                            IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'poista toiminto',
                                    onPressed: () async {
                                      thermostat.unPair(thermostat.connectedDevices[index]);
                                      refresh();
                                    }
                            ),
                      )
                  )
              ),
          ),
          controlledDevicesWidget(
              'Lisää uusia termostaatteja',
              'Termostaatti',
              possibleDevicesDropdown,
              addNewDevice,
                ),
              operationModeHandling2(
                  context,
                  widget.environment,
                  thermostat.operationModes,
                  boilerHeatingParameterSetting,
                  refresh
              ),
              readyWidget(() async {
                if (thermostat.thermoName == '') {
                  informMatterToUser(context, 'Termostaatin nimi ei voi olla tyhjä', 'Lisää nimi!');
                }
                else {
                  if (thermostat.connectedDevices.isEmpty) {
                    informMatterToUser(context, 'Termostaattiin pitää liittää vähintään yksi laite', 'Lisää laite!');
                  }
                  else {
                    // remove earlier version
                    widget.thermostat.unPairAll();
                    widget.environment.removeFunctionality(widget.thermostat);
                    // add new version
                    widget.environment.addFunctionality(thermostat);
                    widget.callback();
                    showSnackbarMessage('laitteen tietoja päivitetty!');
                    Navigator.pop(context, true);
                  }
                }
              })
            ])
        )
    );
  }
}
