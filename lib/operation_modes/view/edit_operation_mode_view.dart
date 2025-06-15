
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:koti/functionalities/air_heat_pump_functionality/view/air_heat_pump_view.dart';
import 'package:thermostat/thermostat.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../../../view/my_dropdown_widget.dart';
import '../../estate/environment.dart';
import '../../logic/dropdown_content.dart';
import '../../view/my_button_widget.dart';
import '../../view/ready_widget.dart';
import '../conditional_operation_modes.dart';
import '../operation_modes.dart';
import 'conditional_option_list_view.dart';
import 'operation_modes_selection_view.dart';

class _opModeStructure {
  String name;
  OperationMode? operationMode;
  bool autoCreated = true;

  _opModeStructure(this.name);
}

class _PossibleOpModes {
  List <_opModeStructure> list = [];
  final OperationModes _operationModes;

  _PossibleOpModes(List<String> possibleTypes, this._operationModes) {
    for (var e in possibleTypes) {
      list.add(_opModeStructure(e));
    }
  }

  void addOpMode(String name, OperationMode opMode ) {
    int index = list.indexWhere((e)=>e.name == name);
    if (index >= 0) {
      list[index].autoCreated = false;
      list[index].operationMode = opMode;
    }
    else {
      log.error('EditOperationModeView: addOpMode("$name") failed');
    }
  }

  int indexOf(String name) {
    int index = list.indexWhere((e)=>e.name == name);

    return max(0, index);
  }

  OperationMode operationMode(String estateName, int index) {
    if (list[index].operationMode == null) {
      list[index].autoCreated = true;
      list[index].operationMode =
          operationModeTypeRegistry.createObject(list[index].name);
      list[index].operationMode!.init(/*estateName, */_operationModes);
    }
    return list[index].operationMode!;
  }

  void dispose({required String excluding}) {
    for (var o in list) {
      if ((o.autoCreated) && (o.name != excluding) &&(o.operationMode != null)) {
        o.operationMode!.clear();
      }
    }
  }
}

class EditOperationModeView extends StatefulWidget {
  final Environment environment;
  final String initOperationModeName;
  final OperationModes operationModes;
  final Function parameterFunction;
  final Function callback;
  const EditOperationModeView({Key? key,
    required this.environment,
    required this.initOperationModeName,
    required this.operationModes,
    required this.parameterFunction,
    required this.callback}) : super(key: key);

  @override
  _EditOperationModeViewState createState() => _EditOperationModeViewState();
}


class _EditOperationModeViewState extends State<EditOperationModeView> {
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  final myDeviceNameController = TextEditingController();

//  late OperationMode editedOperationMode;
  String operationModeName = '';
  List<String> usableNames = [];
  int currentModeIndex = -1;
  late DropdownContent operationNameSelection;
  late DropdownContent alternativeTypes;
  int opIndex = 0;
  late _PossibleOpModes opModePool;

//  ConditionalOperationModes conditionalMode = ConditionalOperationModes();

  @override
  void initState() {
    super.initState();

    var possibleTypeNames = widget.operationModes.types.alternatives();
    operationModeName = widget.initOperationModeName;
    opModePool = _PossibleOpModes(possibleTypeNames, widget.operationModes);

    if (insertingNewOperationMode()) {
      opIndex = 0;
    }
    else {
      OperationMode opMode = widget.operationModes.getMode(operationModeName);
      opModePool.addOpMode(opMode.typeName(), widget.operationModes.getMode(operationModeName));
      opIndex = opModePool.indexOf(opMode.typeName());
    }

    usableNames = _findUsableNames(
        operationModeName,
        widget.environment.operationModes.operationModeNames(),
        widget.operationModes.operationModeNames());

    operationNameSelection = DropdownContent(usableNames, '', usableNames.indexOf(operationModeName));
    alternativeTypes = DropdownContent(widget.operationModes.types.alternatives(), '', opIndex);
    refresh();
  }

