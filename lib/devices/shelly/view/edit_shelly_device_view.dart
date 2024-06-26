import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:koti/devices/wlan/active_wifi_name.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';
import 'package:provider/provider.dart';

import '../../../estate/estate.dart';
import '../../../functionalities/boiler_heating/boiler_heating_functionality.dart';
import '../../../functionalities/functionality/functionality.dart';
import '../../../logic/dropdown_content.dart';
import '../../../look_and_feel.dart';
import '../../../view/my_dropdown_widget.dart';
import '../../shelly_pro2/shelly_pro2.dart';
import '../../shelly_timer_switch/shelly_timer_switch.dart';
import '../shelly_device.dart';
import '../shelly_scan.dart';

const onOffSwitch = 'on/off -kytkin';
const timeSwitch = 'aikakatkaiseva kytkin';
const spotElectricitySwitch = 'sähkönhintakytkin';

DropdownContent _functionality = DropdownContent(
    [onOffSwitch, timeSwitch, spotElectricitySwitch], 'functionality', 0);

Functionality _getFunctionalityWithShelly(String newFunctionalityText) {
  switch (newFunctionalityText) {
    case onOffSwitch:
      {
        PlainSwitchFunctionality plainSwitchFunctionality = PlainSwitchFunctionality();
        ShellyTimerSwitch shellyTimerSwitch = ShellyTimerSwitch();
        plainSwitchFunctionality.pair(shellyTimerSwitch);
        return plainSwitchFunctionality;
      }
    case timeSwitch:
      {
        PlainSwitchFunctionality plainSwitchFunctionality = PlainSwitchFunctionality();
        ShellyTimerSwitch shellyTimerSwitch = ShellyTimerSwitch();
        plainSwitchFunctionality.pair(shellyTimerSwitch);
        return plainSwitchFunctionality;
      }
    case spotElectricitySwitch:
      {
        BoilerHeatingFunctionality boilerFunctionality = BoilerHeatingFunctionality();
        ShellyPro2 shellyPro2 = ShellyPro2();
        boilerFunctionality.pair(shellyPro2);
        return boilerFunctionality;
      }
    default:
      {
        PlainSwitchFunctionality plainSwitchFunctionality = PlainSwitchFunctionality();
        ShellyTimerSwitch shellyTimerSwitch = ShellyTimerSwitch();
        plainSwitchFunctionality.pair(shellyTimerSwitch);
        return plainSwitchFunctionality;
      }
  }
}

List<String> _functionalityDescription = [
  'Kytkin joko päällä tai pois päältä.',
  'Jos laite käyttämättä tietyn aikaa, niin se menee pois päältä itsestään. '
  'Kytkin oppii käyttämättömyydensä (minimivirrankulutuksen).',
  'Kytkimen asento määräytyy sähkön hinnan perusteella'
];

class EditShellyDeviceView extends StatefulWidget {
  final Estate estate;
  final String shellyId;
  final Function callback;
  const EditShellyDeviceView({Key? key, required this.estate, required this.shellyId, required this.callback}) : super(key: key);

  @override
  _EditShellyDeviceViewState createState() => _EditShellyDeviceViewState();
}

class _EditShellyDeviceViewState extends State<EditShellyDeviceView> {
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  final myDeviceNameController = TextEditingController();
  late ResolvedBonsoirService bsData;
  String shellyDeviceName = '';

  @override
  void initState() {
    super.initState();
    bsData = shellyScan.resolveServiceData(widget.shellyId);
    myDeviceNameController.text = shellyDeviceName;
    refresh();
  }

  void refresh() {
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
    return Consumer<Estate>(
        builder: (context, estate, childNotUsed) {
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
                title: appTitle('muokkaa laitteen tietoja'),
              ), // new line
              body: SingleChildScrollView(
                  child: Column(children: <Widget>[
                    Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      height: 150,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Laitteen tiedot'), //k
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Spacer(),
                            Row(children: <Widget>[
                              Flexible(flex:1, child: Text('Tunnus: ')),
                              Flexible(flex:5, child: AutoSizeText(widget.shellyId, style:TextStyle(fontSize:20,color:Colors.blue))),
                            ]),
                            Spacer(),
                            TextField(
                              key: const Key('deviceName'),
                              decoration: const InputDecoration(
                                labelText: 'Laitteen nimi',
                                hintText: 'kirjoita tähän laitteen nimi',
                              ),
                              focusNode: _focusNode,
                              autofocus: false,
                              textInputAction: TextInputAction.done,
                              controller: myDeviceNameController,
                              maxLines: 1,
                              onChanged: (String newText) {
                                shellyDeviceName = newText;
                              },
                              onEditingComplete: () {
                                _focusNode.unfocus();
                          }),
                        ]),
                      ),
                    ),
                    Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Toiminto'), //k
                        child: Row(children: <Widget>[
                          Expanded(
                            flex: 15,
                            child: Container(
                              margin: myContainerMargin,
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Toiminto'),
                                child: SizedBox(
                                  height: 30,
                                  width: 120,
                                  child: MyDropdownWidget(
                                    dropdownContent: _functionality,
                                    setValue: (newValue) {
                                                _functionality
                                                    .setIndex(newValue);
                                                setState(() {});
                                              }
                                  )
                                ),
                                    ),
                                  ),
                                ),
                                const Spacer(flex: 1),
                                Expanded(
                                    flex: 20,
                                    child: Text(_functionalityDescription[_functionality.currentIndex()])),
                              ]),
                            )),
                    Container(
                        margin: myContainerMargin,
                        padding: myContainerPadding,
                        child: InputDecorator(
                            decoration: const InputDecoration(
                                labelText: 'Laitteen yksityiskohtaiset tiedot'),
                            child: Text(_resolvedBonsoirServiceDetailedData(bsData))
                        )
                    ),
                    Container(
                        margin: myContainerMargin,
                        padding: myContainerPadding,
                        child: Tooltip(
                            message:
                            'Fu tästä tallentaaksesi muutokset ja poistuaksesi näytöltä',
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
                                Functionality newFunctionality =
                                  _getFunctionalityWithShelly(_functionality.currentString());
                                ShellyDevice shellyDevice = newFunctionality.device as ShellyDevice;
                                shellyDevice.name = shellyDeviceName;
                                shellyDevice.id = widget.shellyId;
                                await shellyDevice.init();
                                await newFunctionality.init();
                                widget.estate.addDevice(shellyDevice);
                                widget.estate.addFunctionality(newFunctionality);
                                widget.estate.addView(newFunctionality.myView());
                                widget.callback(newFunctionality);
                                log.info('${widget.estate.name}: laite ${shellyDeviceName}(${shellyDevice.id}) asetettu toimintoon: ${_functionality.currentString()}"${_functionality.currentString()}"');

                                showSnackbarMessage('laitteen tietoja päivitetty!');
                                Navigator.pop(context, true);
                              },
                              child: const Text(
                                'Valmis',
                                maxLines: 1,
                                style: TextStyle(color: mySecondaryFontColor),
                                textScaleFactor: 2.2,
                              ),
                            ))),
                  ])
              )
          );
        }
    );
  }
}

String _resolvedBonsoirServiceDetailedData(ResolvedBonsoirService bsData) {
  return 'IP-osoite: ${bsData.ip ?? '-'}, portti: ${bsData.port ?? '-'}\n'
  'attribuutit: ${bsData.attributes.toString()}';
}