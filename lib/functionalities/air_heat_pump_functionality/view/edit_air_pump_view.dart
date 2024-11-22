import 'dart:math';

import 'package:flutter/material.dart';

import 'package:koti/operation_modes/view/edit_operation_mode_view.dart';
import 'package:koti/view/interrupt_editing_widget.dart';

import '../../../devices/device/device.dart';
import '../../../estate/estate.dart';
import '../../../logic/dropdown_content.dart';
import '../../../look_and_feel.dart';
import '../../../operation_modes/view/edit_generic_operation_modes_view.dart';
import '../../../service_catalog.dart';
import '../../../view/my_dropdown_widget.dart';
import '../../../view/ready_widget.dart';
import '../air_heat_pump.dart';

class EditAirPumpView extends StatefulWidget {
  final Estate estate;
  final bool createNew;
  final AirHeatPump airHeatPumpInput;
  const EditAirPumpView({Key? key, required this.estate, required this.createNew, required this.airHeatPumpInput}) : super(key: key);

  @override
  _EditAirPumpViewState createState() => _EditAirPumpViewState();
}

class _EditAirPumpViewState extends State<EditAirPumpView> {

  String deviceName = '';
  late AirHeatPump airHeatPump;
  List <String> foundDeviceNames = [''];
  late DropdownContent possibleDevicesDropdown;

  @override
  void initState() {
    super.initState();
    if (widget.createNew) {
      airHeatPump = widget.airHeatPumpInput;
      airHeatPump.addPredefinedOperationMode(
          'Pois', 'powerOnOffService', false);
    }
    else {
      airHeatPump = widget.airHeatPumpInput.clone();
      deviceName = airHeatPump
          .myPumpDevice()
          .name;
    }
    refresh();
  }

  void refresh() {
    foundDeviceNames =
        widget.estate.findPossibleDevices(deviceService: airHeatPumpService);
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
          title: appIconAndTitle(widget.estate.name, widget.createNew
              ? 'luo ilmalämpöpumppu'
              : 'muokkaa ilmalämpöpumppua'),
        ), // new line
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
              Container(
                margin: myContainerMargin,
                padding: myContainerPadding,
                height: 200,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Ohjattava laite'), //k
                  child:
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          margin: myContainerMargin,
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                                labelText: 'laite'),
                            child: SizedBox(
                                height: 30,
                                width: 120,
                                child: MyDropdownWidget(
                                    keyString: 'airPumpDropdown',
                                    dropdownContent: possibleDevicesDropdown,
                                    setValue: (newValue) {
                                      possibleDevicesDropdown
                                          .setIndex(newValue);
                                      setState(() {});
                                    }
                                )
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
              operationModeHandling2(
                  context,
                  widget.estate,
                  airHeatPump.operationModes,
                  airPumpParameterSetting,
                      () {
                    setState(() {});
                  }
              ),
              readyWidget(() async {
                Device device = widget.estate.myDeviceFromName(
                    possibleDevicesDropdown.currentString());
                if (widget.createNew) {
                  airHeatPump.pair(device);
                  widget.estate.addFunctionality(airHeatPump);
                  widget.estate.addView(airHeatPump.myView());
                  await airHeatPump.init();
                  await airHeatPump.operationModes.selectIndex(0);
                  log.info('${widget.estate.name}: laite "${device
                      .name}" liitetty ilmalämpöpumpun ohjaukseen');
                }
                else {
                  widget.airHeatPumpInput.unPairAll();
                  widget.estate.addFunctionality(airHeatPump);
                  airHeatPump.pair(device);
                  log.info('${widget.estate.name}: ilmalämpöpumpun "${device
                      .name}" ohjausta päivitetty');
                }
                showSnackbarMessage('laitteen $deviceName tietoja päivitetty!');
                Navigator.pop(context, true);
              }),
            ])
        )
    );
  }
}


