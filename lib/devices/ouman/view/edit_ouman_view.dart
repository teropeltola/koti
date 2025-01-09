import 'package:flutter/material.dart';
import 'package:koti/logic/observation.dart';

import '../../../estate/estate.dart';
import '../../../logic/events.dart';
import '../../../look_and_feel.dart';
import '../../../view/ready_widget.dart';
import '../ouman_device.dart';

class EditOumanView extends StatefulWidget {
  final Estate estate;
    const EditOumanView({Key? key,
    required this.estate}) : super(key: key);

  @override
  _EditOumanViewState createState() => _EditOumanViewState();
}

class _EditOumanViewState extends State<EditOumanView> {
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _ipFocusNode = FocusNode();
  final FocusNode _usercodeFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final myNameController = TextEditingController();
  final myIpAddressController = TextEditingController();
  final myUsernameController = TextEditingController();
  final myPasswordController = TextEditingController();
  bool passwordVisible = false;
  late OumanDevice oumanDevice;
  bool createNew = false;

  bool _oumanAlreadyExists() {
    int index = widget.estate.devices.indexWhere((e){return e.runtimeType == OumanDevice;} );
    return (index >= 0);
  }

  OumanDevice _existingOumanDevice() {
  int index = widget.estate.devices.indexWhere((e){return e.runtimeType == OumanDevice;} );
  return widget.estate.devices[index] as OumanDevice;
}

  @override
  void initState() {
    super.initState();
    if (_oumanAlreadyExists()) {
      createNew = false;
      oumanDevice = _existingOumanDevice().clone2() as OumanDevice;
      _callAsyncInit();
      myNameController.text = oumanDevice.name;
      myIpAddressController.text = oumanDevice.ipAddress;
    }
    else {
      oumanDevice = OumanDevice();
      myNameController.text = oumanDevice.name;
      createNew = true;
    }
    refresh();
  }

  void _callAsyncInit() async {
    // fetch username and password with a little delay
    myUsernameController.text = await oumanDevice.webLoginCredentials.username();
    myPasswordController.text = await oumanDevice.webLoginCredentials.password();
    setState(() {});
  }

