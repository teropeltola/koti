import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koti/logic/dropdown_content.dart';
import 'package:koti/service_catalog.dart';
import 'package:koti/view/ready_widget.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../devices/device/device.dart';
import '../devices/mixins/on_off_switch.dart';
import '../estate/estate.dart';
import '../foreground_configurator.dart';
import '../logic/services.dart';
import '../look_and_feel.dart';
import '../operation_modes/conditional_operation_modes.dart';
import 'my_dropdown_widget.dart';

const String _timerTaskType = 'kellonaika';
const String _priceTaskType = 'sähkön hinta';
const List<String> _possibleActionTypeNames = [_timerTaskType, _priceTaskType];

const String _onOffSwitch = 'on/off-kytkin';
const String _temperature = 'lämpötila';
const String _operationState = 'toimintotila';

const _possibleActionNames = [_onOffSwitch, _temperature, _operationState];

class _TimeParameters {
  bool recurringValue = true;
  bool setTimeValue = false;
  TimeOfDay timeOfDay = TimeOfDay(hour:12, minute: 0);
  int minutes = 10;
  int hours = 0;
  int days = 0;
}

const String valueComparison = 'vakio';
const String minimumValue = 'minimi';
const String maximumValue = 'maksimi';

const List<String> _possiblePriceParameterNames = ['vakio', 'minimi', 'maksimi'];
class _PriceParameters extends SpotCondition {
  String currentType() {
    return possiblePriceParameterTypes.currentString();
  }

  DropdownContent possiblePriceParameterTypes = DropdownContent(
      _possiblePriceParameterNames, '', 0);

}

class SetTimerTask extends StatefulWidget {
  const SetTimerTask({Key? key}) : super(key: key);

  @override
  _SetTimerTaskState createState() => _SetTimerTaskState();
}

class _SetTimerTaskState extends State<SetTimerTask> {
  late Estate estate;
  String currentActionType = '';
  String currentAction = '';
  DropdownContent possibleActionTypes = DropdownContent(_possibleActionTypeNames, '', 0);
  DropdownContent possibleActions = DropdownContent(_possibleActionNames, '', 0);
  late DropdownContent onOffDevices;
  late List<String> onOffDeviceCanditates;
  bool onOffValue = false;
  _TimeParameters timeParameters = _TimeParameters();
  _PriceParameters priceParameters = _PriceParameters();
  bool possibleToSetTasks = false;

