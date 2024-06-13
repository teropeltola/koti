
import 'package:flutter/material.dart';
import 'package:koti/functionalities/air_heat_pump_functionality/view/air_heat_pump_view.dart';
import 'package:koti/main.dart';
import 'package:provider/provider.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../../../view/my_dropdown_widget.dart';
import '../../logic/dropdown_content.dart';
import '../conditional_operation_modes.dart';
import '../operation_modes.dart';
import 'operation_modes_selection_view.dart';

class EditOperationModeView extends StatefulWidget {
  final Estate estate;
  final String initOperationModeName;
  final OperationModes operationModes;
  final List<String> possibleTypes;
  final Function parameterFunction;
  final Function callback;
  const EditOperationModeView({Key? key,
    required this.estate,
    required this.initOperationModeName,
    required this.operationModes,
    required this.possibleTypes,
    required this.parameterFunction,
    required this.callback}) : super(key: key);

  @override
  _EditOperationModeViewState createState() => _EditOperationModeViewState();
}


class _EditOperationModeViewState extends State<EditOperationModeView> {
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  final myDeviceNameController = TextEditingController();

  late OperationMode editedOperationMode;
  String operationModeName = '';
  List<String> usableNames = [];
  int currentModeIndex = -1;
  late DropdownContent operationNameSelection;
  late DropdownContent alternativeTypes;

//  ConditionalOperationModes conditionalMode = ConditionalOperationModes();

  @override
  void initState() {
    super.initState();
    operationModeName = widget.initOperationModeName;
    if (insertNewOperationMode()) {
      editedOperationMode = OperationMode();
    }
    else {
      editedOperationMode = widget.operationModes.getMode(operationModeName);
    }

    usableNames = _findUsableNames(
        operationModeName,
        widget.estate.operationModes.operationModeNames(),
        widget.operationModes.operationModeNames());

    operationNameSelection = DropdownContent(usableNames, '', usableNames.indexOf(operationModeName));
    alternativeTypes = DropdownContent(widget.possibleTypes, '', 0);
    refresh();
  }

  bool insertNewOperationMode() {
    return widget.initOperationModeName == '';
  }
    List<String> _findUsableNames(String myName, List<String> allNames, List<String> notAllowedNames) {
      var notAllowedSet = Set.from(notAllowedNames).difference({myName});
      var usableSet = (Set.from(allNames)).difference(notAllowedSet);
      return List.from(usableSet);
    }

