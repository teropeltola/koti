import 'dart:math';

import 'package:flutter/material.dart';
import 'package:koti/estate/environment.dart';

import 'package:koti/operation_modes/view/edit_operation_mode_view.dart';
import 'package:koti/view/interrupt_editing_widget.dart';

import '../../../devices/device/device.dart';
import '../../../estate/estate.dart';
import '../../../logic/dropdown_content.dart';
import '../../../look_and_feel.dart';
import '../../../operation_modes/view/edit_generic_operation_modes_view.dart';
import '../../../service_catalog.dart';
import '../../../view/ready_widget.dart';
import '../../boiler_heating/view/controlled_devices_widget.dart';
import '../air_heat_pump.dart';

class EditAirPumpView extends StatefulWidget {
  final Environment environment;
  final AirHeatPump airHeatPumpInput;
  final Function callback;
  const EditAirPumpView({Key? key, required this.environment, required this.airHeatPumpInput, required this.callback}) : super(key: key);

  @override
  _EditAirPumpViewState createState() => _EditAirPumpViewState();
}

class _EditAirPumpViewState extends State<EditAirPumpView> {

  late AirHeatPump airHeatPump;
  List <String> foundDeviceNames = [''];
  late DropdownContent possibleDevicesDropdown;
  late Estate estate;

  @override
  void initState() {
    super.initState();
    estate = widget.environment.myEstate();
    airHeatPump = widget.airHeatPumpInput.clone();
    refresh();
  }

  void refresh() {
    foundDeviceNames = estate.findPossibleDevices(deviceService: airHeatPumpService);
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
          leading: interruptEditingWidget(context, () async {
            airHeatPump.remove();
          }),
          title: appIconAndTitle(widget.environment.name, 'muokkaa ilmalämpöpumppua'),
        ), // new line
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
              controlledDevicesWidget('Ohjattava laite', 'Ilmalämpöpumppu', possibleDevicesDropdown, () {setState(() {});}),
              operationModeHandling2(
                  context,
                  widget.environment,
                  airHeatPump.operationModes,
                  airPumpParameterSetting,
                      () {
                    setState(() {});
                  }
              ),
              readyWidget(() async {
                Device device = estate.myDeviceFromName(
                    possibleDevicesDropdown.currentString());
                // remove earlier version
                widget.airHeatPumpInput.unPairAll();
                widget.environment.removeFunctionality(widget.airHeatPumpInput);
                // add new version

                airHeatPump.pair(device);
                await airHeatPump.init();
                widget.environment.addFunctionality(airHeatPump);
                widget.callback();

                log.info('${widget.environment.name}: ilmalämpöpumpun "${device
                      .name}" ohjausta päivitetty');

                showSnackbarMessage('laitteen ${device.name} ohjausta päivitetty!');
                Navigator.pop(context, true);
              }),
            ])
        )
    );
  }
}