  @override
  void initState() {
    super.initState();
    estate = myEstates.currentEstate();
    onOffDeviceCanditates = estate.findPossibleDevices(deviceService: powerOnOffWaitingService);
    possibleToSetTasks = onOffDeviceCanditates.isNotEmpty;
    onOffDevices = DropdownContent(onOffDeviceCanditates, '', 0);
    currentActionType = possibleActionTypes.currentString();
    currentAction = possibleActions.currentString();
    refresh();
  }
  void refresh() {
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appIconAndTitle(estate.name, 'ajasta tehtävä'),
      ), //new line
      body: SingleChildScrollView(
        child: !possibleToSetTasks
          ? Text('\n\n       Ei laitteita, joille voisi ajastaa tehtäviä!'
                   '\n       Palaa takaisin ja lisää ensin laitteita!')
          : Column(children: <Widget>[
            Container(
              margin: myContainerMargin,
              padding: myContainerPadding,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tehtävän tiedot'),
                    child: Column(children: <Widget>[
                      Container(
                        margin: myContainerMargin,
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                        child: InputDecorator(
                          decoration:
                          const InputDecoration(labelText: 'Tehtävätyyppi'),
                          child: SizedBox(
                              height: 30,
                              width: 120,
                              child: MyDropdownWidget(
                                  keyString: 'taskType',
                                  dropdownContent: possibleActionTypes,
                                  setValue: (newValue) {
                                    currentActionType = possibleActionTypes.currentString();
                                    setState(() {});
                                  }
                              )
                          ),
                        ),
                      ),
                      Container(
                        margin: myContainerMargin,
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                        child: InputDecorator(
                          decoration:
                            const InputDecoration(labelText: 'Tehtävä'),
                          child: SizedBox(
                            height: 30,
                            width: 120,
                            child: MyDropdownWidget(
                              keyString: 'timerTaskType',
                              dropdownContent: possibleActions,
                              setValue: (newValue) {
                                currentAction = possibleActions.currentString();
                                setState(() {});
                              }
                            )
                          ),
                        ),
                      ),
                      (currentAction == _onOffSwitch)
                      ? Container(
                          margin: myContainerMargin,
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                          child: InputDecorator(
                            decoration:
                            const InputDecoration(labelText: 'Aseta on/off -kytkin'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                height: 30,
                                width: 120,
                                child: MyDropdownWidget(
                                    keyString: 'onoffselection',
                                    dropdownContent: onOffDevices,
                                    setValue: (newValue) {
                                      setState(() {});
                                    }
                                  ),
                                ),
                                const Spacer(flex: 1),
                                Text('Pois', style: TextStyle(color: onOffValue ? Colors.grey : Colors.black),),
                                Switch(
                                  value: onOffValue,
                                  //overlayColor: overlayColor,
                                  //trackColor: trackColor,
                                  //thumbColor: const WidgetStatePropertyAll<Color>(Colors.black),
                                  onChanged: (bool value) {
                                    // This is called when the user toggles the switch.
                                    setState(() {
                                      onOffValue = value;
                                    });
                                  }
                                ),
                                Text('Päälle', style: TextStyle(color: onOffValue ? Colors.black : Colors.grey)),
                              ]
                            )
                        )
                       ): Container(
                        margin: myContainerMargin,
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                        child: InputDecorator(
                          decoration:
                            const InputDecoration(labelText: 'Tehtävätyyppi'),
                            child: Text('ei vielä toteutettu')
                        )
                      )
                    ]
                  )
               )
            ),
            (currentActionType == _timerTaskType)
            ? _myTimeWidget(context, timeParameters, (){setState(() {});})
            : _myPriceWidget(context, priceParameters, (){setState(() {});}),
            readyWidget( () async {
              if (currentAction == _onOffSwitch) {
                Device device = myEstates.currentEstate().myDeviceFromName(
                    onOffDevices.currentString());
                DeviceServiceClass<OnOffSwitchService> mySwitchDeviceService =
                  device.services.getService(
                    powerOnOffWaitingService) as
                      DeviceServiceClass<OnOffSwitchService>;
                Map <String, dynamic> parameters = {};
                bool userAccepted = false;

                if (currentActionType == _timerTaskType) {
                  parameters[recurringKey] = timeParameters.recurringValue;
                  parameters[powerOn] = onOffValue;
                  if (timeParameters.setTimeValue) {
                    parameters[timeOfDayHourKey] =
                        timeParameters.timeOfDay.hour;
                    parameters[timeOfDayMinuteKey] =
                        timeParameters.timeOfDay.minute;
                  }
                  else {
                    parameters[intervalInMinutesKey] =
                    (timeParameters.minutes + timeParameters.hours * 60 +
                        timeParameters.days * 24 * 60);
                  }
                }
                else { // price task
                  parameters[recurringKey] = true;
                  priceParameters.myType = SpotPriceComparisonType.constant;
                  parameters[priceComparisonTypeKey] = priceParameters.toJson();
                }

                userAccepted = await askUserGuidance(context,
                    _userGuidanceTitle(device.name, parameters),
                    'Asetetaanko tehtävä (paina "Kyllä" tai "Ei")?');
                if (userAccepted) {
                  await mySwitchDeviceService.services.defineTask(parameters);
                  Navigator.pop(context, true);
                }
              }

            })
          ]
        )
      )
    );
  }
}

