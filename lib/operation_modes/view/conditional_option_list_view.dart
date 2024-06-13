import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:reorderables/reorderables.dart';

import 'package:koti/view/my_dropdown_widget.dart';

import '../../logic/dropdown_content.dart';
import '../../look_and_feel.dart';
import '../conditional_operation_modes.dart';

class ConditionalOperationView extends StatefulWidget {
  final ConditionalOperationModes conditions;
  const ConditionalOperationView({super.key, required this.conditions});

  @override
  State<ConditionalOperationView> createState() => ConditionalOperationViewState();
}

class ConditionalOperationViewState extends State<ConditionalOperationView> {

  late DropdownContent possibleOperationModeNames;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);

    return Column(children: [
      Container(
        margin: myContainerMargin,
        padding: myContainerPadding,
        child: InputDecorator(
          decoration:
          const InputDecoration(labelText: 'sääntöjen mukaiset tilat'),
          child:operationModeAnalysis(widget.conditions)
        )
      ),
      Container(
        margin: myContainerMargin,
        padding: myContainerPadding,
        child: InputDecorator(
         decoration:
           const InputDecoration(labelText: 'säännöt'),
           child: Column(mainAxisSize: MainAxisSize.min,
               children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
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
                    OperationCondition oC = OperationCondition();
                    oC.conditionType = OperationConditionType.notDefined;
                    widget.conditions.add( ConditionalOperationMode(oC, ResultOperationMode('')));
                    setState(() {});
                  },
                  child: const Text(
                    'Lisää uusi sääntö',
                    maxLines: 1,
                    style: TextStyle(color: mySecondaryFontColor),
                    textScaleFactor: 2.0,
                  ),
                ),
          ]),
          //SizedBox(
          //  height: 450,

            ReorderableColumn( //ReorderableListView(
              //padding: const EdgeInsets.symmetric(horizontal: 2),

              children: <Widget>[
                for (int index = 0; index < widget.conditions.conditions.length; index += 1)
                  Card(
                    key: Key('$index'),            //TODO: change to index independed key
                    elevation: 6,
                    margin: const EdgeInsets.all(1),
                    child:
                      editConditionalOperationMode(
                        context,
                        index,
                        widget.conditions,
                        () { setState(() {});}),
                    ),
              ],

              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  var item = widget.conditions.removeAt(oldIndex);
                  widget.conditions.conditions.insert(newIndex, item);
                });
              },

            ),
            ],))
              ),
        ]);
  }
}



DropdownContent _comparisonOptions = DropdownContent(OperationComparisons.comparisonText,'',0);
DropdownContent _spotPrizeOptions = DropdownContent(SpotPriceComparisonType.typeText,'',0);


Widget _conditionParameters(BuildContext context, OperationCondition condition, Function callback) {
  switch (condition.conditionType) {
    case OperationConditionType.timeOfDay:
      {
        return _timeRange(context, condition, callback);
      }
    case OperationConditionType.spotPrice: {
      return Column(children: [
        Row(children:[
          Expanded(flex: 5, child: MyDropdownWidget(key:Key('comparisonOptions'),dropdownContent: _comparisonOptions ,
              setValue: (val) {
                condition.spot.comparison = OperationComparisons.values[val];
                callback();
              })),
          Expanded(flex: 4, child: MyDropdownWidget(key:Key('comparisonTypes'),dropdownContent: _spotPrizeOptions ,
              setValue: (val) {
                condition.spot.myType = SpotPriceComparisonType.values[val];
                callback();
              })),
        ]),
        _spotParameter(context, condition.spot, callback)
      ],);
    }
    default: return emptyWidget();
  }
}

Widget _spotParameter(BuildContext context, SpotCondition spot, Function callback) {
  switch (spot.myType) {
    case SpotPriceComparisonType.constant: {
      return TextFormField(
        keyboardType:TextInputType.numberWithOptions(decimal: true),
        initialValue: spot.parameterValue.toString(),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))],
        onChanged: (stringValue) {
          if (double.tryParse(stringValue) != null) {
            spot.parameterValue = double.parse(stringValue);
          }
          callback();
        }
      );
    }
    case SpotPriceComparisonType.median: return emptyWidget();
    case SpotPriceComparisonType.percentile: return _doubleSlider(context, spot, callback);
    default: return emptyWidget();
  }
}

Widget _doubleSlider(BuildContext context, SpotCondition spot, Function callback) {
  String sign = spot.myType == SpotPriceComparisonType.constant ? '€' : '%';
  return Slider(
    value: spot.parameterValue,
    min: 0,
    max: 100,
    divisions: 20,
    label: '${spot.parameterValue.round().toString()}$sign',
    onChanged: (double value) {
      spot.parameterValue = value;
      callback();
    }
  );
}

