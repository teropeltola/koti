import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:koti/devices/wlan/active_wifi_name.dart';
import 'package:koti/estate/view/environment_list_widget.dart';
import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/operation_modes/view/edit_operation_mode_view.dart';

import '../../devices/porssisahko/porssisahko.dart';
import '../../functionalities/electricity_price/electricity_price.dart';
import '../../functionalities/electricity_price/view/edit_electricity_view.dart';
import '../../functionalities/functionality/view/edit_environment_functionalities_view.dart';
import '../../view/my_button_widget.dart';
import '../../view/my_snapshot_waiting_widget.dart';
import '../../view/ready_widget.dart';
import '../estate.dart';
import '../../look_and_feel.dart';
import 'edit_environment_view.dart';
import 'edit_estate_devices_view.dart';

class EditEstateView extends StatefulWidget {
   final String estateName;
   const EditEstateView({Key? key, required this.estateName}) : super(key: key);

  @override
  _EditEstateViewState createState() => _EditEstateViewState();
}

class _EditEstateViewState extends State<EditEstateView> {
  late Estate editedEstate;

  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  final myEstateNameController = TextEditingController();
  List<Functionality> existingServices = [];
  Future<bool> estateIsCloned = Future.value(false);

  @override
  void initState() {
    super.initState();

    if (_createNewEstate()) {
      editedEstate = myEstates.candidateEstate();
      myEstates.activateCandidate();
      editedEstate.init('',activeWifi.name);
      addElectricityPriceWithoutEditing(editedEstate);
      myEstateNameController.text = editedEstate.name;
    }
    else {
      editedEstate = myEstates.cloneCandidate(widget.estateName);
      myEstateNameController.text = editedEstate.name;
      estateIsCloned = editedEstate.initDevicesAndFunctionalities();
    }
  }

  void refresh() async {
    setState(() { });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeWifi.dispose();

    super.dispose();
  }

  bool _createNewEstate() {
    return widget.estateName == '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: estateIsCloned, // a previously-obtained Future<bool> or null
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot)
    {
      if (! snapshot.hasData) {
        return MySnapshopWaitingWidget(
            context,
            appIconAndTitle(widget.estateName, 'muuta tietoja'),
            snapshot.hasError);
      }
      return Scaffold(
        appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Palaa takaisin tallentamatta muutoksia',
                  onPressed: () async {
                    // check if the user wants to cancel all the changes
                    bool doExit = await askUserGuidance(context,
                        'Poistuttaessa muutokset eivät säily.',
                        'Haluatko poistua muutossivulta ?'
                    );
                    if (doExit) {
                      editedEstate.removeData();
                      myEstates.deactivateCandidate();
                      Navigator.of(context).pop();
                    }
                  }),
              title: _createNewEstate()
                  ? appIconAndTitle('Syötä', 'asunnon tiedot')
                  : appIconAndTitle(widget.estateName, 'muuta tietoja'),
            ), // new line
            body:
            SingleChildScrollView(
                child: Column(children: <Widget>[
                  Container(
                    margin: myContainerMargin,
                    padding: myContainerPadding,
                    child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Asunnon tiedot'), //k
                        child: Column(children: <Widget>[
                          TextField(
                              key: const Key('estateName'),
                              decoration: const InputDecoration(
                                labelText: 'asunnon nimi',
                                hintText: 'kirjoita tähän asunnolle nimi, esim. koti',
                              ),
                              focusNode: _focusNode,
                              autofocus: false,
                              textInputAction: TextInputAction.done,
                              controller: myEstateNameController,
                              maxLines: 1,
                              onChanged: (String newText) {
                                editedEstate.name = newText;
                              },
                              onEditingComplete: () {
                                _focusNode.unfocus();
                              }),
                          const Text(''),
                          TextFormField(
                              key: const Key('wifiName'),
                              decoration: const InputDecoration(
                                labelText: 'wifi-verkon nimi (oletuksena nykyinen)',
                                hintText: 'oletusarvona on nykyinen wifi',
                              ),
                              focusNode: _focusNodeWifi,
                              initialValue: editedEstate.myWifi,
                              autofocus: false,
                              textInputAction: TextInputAction.done,
                              maxLines: 1,
                              onChanged: (String newWifi) {
                                editedEstate.myWifiDevice().changeWifiName(
                                    newWifi);
                                setState(() {});
                              },
                              onEditingComplete: () {
                                _focusNodeWifi.unfocus();
                              }),
                          const Text(''),
                          EditElectricityShortView(
                              estate: editedEstate
                          )
                        ])
                    ),
                  ),
                  myButtonWidget(
                    'Asunnon laitteet',
                    'Muokkaa asunnon laitteita', () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return EditEstateDevicesView(
                                candidateEstate: editedEstate
                            );
                          },
                        )
                    );
                    refresh();
                  },
                  ),
                  EnvironmentListWidget(
                      environment: editedEstate,
                      callback: refresh),
                  EditEnvironmentFunctionalitiesView(
                      environment: editedEstate,
                      callback: refresh
                  ),
                  operationModeHandling(
                      context,
                      editedEstate,
                      editedEstate.operationModes,
                      environmentOperationModes,
                      refresh
                  ),
                  readyWidget(() async {
                    // todo tee kattava tarkistus parametreistä
                    if (editedEstate.name == '') {
                      informMatterToUser(
                          context, 'Asunnon nimi ei voi olla tyhjä',
                          'Korjaa nimi!');
                    }
                    else {
                      String problems = editedEstate.operationModes
                          .searchConditionLoops();
                      if (problems.isNotEmpty) {
                        informMatterToUser(context,
                            'Toimintotila "$problems" viittaa kehässä itseensä',
                            'Poista kehäviittaukset!');
                      }
                      else {
                        myEstates.replaceEstateWithCandidate(
                            widget.estateName);
                        myEstates.setCurrent(editedEstate.id);
                        await storeChanges();
                        Navigator.pop(context, true);
                      }
                    }
                  })
                ])
            )
        );
      }
    );
  }
}


