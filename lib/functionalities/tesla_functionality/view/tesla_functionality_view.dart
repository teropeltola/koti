
import 'package:flutter/material.dart';

import '../../functionality/functionality.dart';
import '../../functionality/view/functionality_view.dart';

class TeslaFunctionalityView extends FunctionalityView {

  TeslaFunctionalityView(dynamic myFunctionality) : super(myFunctionality) {
  }

  TeslaFunctionalityView.fromJson(Map<String, dynamic> json) : super(allFunctionalities.noFunctionality()) {
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
          'Tesla',
          style: const TextStyle(
          fontSize: 12)),
          Icon(
            Icons.electric_car_outlined,
            size: 50,
            color: Colors.white,
          )
            ])
    );
  }
}

