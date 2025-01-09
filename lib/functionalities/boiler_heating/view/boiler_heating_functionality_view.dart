
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:koti/functionalities/boiler_heating/view/boiler_heating_overview.dart';
import 'package:koti/look_and_feel.dart';
import 'package:koti/service_catalog.dart';

import '../../../devices/mixins/on_off_switch.dart';
import '../../../logic/services.dart';
import '../../functionality/functionality.dart';
import '../../functionality/view/functionality_view.dart';
import '../boiler_heating_functionality.dart';

class BoilerHeatingFunctionalityView extends FunctionalityView {

  late DeviceServiceClass<OnOffSwitchService> _mySwitch;
  bool cacheNotOk = true;

  DeviceServiceClass<OnOffSwitchService> mySwitch() {
    if (cacheNotOk) {
      _mySwitch = myBoilerFunctionality().connectedDevices[0].services.getService(powerOnOffWaitingService) as DeviceServiceClass<OnOffSwitchService>;
      cacheNotOk = false;
    }
    return _mySwitch;
  }

  BoilerHeatingFunctionality myBoilerFunctionality() => myFunctionality() as BoilerHeatingFunctionality;

  BoilerHeatingFunctionalityView()  {
  }

  BoilerHeatingFunctionalityView.fromJson(Map<String, dynamic> json)  {
    super.fromJson(json);
  }

  @override
  void setFunctionality(Functionality functionality) {
    super.setFunctionality(functionality);
  }

  @override
  Widget gridBlock(BuildContext context, Function callback) {

    return ElevatedButton(
        style: mySwitch().services.peek()
          ? buttonStyle(Colors.green, Colors.white)
          : buttonStyle(Colors.grey, Colors.white),
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
            Text(
              myBoilerFunctionality().connectedDevices[0].name,
              style: const TextStyle(
                fontSize: 12)),
            _currentOperationModeWidget(
                myBoilerFunctionality().operationModes.currentModeName(),
                mySwitch().services.peek()),
            _heaterIcon(mySwitch().services.peek()),
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


Icon _heaterIcon(bool heating) {
  if (heating) {
    return Icon(
      Icons.heat_pump_outlined,
      size: 40,
      color: Colors.yellowAccent
    );
  }
  else {
    return Icon(
      Icons.not_interested,
      size: 40,
      color: Colors.white
    );
  }

}

Widget _currentOperationModeWidget(String opModeName, bool heating) {
  return
    Container(
//      margin: const EdgeInsets.all(0.0),
//      padding: const EdgeInsets.all(0.0),
      child:
      OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(0.0),
        foregroundColor: heating
            ? Colors.white
            : Colors.white,
        side: BorderSide(
            color: Colors.white
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
      ),
      child: AutoSizeText(
          opModeName,
        style: TextStyle(fontSize: 10, color: Colors.white),
        minFontSize: 8,
          maxLines: 1,
          )));
}
