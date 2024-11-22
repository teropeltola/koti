import 'package:flutter/material.dart';
import '../../logic/unique_id.dart';
import '../device/device.dart';

class Vehicle extends Device {

  Vehicle() {
    id = UniqueId('V').get();
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: name,
        textLines: [
          'tunnus: $id',
        ],
        widgets: [
          dumpDataMyFunctionalities(formatterWidget: formatterWidget),
        ]
    );
  }


  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  void fromJson(Map<String, dynamic> json){
    super.fromJson(json);
  }

  @override
  Vehicle.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

}