  void refresh() {
    myDeviceNameController.text = operationModeName;
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
          return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Keskeytä toimintatilan  muokkaus',
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
                title: appTitle(insertNewOperationMode() ? 'luo toimintotila' : 'muokkaa toimintotilaa'),
              ), // new line
              body: SingleChildScrollView(
                  child: Column(children: <Widget>[
                    Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      child: _OperationModeNameForm(
                                modeName: operationModeName,
                                alternatives: usableNames,
                                setValue: (val) {
                                  operationModeName = val;
                                  setState(() {});
                                },
                                setValueOnChanged: (val) {
                                  operationModeName = val;
                                }),
                    ),
                  (widget.possibleTypes.isEmpty)
                  ? widget.parameterFunction(
                      alternativeTypes.currentString(),
                      editedOperationMode,
                      widget.estate,
                      widget.operationModes,
                      (newEditedOperationMode){
                            editedOperationMode = newEditedOperationMode;
                            setState(() {});
                      }
                  )
                  : Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      // height: 150,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                  margin: myContainerMargin,
                                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                                  child: InputDecorator(
                                    decoration:
                                    const InputDecoration(labelText: 'toimintotilan tyyppi'),
                                    child: SizedBox(
                                        height: 30,
                                        width: 120,
                                        child: MyDropdownWidget(
                                            dropdownContent: alternativeTypes,
                                            setValue: (newValue) {
                                              alternativeTypes
                                                  .setIndex(newValue);
                                              setState(() {});
                                            }
                                        )
                                    ),
                                  ),
                              ),
                              widget.parameterFunction(
                                alternativeTypes.currentString(),
                                editedOperationMode,
                                widget.estate,
                                widget.operationModes,
                                (updatedOperationMode){ editedOperationMode = updatedOperationMode; setState(() {});}
                              )
                            ]),
                    ),
                    Container(
                        margin: myContainerMargin,
                        padding: myContainerPadding,
                        child: Tooltip(
                            message:
                            'Paina tästä tallentaaksesi muutokset ja poistuaksesi näytöltä',
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
                                if (insertNewOperationMode()) {
                                  if (widget.operationModes.newNameOK(operationModeName)) {
                                    widget.operationModes.add(editedOperationMode);
                                    editedOperationMode.name = operationModeName;
                                    // await myEstates.store();
                                    log.info('${widget.estate.name}: toimintotila "$operationModeName" lisätty');
                                    showSnackbarMessage('toimintotila lisätty!');
                                    Navigator.pop(context, true);
                                  }
                                  else if ( operationModeName == '') {
                                    await informMatterToUser(context, 'Toimintotilan nimi ei voi olla tyhjä',
                                    'Lisää toimintotilan nimi!');
                                  }
                                  else {
                                    await informMatterToUser(context, 'Nimeä ei voi käyttää',
                                    'Vaihda toimintotilan nimeä!');
                                  }
                                }
                                else if ((operationModeName == widget.initOperationModeName) || widget.operationModes.newNameOK(operationModeName)) {
                                  editedOperationMode.name = operationModeName;
                                  log.info(
                                      '${widget.estate.name}: toimintotila "$operationModeName" päivitetty');
                                  showSnackbarMessage('toimintotila päivitetty!');
                                  Navigator.pop(context, true);
                                }
                                else if ( operationModeName == '') {
                                  await informMatterToUser(context, 'Toimintotilan nimi ei voi olla tyhjä',
                                    'Lisää toimintotilan nimi!');
                                }
                                else {
                                  await informMatterToUser(context, 'Nimeä ei voi käyttää',
                                      'Vaihda toimintotilan nimeä!');
                                }
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
}

class _OperationModeNameForm extends StatelessWidget {
  final String modeName;
  final List<String> alternatives;
  final Function setValue;
  final Function setValueOnChanged;

  const _OperationModeNameForm({Key? key,
    required this.modeName,
    required this.alternatives,
    required this.setValue,
    required this.setValueOnChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        List<String> myTextAlternatives = alternatives;

        return myTextAlternatives.where((String option) {
          return option.contains(textEditingValue.text); //.toLowerCase()
        });
      },
      fieldViewBuilder: (
          BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted
          )
      {
        fieldTextEditingController.text = modeName;
        return TextField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          decoration: const InputDecoration(labelText: 'Toimintotilan nimi') ,
          style: const TextStyle(fontWeight: FontWeight.bold),
          onChanged: (value) {
            setValueOnChanged( fieldTextEditingController.text);
          },
          onSubmitted: (String value) {
            setValue( value);
            fieldFocusNode.unfocus();
          },
        );
      },
      onSelected: (String selection) {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        setValue(selection);
      },
    );
  }
}

Widget operationModeHandling(
    BuildContext context,
    Estate estate,
    OperationModes operationModes,
    List <String> possibleParameterTypes,
    Function parameterReadingFunction,
    Function callback
  ) {
  String selectedOpMode = '';
  return Container(
    margin: myContainerMargin,
    padding: myContainerPadding,
    // height: 150,
    child: InputDecorator(
      decoration: const InputDecoration(labelText: 'Toimintatilat'),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            operationModes.nbrOfModes() == 0
                ? Text('Toimintotiloja ei määritelty')
                : OperationModesEditingView(
                    estate: estate,
                    possibleParameterTypes: possibleParameterTypes,
                    operationModes: operationModes,
                    parameterReadingFunction: parameterReadingFunction,
                    selectionNameFunction: ()=>selectedOpMode,
                    returnSelectedModeName: (name){selectedOpMode = name;}),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        backgroundColor: mySecondaryColor,
                        side: const BorderSide(
                            width: 2, color: mySecondaryColor),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                        elevation: 10),
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EditOperationModeView(
                                  estate: estate,
                                  initOperationModeName: '',
                                  operationModes: operationModes,
                                  possibleTypes: possibleParameterTypes,
                                  parameterFunction: parameterReadingFunction,
                                  callback: (){});
                            },
                          )
                      );
                      callback();
                    },
                    child: const Text(
                      'Luo uusi',
                      maxLines: 1,
                      style: TextStyle(color: mySecondaryFontColor),
                      textScaleFactor: 2.0,
                    ),
                  ),
          ]),
    ),
  );
}
