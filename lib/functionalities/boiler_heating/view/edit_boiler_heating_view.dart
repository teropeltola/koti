import 'dart:math';

import 'package:flutter/material.dart';
import 'package:koti/service_catalog.dart';
import 'package:koti/view/no_needed_resources_widget.dart';

import '../../../devices/device/device.dart';
import '../../../estate/estate.dart';
import '../../../logic/dropdown_content.dart';
import '../../../look_and_feel.dart';
import '../../../operation_modes/view/edit_generic_operation_modes_view.dart';
import '../../../view/ready_widget.dart';
import '../../../view/interrupt_editing_widget.dart';
import '../boiler_heating_functionality.dart';
import 'boiler_heating_parameter_setting.dart';
import 'controlled_devices_widget.dart';

/*
class EditFunctionalityView extends StatefulWidget {
  final Estate estate;
  final Functionality functionality;
  final Function callback;
  const EditFunctionalityView({Key? key,
    required this.estate,
    required this.functionality,
    required this.callback}) : super(key: key);

  @override
  _EditFunctionalityViewState createState() => _EditFunctionalityViewState();
}

class _EditFunctionalityViewState extends State<EditFunctionalityView> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}


class X extends EditFunctionalityView {
  X({required super.estate, required super.functionality, required super.callback});
  override

}
 */

class EditBoilerHeatingView extends StatefulWidget {
  final Estate estate;
  final BoilerHeatingFunctionality boilerHeating;
  final Function callback;
  const EditBoilerHeatingView({Key? key,
    required this.estate,
    required this.boilerHeating,
    required this.callback}) : super(key: key);

  @override
  _EditBoilerHeatingViewState createState() => _EditBoilerHeatingViewState();
}

class _EditBoilerHeatingViewState extends State<EditBoilerHeatingView> {
  late BoilerHeatingFunctionality editedBoilerHeating;
  List <String> foundDeviceNames = [''];
  late DropdownContent possibleDevicesDropdown;

  @override
  void initState() {
    super.initState();
    editedBoilerHeating = widget.boilerHeating.clone();
    refresh();
  }

  void refresh() {
    foundDeviceNames = widget.estate.findPossibleDevices(deviceService: powerOnOffWaitingService);
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
        title: appIconAndTitle(widget.estate.name, 'muokkaa lämminvesivaraajaa'),
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
                      widget.estate,
                      editedBoilerHeating.operationModes,
                      boilerHeatingParameterSetting,
                      refresh
                ),
                readyWidget( () async {
                  Device device = widget.estate.myDeviceFromName(possibleDevicesDropdown.currentString());
                  // remove earlier version of boilerHeating
                  widget.boilerHeating.unPairAll();
                  widget.estate.removeFunctionality(widget.boilerHeating);
                  widget.boilerHeating.remove();
                  // add new version
                  editedBoilerHeating.pair(device);
                  await editedBoilerHeating.init();
                  await editedBoilerHeating.operationModes.selectIndex(0);
                  widget.estate.addFunctionality(editedBoilerHeating);
                  // exit
                  widget.callback();
                  log.info('${widget.estate.name}: lämmivesivaraajaa päivitetty');
                  Navigator.pop(context, true);
                }
                )
              ])
        )
      );
  }
}
