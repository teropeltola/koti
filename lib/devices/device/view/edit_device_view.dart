import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';
import 'package:provider/provider.dart';

import '../../../estate/estate.dart';
import '../../../functionalities/functionality/functionality.dart';
import '../../../logic/dropdown_content.dart';
import '../../../look_and_feel.dart';
import '../../../view/my_dropdown_widget.dart';
import '../../../view/ready_widget.dart';
import '../device.dart';

DropdownContent _functionality = DropdownContent(
    ['on/off -kytkin', 'aikakatkaiseva kytkin'], 'functionality', 0);

List<String> _functionalityDescription = [
  'Kytkin joko päällä tai pois päältä.',
  'Jos laite käyttämättä tietyn aikaa, niin se menee pois päältä itsestään. '
  'Kytkin oppii käyttämättömyydensä (minimivirrankulutuksen).'
];

class EditDeviceView extends StatefulWidget {
  final Estate estate;
  final Functionality functionality;
  final Device device;
  const EditDeviceView({Key? key, required this.estate, required this.functionality,required this.device}) : super(key: key);

  @override
  _EditDeviceViewState createState() => _EditDeviceViewState();
}

class _EditDeviceViewState extends State<EditDeviceView> {
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  final myDeviceNameController = TextEditingController();
  late Device newDevice;

  @override
  void initState() {
    super.initState();
    newDevice = widget.device.clone();
    myDeviceNameController.text = newDevice.name;
    refresh();
  }

  void refresh() {
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeWifi.dispose();
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
                          'Poistuttaessa ....',
                          'Haluatko poistua... ?'
                      );
                      if (doExit) {
                        Navigator.of(context).pop();
                      }
                    }),
                title: appIconAndTitle(widget.estate.name, 'muokkaa laitteen tietoja'),
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
                              Flexible(flex:5, child: AutoSizeText(newDevice.id, style:TextStyle(fontSize:20,color:Colors.blue))),
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
                                newDevice.name = newText;
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
                                    keyString: 'deviceFunctionality',
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
                            child: Text(widget.device.detailsDescription())
                        )
                    ),
                    readyWidget(() async {
                      if (_functionality.currentIndex() == 0) {
                        PlainSwitchFunctionality newFunctionality = PlainSwitchFunctionality();
                        newFunctionality.pair(newDevice);
                        newFunctionality.init();
                        widget.estate.addFunctionality(newFunctionality);
                        log.info('${widget.estate.name}: laite ${newDevice.name}(${newDevice.id}) asetettu toimintoon "${_functionality.currentString()}"');
                      }
                      else {

                      }
                      widget.estate.addDevice(newDevice);
                      showSnackbarMessage('laitteen tietoja päivitetty!');
                      Navigator.pop(context, true);
                    }),
                  ])
              )
          );
        }
    );
  }
}
