import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:koti/estate/view/environment_list_widget.dart';
import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/operation_modes/view/edit_operation_mode_view.dart';
import 'package:koti/operation_modes/view/operation_modes_selection_view.dart';
import '../../devices/porssisahko/porssisahko.dart';
import '../../functionalities/electricity_price/electricity_price.dart';
import '../../functionalities/functionality/view/edit_environment_functionalities_view.dart';
import '../../operation_modes/conditional_operation_modes.dart';
import '../../operation_modes/hierarcical_operation_mode.dart';
import '../../operation_modes/operation_modes.dart';
import '../../operation_modes/view/conditional_option_list_view.dart';
import '../../view/ready_widget.dart';
import '../environment.dart';
import '../estate.dart';
import '../../look_and_feel.dart';

class EditEnvironmentView extends StatefulWidget {
   final Environment environment;
   const EditEnvironmentView({Key? key, required this.environment}) : super(key: key);

  @override
  _EditEnvironmentViewState createState() => _EditEnvironmentViewState();
}

class _EditEnvironmentViewState extends State<EditEnvironmentView> {
  late Estate editedEstate;

  late Environment environment;

  final FocusNode _focusNode = FocusNode();
  final myNameController = TextEditingController();
  List<Functionality> existingServices = [];

  bool isNewEnvironment = false;

  @override
  void initState() {
    super.initState();
    environment = widget.environment.clone();
    editedEstate = widget.environment.myEstate();
    isNewEnvironment = (widget.environment.name == '');
    myNameController.text = widget.environment.name;
    refresh();
  }

  void refresh() async {
    setState(() { });
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Palaa takaisin',
                onPressed: () async {
                  // check if the user wants to cancel all the changes
                  bool doExit = await askUserGuidance(context,
                      'Poistuttaessa keskeneräiset muutokset eivät säily.',
                      'Haluatko poistua muutossivulta ?'
                      );
                  if (doExit) {
                    environment.removeData();
                    environment.dispose();
                    Navigator.of(context).pop(false);
                  }
                }),
            title:isNewEnvironment
              ? appIconAndTitle( "Uusi alue", 'syötä tiedot')
              : appIconAndTitle(environment.name, 'muuta tietoja')
          ), // new line
          body:
            SingleChildScrollView(
              child: Column(children: <Widget>[
                Container(
                margin: myContainerMargin,
                padding: myContainerPadding,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Huoneen tai osa-alueen tiedot'), //k
                  child: Column(children: <Widget>[
                    TextField(
                        key: const Key('environmentName'),
                        decoration: const InputDecoration(
                          labelText: 'Nimi',
                          hintText: 'kirjoita tähän osa-alueen nimi, esim. makuuhuone',
                        ),
                        focusNode: _focusNode,
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        controller: myNameController,
                        maxLines: 1,
                        onChanged: (String newText) {
                          environment.name = newText;
                        },
                        onEditingComplete: () {
                          _focusNode.unfocus();
                        }),
                  ])
                ),
              ),
              EnvironmentListWidget(
                  environment: environment,
                  callback: refresh),
              EditEnvironmentFunctionalitiesView(
                    environment: environment,
                    callback: refresh
                ),
              operationModeHandling(
                  context,
                  environment,
                  environment.operationModes,
                  environmentOperationModes,
                  refresh
              ),
              readyWidget(() async {
                if (environment.name == '') {
                  informMatterToUser(context,'Nimi ei voi olla tyhjä', 'Lisää nimi!');
                }
                else {
                  String problems = environment.operationModes.searchConditionLoops();
                  if (problems.isNotEmpty) {
                    informMatterToUser(context,'Toimintotila "$problems" viittaa kehässä itseensä', 'Poista kehäviittaukset!');
                  }
                  else {
                    // remove earlier version of environment
                    environment.parentEnvironment!.removeSubEnvironment(widget.environment);
                    widget.environment.removeData();
                    widget.environment.dispose();
                    // add new environment to the parent
                    environment.parentEnvironment!.addSubEnvironment(environment);

                    Navigator.pop(context, true);
                  }
                }
              })
              ])
            )
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

Widget environmentOperationModes(
    OperationMode operationMode,
    Environment environment,
    OperationModes operationModes
) {
  Widget myWidget;
  if (operationMode is HierarchicalOperationMode) {
    HierarchicalOperationMode hierarchicalOperationMode = operationMode;
    List<Widget> subTiles = [];
    _addSubTiles(environment, subTiles, hierarchicalOperationMode);
    myWidget = Container(
          margin: myContainerMargin,
          padding: myContainerPadding,
          child: InputDecorator(
              decoration: InputDecoration(
                  labelText: '${environment.name}: toimintotilan määritys'),
              child: (subTiles.isEmpty)
                  ? const Text('Asunnon toiminnoille ei ole määritelty toimintotiloja')
                  : Column(children: [
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: subTiles.length,
                    itemBuilder: (context, index) => Card(
                        elevation: 6,
                        margin: const EdgeInsets.all(10),
                        child: subTiles[index]
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

// add recursively all the subtree tiles to the list
void _addSubTiles(Environment environment, List<Widget> subTiles, HierarchicalOperationMode hierarchicalOperationMode) {
  for (var functionality in environment.features) {
    if (functionality.operationModes.nbrOfModes() > 0) {
      subTiles.add(
          ListTile(
              title: Text(functionality.connectedDevices[0].name),
              subtitle: OperationModesSelectionView2(
                operationModes: functionality.operationModes,
                initSelectionName: hierarchicalOperationMode.operationCode(functionality.id),
                returnSelectedModeName: (opName){
                  hierarchicalOperationMode.add(functionality.id, opName );
                  // updateOperationMode(hierarchicalOperationMode);
                },)
          ));
    }
  }
  for (var subEnvironment in environment.environments) {
    for (int index=0; index<subEnvironment.operationModes.nbrOfModes(); index++) {
      OperationMode operationMode = subEnvironment.operationModes.getModeAt(index);
      subTiles.add( ListTile(
        title: Text(subEnvironment.name),
          subtitle: OperationModesSelectionView2(
            operationModes: subEnvironment.operationModes,
            initSelectionName: hierarchicalOperationMode.operationCode(subEnvironment.id),
            returnSelectedModeName: (opName){
              hierarchicalOperationMode.add(subEnvironment.id, opName );
              // updateOperationMode(hierarchicalOperationMode);
            },)
      ));
    }
    _addSubTiles(subEnvironment, subTiles, hierarchicalOperationMode);
  }
}

