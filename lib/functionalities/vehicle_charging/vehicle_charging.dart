
import 'package:flutter/material.dart';

import 'package:koti/functionalities/vehicle_charging/view/vehicle_charging_view.dart';

import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class VehicleCharging extends Functionality {

  static const String functionalityName = 'kulkuneuvon lataus';

  VehicleCharging();

  @override
  Future<void> init () async {
  }

  bool status() {
    return false;
  }

  void setCharging() {
  }

  @override
  FunctionalityView myView() {
    return VehicleChargingView(this);
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
    return json;
  }

  @override
  VehicleCharging.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
  }
}