  bool insertingNewOperationMode() {
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
                    tooltip: 'Keskeytä toimintatilan muokkaus',
                    onPressed: () async {
                      // check if the user wants to cancel all the changes
                      bool doExit = await askUserGuidance(context,
                          'Poistuttaessa muutetut tiedot katoavat.',
                          'Haluatko poistua näytöltä?'
                      );
                      if (doExit) {
                        opModePool.dispose(excluding: '');
                        Navigator.of(context).pop();
                      }
                    }),
                title: appIconAndTitle(widget.environment.name, insertingNewOperationMode() ? 'luo toimintotila' : 'muokkaa toimintotilaa'),
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
                                }
                      ),
                  ),
                  (widget.operationModes.types.alternatives().isEmpty)
                  ? widget.parameterFunction(
                      alternativeTypes.currentString(),
                      opModePool.operationMode(widget.environment.name, opIndex),
                      widget.environment,
                      widget.operationModes,
                      (newEditedOperationMode){
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
                                          keyString: 'alternativeTypes',
                                            dropdownContent: alternativeTypes,
                                            setValue: (newValue) {
                                              opIndex = newValue;
                                              alternativeTypes.setIndex(newValue);
                                              setState(() {});
                                            }
                                        )
                                    ),
                                  ),
                              ),
                              widget.parameterFunction(
                                opModePool.operationMode(widget.environment.name, opIndex),
                                widget.environment,
                                widget.operationModes
                              )
                            ]),
                    ),
                    readyWidget(() async {
                      if (insertingNewOperationMode()) {
                        if (widget.operationModes.newNameOK(operationModeName)) {
                          OperationMode newOpMode = opModePool.operationMode(widget.environment.name, opIndex);
                          newOpMode.name = operationModeName;
                          widget.operationModes.add(newOpMode);
                          log.info('${widget.environment.name}: toimintotila "$operationModeName" lisätty');
                          showSnackbarMessage('toimintotila lisätty!');
                          opModePool.dispose(excluding:newOpMode.typeName());
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
                        OperationMode editedOpMode = opModePool.operationMode(widget.environment.name, opIndex);
                        editedOpMode.name = operationModeName;
                        log.info(
                            '${widget.environment.name}: toimintotila "$operationModeName" päivitetty');
                        showSnackbarMessage('toimintotila päivitetty!');
                        opModePool.dispose(excluding: editedOpMode.typeName());
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
                    })
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
          key: const Key('operationModeName'),
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
    Environment environment,
    OperationModes operationModes,
    Function parameterReadingFunction,
    Function callback
  ) {
  String selectedOpMode = '';
  return Container(
    margin: myContainerMargin,
    padding: myContainerPadding,
    // height: 150,
    child: InputDecorator(
      decoration: const InputDecoration(labelText: 'Toimintotilat'),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            operationModes.nbrOfModes() == 0
                ? const Text('Toimintotiloja ei määritelty')
                : OperationModesEditingView(
                    environment: environment,
                    operationModes: operationModes,
                    parameterReadingFunction: parameterReadingFunction,
                    selectionNameFunction: ()=>selectedOpMode,
                    returnSelectedModeName: (name){selectedOpMode = name; callback();}),
                  myButtonWidget(
                    'Luo uusi',
                    'Luo uusi toimintotila',
                    () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context2) {
                            return EditOperationModeView(
                              environment: environment,
                              initOperationModeName: '',
                              operationModes: operationModes,
                              parameterFunction: parameterReadingFunction,
                              callback: callback
                            );
                          },
                        )
                      );
                      callback();
                    }
                  ),
          ]),
    ),
  );
}

List<String> possibleParameterTypes = [constWarming, relativeWarming, dynamicOperationModeText];

Widget airPumpParameterSetting(
    OperationMode operationMode,
    Estate estate,
    OperationModes operationModes
    )
{
  Widget myWidget;
  if (operationMode is ConstantOperationMode) {
    ConstantOperationMode cOM = operationMode;
    myWidget=temperatureSelectionForm(temperatureParameterId, cOM.parameters);
  }
  else if (operationMode is ConditionalOperationModes) {
    myWidget = ConditionalOperationView(
        conditions: operationMode
    );
  }
  else if (operationMode is BoolServiceOperationMode) {
    BoolServiceOperationMode bOS = operationMode;
    myWidget = Text('ei oo toteutettu, käytä jo määriteltyjä tiloja');
  }
  else {
    myWidget=const Text('ei oo toteutettu, mutta ideana on antaa +/- arvoja edelliseen verrattuna');
  }
  return myWidget;
}

Widget temperatureSelectionForm(String parameterName, Map <String, dynamic> parameters) {
  double currentValue = parameters[parameterName] ?? 24.0;

  return Thermostat(
      formatCurVal: (val) { return 'Lämpötila';},
      curVal: currentValue,
      setPoint: currentValue,
      setPointMode: SetPointMode.displayAndEdit,
      formatSetPoint: (val) { return '${val.toStringAsFixed(1)} $celsius';},
      themeType: ThermostatThemeType.light,
      maxVal: 40.0,
      minVal: 15.0,
      size: 300.0,
      turnOn: true,
      onChanged: (val) {currentValue = val; parameters[parameterName] = val; }
  );

}