Widget _myPriceWidget(BuildContext context, _PriceParameters priceParameters, Function callback) {
  return Container(
      margin: myContainerMargin,
      padding: myContainerPadding,
      child: InputDecorator(
      decoration: const InputDecoration(
      labelText: 'Sähkön hinta'),
      child: Column(children: <Widget>[
        Container(
          margin: myContainerMargin,
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
          child: Column ( children: <Widget>[
            Container(
              margin: myContainerMargin,
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
              child: InputDecorator(
                decoration:
                const InputDecoration(labelText: 'Vertailutapa'),
                child: SizedBox(
                    height: 30,
                    width: 120,
                    child: MyDropdownWidget(
                        keyString: 'priceComparisonType',
                        dropdownContent: priceParameters.possiblePriceParameterTypes,
                        setValue: (newValue) {
                          callback();
                        }
                    )
                ),
              ),
            ),
            (priceParameters.currentType() == valueComparison)
            ? Container(
              margin: const EdgeInsets.fromLTRB(0, 8, 0, 2),
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
              child: InputDecorator(
                decoration:
                const InputDecoration(labelText: 'Vakiovertailu'),
                child: SizedBox(
                    height: 80,
                    width: 120,
                    child: _constantPriceComparison(context, priceParameters, callback)
                    )
                ),

            )
            : Text('ei vielä toteutettu')
          ])
        )
      ])
      ));
}

DropdownContent _comparisonOptions = DropdownContent(OperationComparisons.comparisonChangeText,'',0);

ListTile _constantPriceComparison(
      BuildContext context,
      _PriceParameters priceParameters,
      Function callback) {

  return ListTile(
    title:
        Row(children: [
          const Expanded(
                  flex: 8,
                  child: Text('Hinta muuttuu')),
          Expanded(flex: 12, child: MyDropdownWidget(
                  keyString: 'conditionOptions',
                  dropdownContent: _comparisonOptions,
                  setValue: (val) {
                    priceParameters.comparison = OperationComparisons.values[val];
                    callback();
                  })
              ),
          Expanded(
            flex: 8,
            child: TextFormField(
              keyboardType:const TextInputType.numberWithOptions(decimal: true),
              initialValue: priceParameters.parameterValue.toString(),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))],
              onChanged: (stringValue) {
                if (double.tryParse(stringValue) != null) {
                  priceParameters.parameterValue = double.parse(stringValue);
                }
                callback();
              }
            )
          ),
          const Expanded(
              flex: 1,
              child: Text('c')),

        ],),
  );
}

