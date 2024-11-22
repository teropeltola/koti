import 'package:flutter/material.dart';

import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';
import 'package:koti/functionalities/heating_system_functionality/view/edit_heating_system_view.dart';
import 'package:koti/functionalities/heating_system_functionality/view/heating_system_view.dart';
import '../../devices/device/device.dart';
import '../../devices/ouman/ouman_device.dart';
import '../../estate/estate.dart';
import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class HeatingSystem extends Functionality {

  static const String functionalityName = 'lämmitysjärjestelmä';

  MitsuHeatPumpDevice myAirPump = MitsuHeatPumpDevice();

  HeatingSystem() {
  }

  HeatingSystem.failed() {
    setFailed();
  }

  @override
  Future<void> init () async {
  }


  OumanDevice myOuman() {
    return connectedDeviceOf('OumanDevice') as OumanDevice;
  }

  @override
  FunctionalityView myView() {
    return HeatingSystemView(this);
  }


  @override
  Future<bool> editWidget(BuildContext context, bool createNew, Estate estate, Functionality functionality, Device device) async {
    return await Navigator.push(context, MaterialPageRoute(
        builder: (context)
    {
      return EditHeatingSystemView(
          estateName: estate.name,
          heatingSystem: functionality as HeatingSystem
      );
    }
    ));
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: functionalityName,
        textLines: [
          'tunnus: $id',
        ],
        widgets: [
          dumpDataMyDevices(formatterWidget: formatterWidget)
        ]
    );
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['myAirPump'] = myAirPump.id;
    return json;
  }

  @override
  HeatingSystem.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    myAirPump = allDevices.findDevice(json['myAirPump'] ?? '') as MitsuHeatPumpDevice;
  }

}

HeatingSystem createNewHeatingSystem(OumanDevice ouman, MitsuHeatPumpDevice mitsu) {

  HeatingSystem heatingSystem = HeatingSystem();
  heatingSystem.pair(ouman);
  heatingSystem.myAirPump = mitsu;
  heatingSystem.pair(mitsu);

  return heatingSystem;
}
