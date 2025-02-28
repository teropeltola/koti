import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:koti/service_catalog.dart';

import '../../../estate/estate.dart';
import '../../../logic/events.dart';
import '../../../logic/observation.dart';
import '../../../logic/services.dart';
import '../../../look_and_feel.dart';
import '../../../view/ready_widget.dart';
import '../../shelly_blu_gw/shelly_blu_gw.dart';
import '../shelly_blu_trv.dart';

class EditShellyBluTrvView extends StatefulWidget {
  final Estate estate;
  final ShellyBluTrv shellyBluTrv;
  final Function callback;
  const EditShellyBluTrvView({Key? key, required this.estate, required this.shellyBluTrv, required this.callback}) : super(key: key);

  @override
  _EditShellyBluTrvViewState createState() => _EditShellyBluTrvViewState();
}

class _EditShellyBluTrvViewState extends State<EditShellyBluTrvView> {
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  final myDeviceNameController = TextEditingController();
  late ShellyBluTrv shellyBluTrv;
  bool creatingNewDevice = false;

  late BluConfigAndStatus bluTrvInfo;
  late Future <bool> dataFetched;

  @override
  void initState() {
    super.initState();
    creatingNewDevice = widget.shellyBluTrv.name == '';
    shellyBluTrv = widget.shellyBluTrv.clone2() as ShellyBluTrv;

    dataFetched = _fetchTrvData();
    myDeviceNameController.text = shellyBluTrv.name;
    refresh();
  }

  Future<bool> _fetchTrvData() async {
    await shellyBluTrv.init();
    await shellyBluTrv.updateData();
    bluTrvInfo = await shellyBluTrv.myGw.bluInfo(shellyBluTrv.idNumber);
    return true;
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
    return FutureBuilder<bool>(
      future: dataFetched, // a previously-obtained Future<bool> or null
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        List<Widget> children = [];
        if (snapshot.hasData) {
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
                title: appTitleOld('muokkaa laitteen tietoja'),
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
                              Row(children: <Widget>[
                                const Flexible(flex:1, child: Text('Tunnus: ')),
                                Flexible(flex:5, child: AutoSizeText(shellyBluTrv.id, style:const TextStyle(fontSize:20,color:Colors.blue))),
                              ]),
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
                                    shellyBluTrv.name = newText;
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
                            decoration: const InputDecoration(
                                labelText: 'Laitteen yksityiskohtaiset tiedot'),
                            child: Column(
                              children: [
                                Text('GW id: ${bluTrvInfo.status.id}'),
                                Text('patterin lataustaso ${bluTrvInfo.status.battery} %'),
                                Text('viimeisin päivitys: ${timestampToDateTimeString(bluTrvInfo.status.lastUpdatedTs)}'),
                                Text('nimi: ${bluTrvInfo.config.name}'),
                                Text('osoite: ${bluTrvInfo.config.addr}')
                              ]
                            )
                        )
                    ),
                    readyWidget(() async {

                      // remove earlier version
                      widget.estate.removeDevice(widget.shellyBluTrv.id);
                      widget.shellyBluTrv.remove();
                      // create new
                      await shellyBluTrv.init();
                      widget.estate.addDevice(shellyBluTrv);
                      events.write(widget.estate.id, shellyBluTrv.id, ObservationLevel.ok,
                          'laitetta (tunnus: "${shellyBluTrv.id}") muokattu');
                      showSnackbarMessage('laitteen tietoja päivitetty!');
                      // show message in the TRV
                      DeviceServiceClass<ThermostatControlService> myService =
                        shellyBluTrv.services.getService(thermostatService)
                          as DeviceServiceClass<ThermostatControlService>;
                      myService.services.showMessage(shellyBluTrv.name);
                      
                      Navigator.pop(context, true);

                    })
                  ])
              )
          );
        } else if (snapshot.hasError) {
          children = <Widget>[
            const Icon(
              Icons.error_outline,
              color: myPrimaryFontColor,
              size: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Hups, emme saa nyt yhteyttä verkkoon!'),
            ),
          ];
        } else {
          children = const <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Pieni hetki, tietoa haetaan laitteilta...\n'),
            ),
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),

          ];
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        );
      },
    );



  }
}
