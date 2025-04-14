import 'dart:math';

import 'package:flutter/material.dart';
import 'package:koti/functionalities/boiler_heating/view/controlled_devices_widget.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';
import 'package:koti/service_catalog.dart';
import 'package:koti/view/no_needed_resources_widget.dart';

import '../../../../devices/device/device.dart';
import '../../../../estate/estate.dart';
import '../../../../logic/dropdown_content.dart';
import '../../../../look_and_feel.dart';
import '../../../../operation_modes/view/edit_generic_operation_modes_view.dart';
import '../../../../view/ready_widget.dart';
import '../../../../view/interrupt_editing_widget.dart';
import '../../../estate/environment.dart';
import '../../boiler_heating/view/boiler_heating_parameter_setting.dart';

class CreatePlainSwitchView extends StatefulWidget {
  final Environment environment;
  const CreatePlainSwitchView({Key? key,
    required this.environment}) : super(key: key);

  @override
  _CreatePlainSwitchViewState createState() => _CreatePlainSwitchViewState();
}

class _CreatePlainSwitchViewState extends State<CreatePlainSwitchView> {
  PlainSwitchFunctionality plainSwitch = PlainSwitchFunctionality();
  List <String> foundDeviceNames = [''];
  late DropdownContent possibleDevicesDropdown;
  late Estate estate;

  @override
  void initState() {
    super.initState();
    estate = widget.environment.myEstate();
    possibleDevicesDropdown = DropdownContent(foundDeviceNames, '', 0);
    plainSwitch.addPredefinedOperationMode('Päällä', powerOnOffWaitingService , true);
    plainSwitch.addPredefinedOperationMode('Pois', powerOnOffWaitingService , false);
    refresh();
  }

  void refresh() {
    foundDeviceNames = estate.findPossibleDevices(deviceService: powerOnOffWaitingService);
    int index = max(0, foundDeviceNames.indexOf(plainSwitch.id));
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
        leading: interruptEditingWidget(context, () async {plainSwitch.remove();}),
        title: appIconAndTitle(widget.environment.name, 'luo sähkökytkin'),
      ), // new line
      body: SingleChildScrollView(
        child:
          foundDeviceNames.isEmpty
            ? noNeededResources(context, 'Asunnossa ei ole laitteita, jossa tarvittava virtakytkin.'
                                         'Lisää ensin asuntoon vaadittava laite')
            : Column(children: <Widget>[
                controlledDevicesWidget('Ohjattava laite', 'Sähkökatkaisin', possibleDevicesDropdown, () {setState(() {});}),
                operationModeHandling2(
                  context,
                  widget.environment,
                  plainSwitch.operationModes,
                  boilerHeatingParameterSetting,
                  refresh
                ),
                readyWidget(
                        () async {
                          Device device = estate.myDeviceFromName(possibleDevicesDropdown.currentString());
                          plainSwitch.pair(device);
                          await plainSwitch.init();
                          widget.environment.addFunctionality(plainSwitch);
                          await plainSwitch.operationModes.selectIndex(0);
                          log.info('${widget.environment.name}: laite "${device.name}" liitetty sähkökytkimeen');
                          Navigator.pop(context, true);
                        }
                    )
                  ])
              )
          );
  }
}

Future <bool> createPlainSwitchSystem(BuildContext context, Environment environment) async {

  bool success = await Navigator.push(context, MaterialPageRoute(
      builder: (context)
      {
        return CreatePlainSwitchView(
            environment: environment
        );
      }
  ));

  return success;
}