Widget _myTimeWidget(BuildContext context, _TimeParameters timeParameters, Function callback) {
  return Container(
      margin: myContainerMargin,
      padding: myContainerPadding,
      child: InputDecorator(
          decoration: const InputDecoration(
              labelText: 'Ajastus'),
          child: Column(children: <Widget>[
            Container(
              margin: myContainerMargin,
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
              child: Column (
                  children: [
                    ToggleSwitch(
                      minWidth: 120.0,
                      minHeight: 40.0,
                      fontSize: 20.0,
                      initialLabelIndex: timeParameters.recurringValue ? 1 : 0,
                      activeBgColor: [Colors.blue],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.grey[700],
                      totalSwitches: 2,
                      labels: ['Kerran', 'Toistuva'],
                      onToggle: (index) {
                        if (index != null) {
                          timeParameters.recurringValue = (index == 1);
                          callback();
                        }
                      },
                    ),
                    Text(''),
                    ToggleSwitch(
                      minWidth: 120.0,
                      minHeight: 40.0,
                      fontSize: 20.0,
                      initialLabelIndex: timeParameters.setTimeValue ? 1 : 0,
                      activeBgColor: [Colors.blue],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.grey[700],
                      totalSwitches: 2,
                      labels: ['Aikaväli', 'Kellonaika'],
                      onToggle: (index) {
                        if (index != null) {
                          timeParameters.setTimeValue = (index == 1);
                          callback();
                        }
                      },
                    ),
                    Text(''),
                    timeParameters.setTimeValue
                        ?
                    TextButton(
                        onPressed: () async {
                          TimeOfDay? possibleAnswer = await showTimePicker(
                            context: context,
                            initialTime: timeParameters.timeOfDay,
                            builder: (BuildContext context, Widget? child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            },
                          );
                          if (possibleAnswer != null) {
                            timeParameters.timeOfDay = possibleAnswer;
                            callback();
                          }
                        },
                        child: Text( '${myTimeFormatter(timeParameters.timeOfDay.hour, timeParameters.timeOfDay.minute)}',
                            style: TextStyle(fontSize:24, backgroundColor: Colors.blue, color: Colors.white,)

                        ))
                        : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                              flex: 5,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                    labelText: 'Päivät'),
                                child:NumberPicker(
                                  value: timeParameters.days,
                                  itemHeight: 30,
                                  itemWidth: 40,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey)),
                                  selectedTextStyle: TextStyle(fontSize: 20, backgroundColor: Colors.blue, color: Colors.white),
                                  textStyle: TextStyle(fontSize: 14),
                                  // infiniteLoop: true, // not working - bug in the package
                                  minValue: 0,
                                  maxValue: 366,
                                  onChanged: (value) { timeParameters.days = value; callback(); }
                                ),
                              )),
                          Spacer(),
                          Expanded(
                              flex: 5,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                    labelText: 'Tunnit'),
                                child:
                                NumberPicker(
                                  value: timeParameters.hours,
                                  itemHeight: 30,
                                  itemWidth: 40,
                                  selectedTextStyle: TextStyle(fontSize: 20, backgroundColor: Colors.blue, color: Colors.white),
                                  textStyle: TextStyle(fontSize: 14),
                                  minValue: 0,
                                  maxValue: 24,
                                  onChanged: (value) {timeParameters.hours = value; callback(); },
                                ),
                              )),
                          Spacer(),
                          Expanded(
                              flex: 5,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                    labelText: 'Minuutit'),
                                child:
                                NumberPicker(
                                  value: timeParameters.minutes,
                                  itemHeight: 30,
                                  itemWidth: 40,
                                  selectedTextStyle: TextStyle(fontSize: 20, backgroundColor: Colors.blue, color: Colors.white),
                                  textStyle: TextStyle(fontSize: 14),
                                  minValue: 0,
                                  maxValue: 59,
                                  onChanged: (value) { timeParameters.minutes = value; callback(); }
                                ),
                              ))
                        ]),
                  ]
              ),)
          ]
          )
      )
  );

}

String _userGuidanceTitle(String deviceName, Map<String, dynamic> parameters) {
  String titleStart = 'Uusi tehtävä: ${deviceName} asetetaan ${parameters[powerOn] ?? false ? 'pois' : 'päälle'}';
  bool recurring = parameters[recurringKey] ?? false;
  if (parameters[priceComparisonTypeKey] != null) {
    SpotCondition spotCondition = SpotCondition.fromJson(parameters[priceComparisonTypeKey]);
    return '$titleStart päivittäin, kun sähkö hinta muuttuu '
            '${spotCondition.comparison.changeText()} ${currencyCentInText(spotCondition.parameterValue)}.';
  }
  else if (parameters[timeOfDayHourKey] != null) {
    //timeOfDay
    return '$titleStart ${recurring ? 'toistuvasti päivittäin' : 'kerran'}'
    ' klo ${myTimeFormatter(parameters[timeOfDayHourKey], parameters[timeOfDayMinuteKey])}.';
  }
  else {
    return '$titleStart ${recurring ? 'toistuvasti päivittäin' : 'kerran'} '
            '${_timeInterval(parameters[intervalInMinutesKey] ?? 0)} '
            '${recurring ? 'välein' : 'päästä'}.';
  }
}

String _timeInterval(int minutes) {
  String returnStringStart = '';
  if (minutes >= 24*60) {
    returnStringStart = '${(minutes / (24*60)).floor()} päivän ';
    minutes = minutes % (24*60);
  }
  if (minutes >= 60) {
    returnStringStart += '${(minutes / 60).floor()} tunnin ';
    minutes = minutes % 60;
  }
  return '$returnStringStart$minutes minuutin';
}