Future <void> addElectricityPriceWithoutEditing(Estate estate) async {
  Porssisahko spot = Porssisahko();
  spot.name = 'spot';
  estate.addDevice(spot);

  ElectricityPrice electricityPrice = ElectricityPrice();
  electricityPrice.pair(spot);
  estate.addFunctionality(electricityPrice);

  // these are not waited in the initialization:
  await spot.init();
  await electricityPrice.init();

}

/*
Widget _estateOperationModes(
    OperationMode operationMode,
    Estate estate,
    OperationModes operationModes
) {

  Widget myWidget;

  if (operationMode is HierarchicalOperationMode) {
    HierarchicalOperationMode hierarchicalOperationMode = operationMode;
    List<Widget> featureTiles = [];
    for (int index=0; index<estate.features.length; index++) {
      if (estate.features[index].operationModes.nbrOfModes() > 0) {
        featureTiles.add(
          ListTile(
            title: Text(estate.features[index].connectedDevices[0].name),
            subtitle: OperationModesSelectionView2(
              operationModes: estate.features[index].operationModes,
              initSelectionName: hierarchicalOperationMode.operationCode(estate.features[index].id),
              returnSelectedModeName: (opName){
                  hierarchicalOperationMode.add(estate.features[index].id, opName );
                  // updateOperationMode(hierarchicalOperationMode);
                },)
          ));
        }
      }
      myWidget = Container(
          margin: myContainerMargin,
          padding: myContainerPadding,
          child: InputDecorator(
              decoration: const InputDecoration(
                  labelText: 'Asunnon toimintotila määritys'),
              child: (featureTiles.isEmpty)
                  ? const Text('Asunnon toiminnoille ei ole määritelty toimintotiloja')
                  : Column(children: [
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: featureTiles.length,
                    itemBuilder: (context, index) => Card(
                        elevation: 6,
                        margin: const EdgeInsets.all(10),
                        child: featureTiles[index]
                    )
                )
              ])
          )
      );
    }
  else if (operationMode is ConditionalOperationModes) {
    myWidget = ConditionalOperationView(
      conditions: operationMode
    );
  }
  else {
    myWidget = emptyWidget();
  }
  return myWidget;
}

class _SelectionOption {

}

Widget functionalitySelection(String title, List<_SelectionOption> selectionOptions) {
  return Text(title);
}

 */