ExpansionTile editConditionalOperationMode(
    BuildContext context,
    int index,
    ConditionalOperationModes items,
    Function callback) {

  String nameOfMode = items.conditions[index].result.operationModeName;
  int indexOfMode = items.operationModes.findName(nameOfMode);
  if (indexOfMode < 0) {
    indexOfMode = 0;
    items.conditions[index].result.operationModeName = items.operationModes.modeName(0);
  }
  DropdownContent possibleOperationModes = DropdownContent(items.operationModes.operationModeNames(),'',indexOfMode);
  DropdownContent conditionOptions = DropdownContent(OperationConditionType.optionTextList,'',items.conditions[index].condition.conditionType.index);


  if (items.conditions[index].draft) {
    return ExpansionTile(
      title:
        Column(children: [
          Row(children: [
            Expanded(
              flex: 1,
              child: Text('Määrittele ehto:')),
            Expanded(flex: 1, child: MyDropdownWidget(dropdownContent: conditionOptions,
              setValue: (val) {
                items.conditions[index].condition.conditionType = OperationConditionType.values[val];
                callback();
              })
            )
          ],),
          _conditionParameters(context, items.conditions[index].condition, callback)
        ],
      ),
      subtitle:
        Column(children: [
          Row(children: [
            Expanded(flex: 1, child: Text('toimintotila:')),
            Expanded(
              flex: 1,
              child: MyDropdownWidget(dropdownContent: possibleOperationModes,
                setValue: (val) {
                  var x = val;
                  items.conditions[index].result.operationModeName = possibleOperationModes.currentString();
                  callback();
                }
              )
            )
          ],),
          TextButton(
            key: const Key('informMatterOK'),
            child: const Text('OK'),
            onPressed: () async {
              if (items.conditions[index].parametersOK()) {
                items.conditions[index].draft = false;
              }
              else {
                await informMatterToUser(context, 'Ehto ei voi olla tyhjä', 'Täytä ehto-kenttä!');
              }
              callback();
            },
          )
        ],),
        children: [

      ]
    );
  }
  else {
    return ExpansionTile(
      title: Text('${index + 1}: ${_conditionText(items.conditions[index].condition)}'),
      subtitle: Text('=> toimintotila: ${items.conditions[index].result.operationModeName}'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.edit,
                color: mySecondaryFontColor, size: 40),
              tooltip: 'muokkaa ehdollista toimintoa',
              onPressed: () async {
                items.conditions[index].draft = true;
                callback();
              }
            ),
            IconButton(
                icon: const Icon(Icons.delete,
                    color: mySecondaryFontColor, size: 40),
                tooltip: 'poista tämä ehdollinen toiminto',
                onPressed: () async {
                  bool doDelete = await askUserGuidance(context, 'Komennolla tuhotaan tämä ehdollinen toiminto eikä sitä voi perua.', 'Haluatko tuhota toimintatilan?');
                  if (doDelete) {
                    items.conditions.removeAt(index);
                  }
                  callback();
                }
            ),
        ])
      ]
    );
  }
}

Widget _timeRange(BuildContext context, OperationCondition operationCondition, Function callback) {

  return OutlinedButton(
    style: OutlinedButton.styleFrom(
        backgroundColor: mySecondaryColor,
        side: const BorderSide(
            width: 2, color: mySecondaryColor),
        shape: const RoundedRectangleBorder(
            borderRadius:
            BorderRadius.all(Radius.circular(10))),
        elevation: 10),
    onPressed: () async {
      TimeRange? timeRange = await showTimeRangePicker(
        fromText: 'Mistä',
        toText: 'Mihin',

        labels: ['0','3','6','9','12','15','18','21'].asMap().entries.map((e) {
          return ClockLabel.fromIndex(
              idx: e.key, length: 8, text: e.value);
        }).toList(),
        context: context,
        paintingStyle: PaintingStyle.stroke,
        backgroundColor: Colors.grey.withOpacity(0.2),
        start: const TimeOfDay(hour: 0, minute: 0),
        end: const TimeOfDay(hour: 23, minute: 59),
        ticks: 24,
        strokeColor: Theme.of(context).primaryColor.withOpacity(0.5),
        ticksColor: Theme.of(context).primaryColor,
        labelOffset: 15,
        padding: 60,
        disabledColor: Colors.red.withOpacity(0.5),
      );
      if (timeRange != null) {
        operationCondition.timeRange = MyTimeRange(startTime: timeRange.startTime, endTime: timeRange.endTime);
      }
      callback();
    },
    child: Text(
      _timeRangeToString(operationCondition.timeRange),
      maxLines: 1,
      style: TextStyle(color: mySecondaryFontColor),
      textScaleFactor: 2.0,
    ),
  );
}

String _timeRangeToString(MyTimeRange range) {
  return '${_timeToString(range.startTime)}-${_timeToString(range.endTime)}';
}

String _timeToString(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}.${time.minute.toString().padLeft(2, '0')}';
}

String _conditionText(OperationCondition condition) {
  switch (condition.conditionType) {
    case OperationConditionType.timeOfDay:
      return 'välillä ${_timeRangeToString(condition.timeRange)}';
    case OperationConditionType.spotPrice: {
      switch (condition.spot.myType) {
        case SpotPriceComparisonType.constant: return 'Jos hinta ${condition.spot.comparison.text()} ${condition.spot.parameterValue} c/kWh';
        case SpotPriceComparisonType.median: return 'Jos hinta ${condition.spot.comparison.text()} mediaani';
        case SpotPriceComparisonType.percentile: return 'Jos hinta ${condition.spot.comparison.text()} ${condition.spot.parameterValue.round()}. %-piste';
        default: return 'ei toteutettu';
      }
    }
    default:
      return 'odota vähän';
  }
}



Widget operationModeAnalysis(ConditionalOperationModes conditionalOperationModes) {
  List<String> data = conditionalOperationModes.simulate();
  return Column(
    children: <Widget>[
      for (int index = 0; index < data.length; index += 1)
        Text('${index == 0 ? '  ': '    '}${data[index]}'),
    ],
  );
}

