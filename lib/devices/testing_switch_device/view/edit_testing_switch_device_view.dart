import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../../../view/ready_widget.dart';
import '../testing_switch_device.dart';


class EditTestingSwitchDeviceView extends StatefulWidget {
  final Estate estate;
  final TestingSwitchDevice testingSwitchDevice;
  final Function callback;
  const EditTestingSwitchDeviceView({Key? key, required this.estate, required this.testingSwitchDevice, required this.callback}) : super(key: key);

  @override
  _EditTestingSwitchDeviceViewState createState() => _EditTestingSwitchDeviceViewState();
}

class _EditTestingSwitchDeviceViewState extends State<EditTestingSwitchDeviceView> {
  final FocusNode _focusNode = FocusNode();
  final myDeviceNameController = TextEditingController();
  late TestingSwitchDevice testingSwitchDevice;
  bool creatingNewDevice = false;

  @override
  void initState() {
    super.initState();
    creatingNewDevice = widget.testingSwitchDevice.name == '';
    testingSwitchDevice = widget.testingSwitchDevice.clone2() as TestingSwitchDevice;
    myDeviceNameController.text = testingSwitchDevice.name;
    refresh();
  }

  void refresh() {
  }

  @override
  void dispose() {
    _focusNode.dispose();
    myDeviceNameController.dispose();
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
                testingSwitchDevice.remove();
                Navigator.of(context).pop();
              }
            }),
            title: appIconAndTitle(widget.estate.name, creatingNewDevice ? 'anna laitteen tiedot' : 'muokkaa laitteen tietoja'),
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
                            const Spacer(),
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
                                testingSwitchDevice.name = newText;
                              },
                              onEditingComplete: () {
                                _focusNode.unfocus();
                            }),
                            const Spacer(),
                            Row(children: <Widget>[
                              const Flexible(flex:1, child: Text('Tunnus: ')),
                              Flexible(flex:5, child: AutoSizeText(testingSwitchDevice.id, style:const TextStyle(fontSize:20,color:Colors.blue))),
                            ]),

                        ]),
                      ),
                    ),
                    readyWidget(() async {
                      // remove earlier version
                      widget.estate.removeDevice(widget.testingSwitchDevice.id);
                      widget.testingSwitchDevice.remove();
                      // add the new version
                      await testingSwitchDevice.init();
                      widget.estate.addDevice(testingSwitchDevice);
                      log.info('${widget.estate.name}: laite tunnuksella "${testingSwitchDevice.id}" otettu käyttöön nimellä "${testingSwitchDevice.name}"');

                      showSnackbarMessage('laitteen tietoja päivitetty!');
                      Navigator.pop(context, true);

                    }
                    )
                  ])
              )
          );

  }
}
