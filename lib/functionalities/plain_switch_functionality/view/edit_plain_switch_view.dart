import 'dart:math';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';

import '../../../devices/device/device.dart';
import '../../../estate/estate.dart';
import '../../../logic/dropdown_content.dart';
import '../../../look_and_feel.dart';
import '../../../view/my_dropdown_widget.dart';
import '../../../view/ready_widget.dart';

class EditPlainSwitchView extends StatefulWidget {
  final Estate estate;
  final bool createNew;
  final String switchType;
  final PlainSwitchFunctionality switchFunctionality;
  final Function callback;
  const EditPlainSwitchView({Key? key,
    required this.estate,
    required this.createNew,
    required this.switchType,
    required this.switchFunctionality,
    required this.callback}) : super(key: key);

  @override
  _EditPlainSwitchViewState createState() => _EditPlainSwitchViewState();
}

class _EditPlainSwitchViewState extends State<EditPlainSwitchView> {
  late PlainSwitchFunctionality plainSwitchFunctionality;
  List <String> foundDeviceNames = [''];
  late DropdownContent possibleDevicesDropdown;

  @override
  void initState() {
    super.initState();
    if (widget.createNew) {
      plainSwitchFunctionality = widget.switchFunctionality;
    }
    else {
      plainSwitchFunctionality = (widget.switchFunctionality as PlainSwitchFunctionality).clone();
    }
    refresh();
  }

  List<String> findPossibleDevices(List<Device> devices) {
    List<String> list = [];
    for (var device in devices) {
      if (device.services.offerService('powerOnOffService')) {
        list.add(device.name);
      }
    }
    return list;
  }

  void refresh() {
    foundDeviceNames = findPossibleDevices(widget.estate.devices);
    int index = max(0, foundDeviceNames.indexOf(plainSwitchFunctionality.id));
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
            title: appIconAndTitle(widget.estate.name, widget.createNew ? 'luo kytkin' : 'muokkaa kytkintä'),
      ), // new line
      body: SingleChildScrollView(
        child:
          foundDeviceNames.isEmpty
          ? Column(children: <Widget>[
            Container(
              margin: myContainerMargin,
              padding: myContainerPadding,
              height: 200,
              child: InputDecorator(
                decoration: InputDecoration(labelText: widget.switchType), //k
                child:
                Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        margin: myContainerMargin,
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                        child: Text('Asunnossa ei ole laitteita, jossa tarvittava virtakytkin.'
                                    'Lisää ensin asuntoon vaadittava laite')
                        ),
                      Container(
                        margin: myContainerMargin,
                        padding: myContainerPadding,
                        child: Tooltip(
                          message: 'Paina tästä poistuaksesi näytöltä',
                          child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      backgroundColor: mySecondaryColor,
                                      side: const BorderSide(
                                          width: 2, color: mySecondaryColor),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(10))),
                                      elevation: 10),
                                  onPressed: () async {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text(
                                    'Ok',
                                    maxLines: 1,
                                    style: TextStyle(color: mySecondaryFontColor),
                                    textScaler: const TextScaler.linear(2.2),
                                  ),
                                ))),
                      ])))])
              : Column(children: <Widget>[
                    Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      height: 200,
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: widget.switchType), //k
                        child:
                          Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Valitse sähkökatkaisin -laite:'),
                            Container(
                              margin: myContainerMargin,
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Laitteen nimi'),
                                child: SizedBox(
                                  height: 30,
                                  width: 120,
                                  child: MyDropdownWidget(
                                    keyString: 'plainSwitchDevices',
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
                                Container(
                                  margin: myContainerMargin,
                                  padding: myContainerPadding,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                        labelText: 'Laitteen yksityiskohtaiset tiedot'),
                                    child: Text('voisiko tähän lisätä valitun laitteen tiedot')
                                )
                            ),
                          ]),
                      ),
                    ),
                    readyWidget(() async {
                      Device device = widget.estate.myDeviceFromName(possibleDevicesDropdown.currentString());
                      if (! widget.createNew) {
                        widget.switchFunctionality.unPairAll();
                        widget.estate.removeFunctionality(widget.switchFunctionality);
                      }
                      plainSwitchFunctionality.pair(device);
                      widget.estate.addFunctionality(plainSwitchFunctionality);
                      widget.estate.addView(plainSwitchFunctionality.myView());
                      await plainSwitchFunctionality.init();
                      widget.callback(plainSwitchFunctionality);
                      log.info('${widget.estate.name}: laite ${device.name}(${device.id}) asetettu toimintoon: ${widget.switchType}"');
                      showSnackbarMessage('laitteen tietoja päivitetty!');
                      Navigator.pop(context, true);
                    })
                  ])
              )
          );

  }
}

String _resolvedBonsoirServiceDetailedData(ResolvedBonsoirService bsData) {
  return 'IP-osoite: ${bsData.ip ?? '-'}, portti: ${bsData.port ?? '-'}\n'
  'attribuutit: ${bsData.attributes.toString()}';
}