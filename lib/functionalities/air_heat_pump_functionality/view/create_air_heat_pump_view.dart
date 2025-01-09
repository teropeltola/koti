import 'dart:math';

import 'package:flutter/material.dart';
import 'package:koti/functionalities/boiler_heating/view/controlled_devices_widget.dart';
import 'package:koti/service_catalog.dart';
import 'package:koti/view/no_needed_resources_widget.dart';

import '../../../../devices/device/device.dart';
import '../../../../estate/estate.dart';
import '../../../../logic/dropdown_content.dart';
import '../../../../look_and_feel.dart';
import '../../../../operation_modes/view/edit_generic_operation_modes_view.dart';
import '../../../../view/ready_widget.dart';
import '../../../../view/interrupt_editing_widget.dart';
import '../../../operation_modes/view/edit_operation_mode_view.dart';
import '../air_heat_pump.dart';

class CreateAirHeatPumpView extends StatefulWidget {
  final Estate estate;
  const CreateAirHeatPumpView({Key? key,
    required this.estate}) : super(key: key);

  @override
  _CreateAirHeatPumpViewState createState() => _CreateAirHeatPumpViewState();
}

class _CreateAirHeatPumpViewState extends State<CreateAirHeatPumpView> {
  AirHeatPump airHeatPump = AirHeatPump();
  List <String> foundDeviceNames = [''];
  late DropdownContent possibleDevicesDropdown;

  @override
  void initState() {
    super.initState();
    airHeatPump.addPredefinedOperationMode('Päällä', "powerOnOffService" , true);
    airHeatPump.addPredefinedOperationMode('Pois', "powerOnOffService" , false);
    refresh();
  }

  void refresh() {
    foundDeviceNames = widget.estate.findPossibleDevices(deviceService: airHeatPumpService);
    int index = max(0, foundDeviceNames.indexOf(airHeatPump.id));
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
        leading: interruptEditingWidget(context, () async {airHeatPump.remove();}),
        title: appIconAndTitle(widget.estate.name, 'luo ilmalämpöpumppu'),
      ), // new line
      body: SingleChildScrollView(
        child:
          foundDeviceNames.isEmpty
            ? noNeededResources(context, 'Asunnossa ei ole laitteita, jossa tarvittava virtakytkin.'
                                         'Lisää ensin asuntoon vaadittava laite')
            : Column(children: <Widget>[
                controlledDevicesWidget('Ohjattava laite', 'Ilmalämpöpumppu', possibleDevicesDropdown, () {setState(() {});}),
                operationModeHandling2(
                  context,
                  widget.estate,
                  airHeatPump.operationModes,
                  airPumpParameterSetting,
                  refresh
                ),
                readyWidget(
                        () async {
                          Device device = widget.estate.myDeviceFromName(possibleDevicesDropdown.currentString());
                          airHeatPump.pair(device);
                          await airHeatPump.init();
                          await airHeatPump.operationModes.selectIndex(0);
                          widget.estate.addFunctionality(airHeatPump);
                          log.info('${widget.estate.name}: laite "${device.name}" liitetty ilmalämpöpumpun ohjaukseen');
                          Navigator.pop(context, true);
                        }
                    )
                  ])
              )
          );
  }
}

Future <bool> createAirHeatPumpSystem(BuildContext context, Estate estate) async {

  bool success = await Navigator.push(context, MaterialPageRoute(
      builder: (context)
      {
        return CreateAirHeatPumpView(
            estate: estate
        );
      }
  ));

  return success;

}



