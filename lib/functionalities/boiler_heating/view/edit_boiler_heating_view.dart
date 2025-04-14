import 'dart:math';

import 'package:flutter/material.dart';
import 'package:koti/service_catalog.dart';
import 'package:koti/view/no_needed_resources_widget.dart';

import '../../../devices/device/device.dart';
import '../../../estate/environment.dart';
import '../../../estate/estate.dart';
import '../../../logic/dropdown_content.dart';
import '../../../look_and_feel.dart';
import '../../../operation_modes/view/edit_generic_operation_modes_view.dart';
import '../../../view/ready_widget.dart';
import '../../../view/interrupt_editing_widget.dart';
import '../boiler_heating_functionality.dart';
import 'boiler_heating_parameter_setting.dart';
import 'controlled_devices_widget.dart';

class EditBoilerHeatingView extends StatefulWidget {
  final Environment environment;
  final BoilerHeatingFunctionality boilerHeating;
  final Function callback;
  const EditBoilerHeatingView({Key? key,
    required this.environment,
    required this.boilerHeating,
    required this.callback}) : super(key: key);

  @override
  _EditBoilerHeatingViewState createState() => _EditBoilerHeatingViewState();
}

class _EditBoilerHeatingViewState extends State<EditBoilerHeatingView> {
  late BoilerHeatingFunctionality editedBoilerHeating;
  List <String> foundDeviceNames = [''];
  late DropdownContent possibleDevicesDropdown;
  late Estate estate;

  @override
  void initState() {
    super.initState();
    estate = widget.environment.myEstate();
    editedBoilerHeating = widget.boilerHeating.clone();
    refresh();
  }

  void refresh() {
    foundDeviceNames = estate.findPossibleDevices(deviceService: powerOnOffWaitingService);
    int index = max(0, foundDeviceNames.indexOf(editedBoilerHeating.id));
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
        leading: interruptEditingWidget(context, () async {
          editedBoilerHeating.remove();
          widget.callback();
        }),
        title: appIconAndTitle(widget.environment.name, 'muokkaa lämminvesivaraajaa'),
      ), // new line
      body: SingleChildScrollView(
        child:
          foundDeviceNames.isEmpty
            ? noNeededResources(context, 'Asunnossa ei ole laitteita, jossa tarvittava virtakytkin.'
                                         'Lisää ensin asuntoon vaadittava laite')
            : Column(children: <Widget>[
                controlledDevicesWidget('Ohjattavat laitteet', 'Lämminvesivaraajan sähköohjaus', possibleDevicesDropdown,  () {setState(() {});}),
                operationModeHandling2(
                      context,
                      widget.environment,
                      editedBoilerHeating.operationModes,
                      boilerHeatingParameterSetting,
                      refresh
                ),
                readyWidget( () async {
                  Device device = estate.myDeviceFromName(possibleDevicesDropdown.currentString());
                  // remove earlier version of boilerHeating
                  widget.boilerHeating.unPairAll();
                  widget.environment.removeFunctionality(widget.boilerHeating);
                  widget.boilerHeating.remove();
                  // add new version
                  editedBoilerHeating.pair(device);
                  await editedBoilerHeating.init();
                  await editedBoilerHeating.operationModes.selectIndex(0);
                  widget.environment.addFunctionality(editedBoilerHeating);
                  // exit
                  widget.callback();
                  log.info('${widget.environment.name}: lämmivesivaraajaa päivitetty');
                  Navigator.pop(context, true);
                }
                )
              ])
        )
      );
  }
}
