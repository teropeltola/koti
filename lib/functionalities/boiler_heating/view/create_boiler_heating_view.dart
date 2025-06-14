import 'dart:math';

import 'package:flutter/material.dart';
import 'package:koti/estate/environment.dart';
import 'package:koti/functionalities/boiler_heating/view/controlled_devices_widget.dart';
import 'package:koti/view/no_needed_resources_widget.dart';

import '../../../../devices/device/device.dart';
import '../../../../estate/estate.dart';
import '../../../../logic/dropdown_content.dart';
import '../../../../look_and_feel.dart';
import '../../../../operation_modes/view/edit_generic_operation_modes_view.dart';
import '../../../../view/ready_widget.dart';
import '../../../../view/interrupt_editing_widget.dart';
import '../../../service_catalog.dart';
import '../boiler_heating_functionality.dart';
import 'boiler_heating_parameter_setting.dart';

class CreateBoilerHeatingView extends StatefulWidget {
  final Environment environment;
  const CreateBoilerHeatingView({Key? key,
    required this.environment}) : super(key: key);

  @override
  _CreateBoilerHeatingViewState createState() => _CreateBoilerHeatingViewState();
}

class _CreateBoilerHeatingViewState extends State<CreateBoilerHeatingView> {
  BoilerHeatingFunctionality boilerHeatingFunctionality = BoilerHeatingFunctionality();
  List <String> foundDeviceNames = [''];
  late DropdownContent possibleDevicesDropdown;
  late Estate estate;

  @override
  void initState() {
    super.initState();
    estate = widget.environment.myEstate();
    boilerHeatingFunctionality.addPredefinedOperationMode('Päällä', powerOnOffWaitingService , true);
    boilerHeatingFunctionality.addPredefinedOperationMode('Pois', powerOnOffWaitingService , false);
    refresh();
  }

  void refresh() {
    foundDeviceNames = estate.findPossibleDevices(deviceService: powerOnOffWaitingService);
    int index = max(0, foundDeviceNames.indexOf(boilerHeatingFunctionality.id));
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
        leading: interruptEditingWidget(context, () async {boilerHeatingFunctionality.remove();}),
        title: appIconAndTitle(widget.environment.name, 'luo lämminvesivaraaja'),
      ), // new line
      body: SingleChildScrollView(
        child:
          foundDeviceNames.isEmpty
            ? noNeededResources(context, 'Asunnossa ei ole laitteita, jossa tarvittava virtakytkin.'
                                         'Lisää ensin asuntoon vaadittava laite')
            : Column(children: <Widget>[
                controlledDevicesWidget('Ohjattava laite', 'Lämminvesivaraajan sähköohjaus', possibleDevicesDropdown, () {setState(() {});}),
                operationModeHandling2(
                  context,
                  widget.environment,
                  boilerHeatingFunctionality.operationModes,
                  boilerHeatingParameterSetting,
                  refresh
                ),
                readyWidget(
                        () async {
                          Device device = estate.myDeviceFromName(possibleDevicesDropdown.currentString());
                          boilerHeatingFunctionality.pair(device);
                          await boilerHeatingFunctionality.init();
                          await boilerHeatingFunctionality.operationModes.selectIndex(0);
                          widget.environment.addFunctionality(boilerHeatingFunctionality);
                          log.info('${widget.environment.name}: laite "${device.name}" liitetty lämminvesivaraajaan');
                          Navigator.pop(context, true);
                        }
                    )
                  ])
              )
          );
  }
}

Future <bool> createBoilerWarmingSystem(BuildContext context, Environment environment) async {

  bool success = await Navigator.push(context, MaterialPageRoute(
      builder: (context)
      {
        return CreateBoilerHeatingView(
            environment: environment
        );
      }
  ));

  return success;

}



