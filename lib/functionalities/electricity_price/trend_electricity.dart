import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../look_and_feel.dart';

import 'package:koti/app_configurator.dart';

part 'trend_electricity.g.dart';

@HiveType(typeId: hiveTypeTrendElectricityPrice)
class TrendElectricity {
  @HiveField(1)
  int timestamp = 0;
  @HiveField(2)
  double price = 0.0;

  TrendElectricity(
      this.timestamp,
      this.price,
  );

  String hiveName() {
    return hiveTrendElectricityPriceName;
  }

  Widget showInLine() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget> [
          _item(timestampToDateTimeString(timestamp, withoutYear: true)),
          _item('${_doubleToEuroString(price)} €'),
        ]
    );
  }
}

Widget _item(String text) {
  return Expanded( flex: 1, child: Text(text, textScaleFactor:0.8,textAlign:TextAlign.center));
}


String _doubleToEuroString (double t) {
  if (t == noValueDouble) {
    return '???';
  }
  else {
    return t.toStringAsFixed(2);
  }
}
