
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:koti/functionalities/boiler_heating/view/boiler_heating_overview.dart';
import 'package:koti/look_and_feel.dart';
import 'package:koti/service_catalog.dart';

import '../../../devices/mixins/on_off_switch.dart';
import '../../../logic/services.dart';
import '../../../logic/color_palette.dart';
import '../../functionality/view/functionality_view.dart';
import '../boiler_heating_functionality.dart';

class BoilerHeatingPalette extends ColorPalette {

}

class BoilerHeatingFunctionalityView extends FunctionalityView {

  late DeviceServiceClass<OnOffSwitchService> _mySwitch;
  bool cacheNotOk = true;

  bool deviceConnected() {
    return myBoilerFunctionality().connectedDevices[0].connected();
  }

  DeviceServiceClass<OnOffSwitchService> mySwitch() {
    if (cacheNotOk) {
        _mySwitch =
        myBoilerFunctionality().connectedDevices[0].services.getService(
            powerOnOffWaitingService) as DeviceServiceClass<OnOffSwitchService>;
        cacheNotOk = false;
    }
    return _mySwitch;
  }

  BoilerHeatingFunctionality myBoilerFunctionality() => myFunctionality() as BoilerHeatingFunctionality;

  BoilerHeatingFunctionalityView();

  BoilerHeatingFunctionalityView.fromJson(Map<String, dynamic> json)  {
    super.fromJson(json);
  }


  @override
  Widget gridBlock(BuildContext context, Function callback) {

    ColorPalette currentPalette = BoilerHeatingPalette();
    currentPalette.setCurrentPalette(
      false, // TODO: alarm set not implemented
      deviceConnected(),
      mySwitch().services.peek()
    );

    return ElevatedButton(
        style: buttonStyle(currentPalette.backgroundColor(), currentPalette.textColor()),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return BoilerHeatingOverview(boilerHeating: myBoilerFunctionality());
            },
          ));

          callback();
        },
        onLongPress: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AutoSizeText(
              myBoilerFunctionality().connectedDevices[0].name,
              stepGranularity:0.5,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 12)),
            _currentOperationModeWidget(
                myBoilerFunctionality().operationModes.currentModeName(),
                currentPalette.textColor()
            ),
            currentPalette.iconWidget(),
          ]),

    );
  }

  @override
  String viewName() {
    return BoilerHeatingFunctionality.functionalityName;
  }

  @override
  String subtitle() {
    return myFunctionality().connectedDevices[0].name;
  }

}

Icon _notConnectedIcon() {
  return const Icon(
    Icons.not_interested,
    size: 40,
    color: Colors.red
  );
}

Icon _heaterIcon(bool heating) {
  if (heating) {
    return const Icon(
      Icons.heat_pump_outlined,
      size: 40,
      color: Colors.yellowAccent
    );
  }
  else {
    return const Icon(
      Icons.not_interested,
      size: 40,
      color: Colors.white
    );
  }

}

Widget _currentOperationModeWidget(String opModeName, Color textColor ) {
  return
    Container(
//      margin: const EdgeInsets.all(0.0),
//      padding: const EdgeInsets.all(0.0),
      child:
      OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(0.0),
        foregroundColor: textColor,
        side:  BorderSide(
            color: textColor
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
      ),
      child: AutoSizeText(
          opModeName,
        style: TextStyle(fontSize: 10, color: textColor),
        minFontSize: 8,
          maxLines: 1,
          )));
}
