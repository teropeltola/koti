
import 'package:flutter/material.dart';

import '../../functionality/view/functionality_view.dart';

class VehicleChargingView extends FunctionalityView {

  VehicleChargingView();

  VehicleChargingView.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }

  @override
  Widget gridBlock(BuildContext context, Function callback) {

    return ElevatedButton(
        style:buttonStyle(Colors.blueAccent, Colors.white),
        onPressed: () {
          callback();
        },
        onLongPress: () {
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              viewName(),
              style: const TextStyle(fontSize: 12)),
            const Icon(
              Icons.electric_car_outlined,
              size: 50,
              color: Colors.white,
          )
            ])
    );
  }

  @override
  String viewName() {
    return 'Auton lataus';
  }

  @override
  String subtitle() {
    return 'Tesla';
  }


}

