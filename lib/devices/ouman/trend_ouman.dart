
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:koti/trend/trend.dart';
import '../../look_and_feel.dart';

import 'package:koti/app_configurator.dart';

part 'trend_ouman.g.dart';

@HiveType(typeId: hiveTypeTrendOuman)
class TrendOuman extends TrendData {
  @HiveField(3)
  double outsideTemperature = 0.0;
  @HiveField(4)
  double measuredWaterTemperature = 0.0;
  @HiveField(5)
  double requestedWaterTemperature = 0.0;
  @HiveField(6)
  double valve = 0.0;

  TrendOuman(int timestamp,
      String estateId,
      String deviceId,
      this.outsideTemperature,
      this.measuredWaterTemperature,
      this.requestedWaterTemperature,
      this.valve) : super(timestamp, estateId, deviceId);

  @override
  String hiveName() {
    return hiveTrendOumanName;
  }


  @override
  Widget showInLine() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget> [
          _item(timestampToDateTimeString(timestamp, withoutYear: true)),
          _item('${_temperatureString(measuredWaterTemperature)} $celsius'),
          _item('${_temperatureString(requestedWaterTemperature)} $celsius'),
          _item('${_doubleToString(valve)} %'),
          _item('${_temperatureString(outsideTemperature)} $celsius')
        ]
    );
  }
}


Widget showOumanEvent(TrendOuman oumanEvent) {
  try {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget> [
          _item(timestampToDateTimeString(oumanEvent.timestamp, withoutYear: true)),
          _item('${_temperatureString(oumanEvent.measuredWaterTemperature)} $celsius'),
          _item('${_temperatureString(oumanEvent.requestedWaterTemperature)} $celsius'),
          _item('${_doubleToString(oumanEvent.valve)} %'),
          _item('${_temperatureString(oumanEvent.outsideTemperature)} $celsius')
        ]
    );
  }
  catch (e, st) {
    log.error('Unvalid oumanEvent', e, st);
    return const Text('Sisäinen virhe tietojen tulostuksessa',textScaleFactor:0.8);
  }
}

Widget _item(String text) {
  return Expanded( flex: 1, child: Text(text, textScaleFactor:0.8,textAlign:TextAlign.center));
}

String _temperatureString (double t) {
  return _doubleToString(t);
}

String _doubleToString (double t) {
  if (t == noValueDouble) {
    return '???';
  }
  else {
    return t.toStringAsFixed(1);
  }
}
