import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../../../view/ready_widget.dart';
import '../mitsu_air-source_heat_pump.dart';

class EditMitsuView extends StatefulWidget {
  final Estate estate;
  final MitsuHeatPumpDevice initMitsu;
  final Function callback;

  const EditMitsuView({Key? key,
    required this.estate,
    required this.initMitsu,
    required this.callback}) : super(key: key);

  @override
  _EditMitsuViewState createState() => _EditMitsuViewState();
}

class _EditMitsuViewState extends State<EditMitsuView> {
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _usercodeFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final myDeviceNameController = TextEditingController();
  final myUsernameController = TextEditingController();
  final myPasswordController = TextEditingController();
  bool passwordVisible = false;
  late MitsuHeatPumpDevice mitsuDevice;
  bool creatingNewDevice = false;

  @override
  void initState() {
    super.initState();
    creatingNewDevice = widget.initMitsu.name == '';
    mitsuDevice = widget.initMitsu.clone2() as MitsuHeatPumpDevice;
    myDeviceNameController.text = mitsuDevice.name;

    _callAsyncInit();

    refresh();
  }

  void _callAsyncInit() async {
    // fetch username and password with a little delay
    myUsernameController.text = await mitsuDevice.webLoginCredentials.username();
    myPasswordController.text = await mitsuDevice.webLoginCredentials.password();
    setState(() {});
  }

  void refresh() {
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
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
                    tooltip: 'Keskeytä laitteen tietojen ${creatingNewDevice ? 'luonti' : 'muokkaus'}',
                    onPressed: () async {
                      // check if the user wants to cancel all the changes
                      bool doExit = await askUserGuidance(context,
                          'Poistuttaessa häviää keskeneräiset tiedot.',
                          'Haluatko silti poistua näytöltä?'
                      );
                      if (doExit) {
                        mitsuDevice.remove();
                        Navigator.pop(context, false);
                      }
                    }),
                title: appIconAndTitle(widget.estate.name, creatingNewDevice ? 'anna Mitsun tiedot' : 'muokkaa Mitsun tietoja'),
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
                              const Text('Laitteen kutsumanimi: '),
                              const Spacer(),
                              TextField(
                                  key: const Key('deviceName'),
                                  decoration: const InputDecoration(
                                    labelText: 'nimi',
                                    hintText: 'kirjoita tähän laitteen nimi',
                                  ),
                                  focusNode: _nameFocusNode,
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  controller: myDeviceNameController,
                                  maxLines: 1,
                                  onChanged: (String newText) {
                                    mitsuDevice.name = newText;
                                  },
                                  onEditingComplete: () {
                                    _nameFocusNode.unfocus();
                                  }),
                              Spacer(),
                              Row(children: <Widget>[
                                Flexible(flex:1, child: Text('Tunnus: ')),
                                Flexible(flex:5, child: AutoSizeText(mitsuDevice.id, style:TextStyle(fontSize:20,color:Colors.blue))),
                              ]),

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
                                    flex: 4,
                                    child: Text('Käyttäjätunnus:'),
                                  ),
                                  Expanded(
                                    flex: 9,
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
                                      flex: 4,
                                      child: Text('Salasana:'),
                                    ),
                                    Expanded(
                                      flex: 8,
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
                      if (_nameFaulty(myDeviceNameController.text)) {
                        await informMatterToUser(context,'nimi ei voi olla tyhjä', 'Päivitä nimi-kenttää!');
                      }
                      else if (_usernameFaulty(myUsernameController.text)) {
                        await informMatterToUser(context,'käyttäjätunnus on virheellinen', 'Korjaa se!');
                      }
                      else if (_passwordFaulty(myPasswordController.text)) {
                        await informMatterToUser(context,'käyttäjätunnus on virheellinen', 'Korjaa se!');
                      }
                      else {
                        if (creatingNewDevice) {
                        }
                        else {
                          widget.estate.removeDevice(widget.initMitsu.id);
                        }
                        await mitsuDevice
                            .webLoginCredentials
                            .initUsernameAndPassword(
                            myUsernameController.text,
                            myPasswordController.text);
                        widget.estate.addDevice(mitsuDevice);
                        // await mitsuDevice.init();
                        bool connectionSucceeded = await mitsuDevice.fetchAndAnalyzeData();
                        if (connectionSucceeded) {
                          log.info('${widget.estate.name}: laite ${mitsuDevice.name}(${mitsuDevice.id}) luotu');
                          showSnackbarMessage('Mitsubishi-laitteen tietoja päivitetty!');
                          Navigator.pop(context, true);
                        }
                        else {
                          widget.estate.removeDevice(mitsuDevice.id);
                          await informMatterToUser(
                              context,
                              'Yhteyden muodostus Mitsubishiin epäonnistui annetuilla tiedoilla!',
                              'Tarkista tiedot ja yritä uudelleen!');
                        }
                      }
                    })
                  ])
              )
          );
        }
}

bool _nameFaulty(String name) {
  return name.isEmpty;
}

bool _usernameFaulty(String username) {
  return username.isEmpty;
}

bool _passwordFaulty(String password) {
  return password.isEmpty;
}