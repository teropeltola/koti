
import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../devices/device/device.dart';
import '../../../logic/color_palette.dart';
import '../../../look_and_feel.dart';
import '../../functionality/view/functionality_view.dart';
import '../thermostat.dart';

class ThermostatView extends FunctionalityView {

  @override
  String viewName() {
    return Thermostat.functionalityName;
  }

  Thermostat myThermostat() {
    return myFunctionality() as Thermostat;
  }

  @override
  String subtitle() {
    return myThermostat().thermoName;
  }

  ThermostatView();

  ThermostatView.fromJson(Map<String, dynamic> json);

  double _stepGranularity() {
    if (myThermostat().thermostatMode == ThermostatMode.simple) {
      return myThermostat().minAccuracy;
    }
    else if (myThermostat().thermostatMode == ThermostatMode.average) {
      if (myThermostat().minAccuracy < 0.2) {
        return 0.1;
      }
      else {
        return 0.5;
      }
    }
    return 1.0;
  }

  ColorPalette _colorPalette() {
    ColorPalette colorPalette = ColorPalette();
    colorPalette.modify(ColorPaletteMode.all, newIcon: Icons.thermostat, newIconSize: 30.0);
    if (myThermostat().thermostatMode == ThermostatMode.average) {
      colorPalette.modify(ColorPaletteMode.workingOn, newBackgroundColor: Colors.cyan, newTextColor: Colors.white, newIconColor: Colors.white);
      colorPalette.setCurrentPalette(false, true, true); // average is always working on
    }
    else {
      if (myThermostat().connectedDevices.isEmpty) {
        colorPalette.setCurrentPalette(true, false, false);
      }
      else {
        Device myDevice = myThermostat().connectedDevices.first;
        colorPalette.setCurrentPalette(
            myDevice.alarmOn(), myDevice.connected(), true);
      }
    }
    return colorPalette;
  }

  @override
  Widget gridBlock(BuildContext context, Function callback) {

    ColorPalette colorPalette = _colorPalette();

    return ElevatedButton(
        style: buttonStyle(colorPalette.backgroundColor(), colorPalette.textColor()),
        onPressed: () async {
          callback();
        },
        onLongPress: () async {
          double oldTarget = myThermostat().targetTemperature();
          if (oldTarget == noValueDouble) {
            informMatterToUser(context, 'Ei yhteyttä termostaattiin', 'Ei voida säätää tavoitelämpötilaa');
          }
          else {
            double newTarget = await defineNewTarget(
                context, myThermostat().thermoName, oldTarget, _stepGranularity()) ?? oldTarget;
            if (newTarget != oldTarget) {
              myThermostat().setTargetTemperature(newTarget);
              callback();
            }
          }

        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    colorPalette.iconWidget(),
                    AutoSizeText(
                      '${temperatureString(myThermostat().currentTemperature())}',
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12)
                ),
              ]
              )
              ),
              Center(child: Text(
                  '${temperatureString(myThermostat().targetTemperature())}',
                  style: const TextStyle(
                      fontSize: 24))
              ),
              Center(child: AutoSizeText(
                  myThermostat().thermoName,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 12)),
              )
            ])
    );
  }
}
Widget _updateButton(BuildContext context, bool up, Function callback) {
  return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all( up ? Colors.red : Colors.blueAccent),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                 // side: BorderSide(color: Colors.red)
              )
          )
    ),
    onPressed: () async {
      callback();
    },
    child: Text(up ? '+' : '-',
      style: const TextStyle(
          fontSize: 40,
          color: Colors.white,

          fontWeight: FontWeight.w800
      )
  ),
  );

}

const double delta = 0.1;

void showLoaderDialog(BuildContext context, double inputValue, Function returnValue) {

  double currentValue = inputValue;
  AlertDialog alert = AlertDialog(
    content: SizedBox(
      height: 100,
        child: Column(
        children: [
      Text('aseta uusi tavoitelämpötila'),
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _updateButton(context, false, () {
          currentValue -= delta;
          returnValue(currentValue);
        }),
        Text('${temperatureString(inputValue)}',
            style: const TextStyle(
                fontSize: 30,
                color: Colors.black,

                fontWeight: FontWeight.w800
            )),

        _updateButton(context, true, () {
          currentValue += delta;
          returnValue(currentValue);
        }),
      ],
    ),
    ])
    )
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}


// returns a new value of the target temperature
const _tempInputDuration = Duration(seconds: 3);

Future<double?> defineNewTarget(BuildContext context, String name, double initialValue, double step) async {
  double currentValue = initialValue;
  final Completer<double?> completer = Completer<double?>();
  Timer? timer;

  void resetTimer() {
    timer?.cancel();
    timer = Timer(_tempInputDuration, () {
      completer.complete(currentValue);
      Navigator.of(context).pop();
    });
  }

  resetTimer(); // Start the initial timer

  return showDialog<double?>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(name, textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('aseta uusi tavoitelämpötila'),
                Text(''),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.blue, // Button color
                      ),
                      onPressed: () {
                        setState(() {
                          currentValue -= step;
                          resetTimer();
                        });
                      },
                    ),
                    Text('${temperatureString(currentValue)}',
                        style: const TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.w800
                        )),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.red, // Button color
                      ),
                      onPressed: () {
                        setState(() {
                          currentValue += step;
                          resetTimer();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  ).then((value) => completer.future);
}