  void refresh() {
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _ipFocusNode.dispose();
    _usercodeFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Keskeytä laitteen tietojen ${createNew ? 'luonti' : 'muokkaus'}',
                    onPressed: () async {
                      // check if the user wants to cancel all the changes
                      bool doExit = await askUserGuidance(context,
                          'Poistuttaessa häviää keskeneräiset tiedot.',
                          'Haluatko silti poistua näytöltä?'
                      );
                      if (doExit) {
                        oumanDevice.remove();
                        Navigator.of(context).pop(false);
                      }
                    }),
                title: appIconAndTitle(widget.estate.name, createNew ? 'luo Oumanin tiedot' : 'muokkaa Oumanin tietoja'),
              ), // new line
              body: SingleChildScrollView(
                  child: Column(children: <Widget>[
                    Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      height: 200,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Laitteen tiedot'), //k
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Spacer(),
                              const Text('Laitteen kutsumanimi: '),
                              const Spacer(),
                              TextField(
                                  key: const Key('oDeviceName'),
                                  decoration: const InputDecoration(
                                    labelText: 'nimi',
                                    hintText: 'kirjoita tähän laitteen nimi',
                                  ),
                                  focusNode: _nameFocusNode,
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  controller: myNameController,
                                  maxLines: 1,
                                  onEditingComplete: () {
                                    _nameFocusNode.unfocus();
                                  }
                              ),

                              const Text('Paikallisverkon kiinteä IP-osoite: '),
                              const Spacer(),
                              TextField(
                                  key: const Key('ipAddress'),
                                  decoration: const InputDecoration(
                                    labelText: 'IP-osoite',
                                    hintText: 'kirjoita tähän laitteen kiinteä IP-osoite paikallisverkossa',
                                  ),
                                  focusNode: _ipFocusNode,
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  controller: myIpAddressController,
                                  maxLines: 1,
                                  onEditingComplete: () {
                                    _ipFocusNode.unfocus();
                                  }),
                            ]),
                      ),
                    ),
                    Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Salatut tiedot'),
                        child:
                          Column(children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10,0,10,0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text('Käyttäjätunnus:'),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child:
                                      TextField(
                                        key: const Key('usernameKey'),
                                        obscureText: false,
                                        enableSuggestions: false,
                                        autocorrect: false,
                                        autofocus: false,
                                        focusNode: _usercodeFocusNode,
                                        textInputAction: TextInputAction.done,
                                        controller: myUsernameController,
                                        maxLines: 1,
                                        decoration: const InputDecoration(
                                          hintText: "käyttäjätunnus",
                                        ),
                                        onEditingComplete: () {
                                          _usercodeFocusNode.unfocus();
                                        }),
                                  ),
                              ])
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10,2,10,2),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Text('Salasana:'),
                                    ),
                                    Expanded(
                                      flex: 7,
                                      child:
                                        TextField(
                                          key: const Key('passwordKey'),
                                          obscureText: !passwordVisible,
                                          enableSuggestions: false,
                                          autocorrect: false,
                                          autofocus: false,
                                          focusNode: _passwordFocusNode,
                                          textInputAction: TextInputAction.done,
                                          controller: myPasswordController,
                                          maxLines: 1,
                                          decoration: const InputDecoration(
                                            hintText: "salasana",
                                          ),
                                          onEditingComplete: () {
                                              _usercodeFocusNode.unfocus();
                                          },
                                        ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        alignment: AlignmentDirectional.topCenter,
                                        icon: Icon(
                                          passwordVisible ? Icons.visibility : Icons.visibility_off, //change icon based on boolean value
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          passwordVisible = !passwordVisible;
                                          setState(() {});
                                        }
                                      )
                                    )
                                  ])
                            )
                      ])
                    )),
                    readyWidget(() async {
                      if (myNameController.text == '') {
                        await informMatterToUser(context,'nimi ei voi olla tyhjä', 'Korjaa se!');
                      }
                      else if (_ipAddressFaulty(myIpAddressController.text)) {
                        await informMatterToUser(context,'ip-osoite on virheellinen', 'Korjaa se muotoon "111.222.333.444"!');
                      }
                      else if (_usernameFaulty(myUsernameController.text)) {
                        await informMatterToUser(context,'käyttäjätunnus on virheellinen', 'Korjaa se!');
                      }
                      else if (_passwordFaulty(myPasswordController.text)) {
                        await informMatterToUser(context,'salasana on virheellinen', 'Korjaa se!');
                      }
                      else {
                        if (! createNew) {
                          OumanDevice oldOumanDevice = _existingOumanDevice();
                          widget.estate.removeDevice(oldOumanDevice.id);
                          oldOumanDevice.remove();
                        }
                        widget.estate.addDevice(oumanDevice);
                        oumanDevice.name = myNameController.text;
                        oumanDevice.ipAddress = myIpAddressController.text;
                        await oumanDevice
                            .webLoginCredentials
                            .initUsernameAndPassword(
                              myUsernameController.text,
                              myPasswordController.text);
                        await oumanDevice.init();
                        events.write(widget.estate.id, oumanDevice.id, ObservationLevel.informatic, 'laite luotu');
                        if (widget.estate.myWifiIsActive) {
                          bool connectionSucceeded = await oumanDevice
                            .initSuccessInCreation(widget.estate);
                          if (connectionSucceeded) {
                            showSnackbarMessage('Ouman-laitteen tietoja päivitetty!');
                            Navigator.pop(context, true);
                          }
                          else {
                            await informMatterToUser(
                              context,
                              'Yhteyden muodostus Oumaniin epäonnistui!',
                              'Tarkista tiedot ja yritä uudelleen!');
                          }
                        }
                        else {
                          await informMatterToUser(
                            context,
                            'Yhteyttä laitteiseen ei voida testata nyt!',
                            'Tarkista toiminta ollessasi asunnon verkossa!');
                          showSnackbarMessage('Ouman-laitteen tietoja päivitetty!');
                          Navigator.pop(context, true);
                        }
                      }
                    }),
                  ])
              )
          );
        }
}

bool _ipAddressFaulty(String ipAddress) {
  return false;
}

bool _usernameFaulty(String username) {
  return username.isEmpty;
}

bool _passwordFaulty(String password) {
  return password.isEmpty;
}