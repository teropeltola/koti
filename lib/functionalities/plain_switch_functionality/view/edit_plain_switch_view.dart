import 'dart:math';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';

import '../../../devices/device/device.dart';
import '../../../estate/estate.dart';
import '../../../logic/dropdown_content.dart';
import '../../../logic/events.dart';
import '../../../logic/observation.dart';
import '../../../look_and_feel.dart';
import '../../../operation_modes/view/edit_generic_operation_modes_view.dart';
import '../../../service_catalog.dart';
import '../../../view/interrupt_editing_widget.dart';
import '../../../view/no_needed_resources_widget.dart';
import '../../../view/ready_widget.dart';
import '../../boiler_heating/view/boiler_heating_parameter_setting.dart';
import '../../boiler_heating/view/controlled_devices_widget.dart';

class EditPlainSwitchView extends StatefulWidget {
  final Estate estate;
  final PlainSwitchFunctionality switchFunctionality;
  final Function callback;

  const EditPlainSwitchView({Key? key,
    required this.estate,
    required this.switchFunctionality,
    required this.callback}) : super(key: key);

  @override
  _EditPlainSwitchViewState createState() => _EditPlainSwitchViewState();
}

class _EditPlainSwitchViewState extends State<EditPlainSwitchView> {
  late PlainSwitchFunctionality plainSwitch;
  List <String> foundDeviceNames = [''];
  late DropdownContent possibleDevicesDropdown;

  @override
  void initState() {
    super.initState();
    plainSwitch = widget.switchFunctionality.clone();
    refresh();
  }

  List<String> findPossibleDevices(List<Device> devices) {
    List<String> list = [];
    for (var device in devices) {
      if (device.services.offerService(powerOnOffWaitingService)) {
        list.add(device.name);
      }
    }
    return list;
  }

  void refresh() {
    foundDeviceNames = findPossibleDevices(widget.estate.devices);
    int index = max(0, foundDeviceNames.indexOf(plainSwitch.id));
    possibleDevicesDropdown = DropdownContent(foundDeviceNames, '', index);
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
          plainSwitch.remove();
          widget.callback();
        }),
        title: appIconAndTitle(widget.estate.name, 'muokkaa kytkintä'),
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
                widget.estate,
                plainSwitch.operationModes,
                boilerHeatingParameterSetting,
                refresh
            ),
            readyWidget(() async {
              Device device = widget.estate.myDeviceFromName(possibleDevicesDropdown.currentString());
              // remove earlier version
              widget.switchFunctionality.unPairAll();
              widget.estate.removeFunctionality(widget.switchFunctionality);
              // add new version
              plainSwitch.pair(device);
              await plainSwitch.init();
              widget.estate.addFunctionality(plainSwitch);
              widget.callback(plainSwitch);
              events.write(widget.estate.id, device.id, ObservationLevel.informatic, 'laite asetettu sähkökytkimeksi');
              showSnackbarMessage('laitteen tietoja päivitetty!');
              Navigator.pop(context, true);
            })
          ])
        )
      );
  }
}

String _resolvedBonsoirServiceDetailedData(ResolvedBonsoirService bsData) {
  return 'IP-osoite: ${bsData.host ?? '-'}, portti: ${bsData.port ?? '-'}\n'
  'attribuutit: ${bsData.attributes.toString()}';
}