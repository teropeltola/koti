
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:koti/trend/trend.dart';

import 'package:koti/app_configurator.dart';

import '../look_and_feel.dart';

part 'trend_switch.g.dart';

@HiveType(typeId: hiveTypeTrendOnOffSwitch)
class TrendSwitch extends TrendData {
  @HiveField(3)
  bool on = false;
  @HiveField(4)
  String initiator= '';

  TrendSwitch(int timestamp,
      String estateId,
      String deviceId,
      this.on,
      this.initiator) : super(timestamp, estateId, deviceId);

  @override
  String hiveName() {
    return hiveTrendOnOffSwitch;
  }

  @override
  Widget showInLine() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
                    Expanded(
                      flex: 2,
                      child: Text(timestampToDateTimeString(timestamp, withoutYear: true))
                    ),
                    Expanded(
                        flex: 1,
                        child: on ? Icon(Icons.power) : Icon(Icons.power_off)
                    ),
                    Expanded(
                        flex: 4,
                        child: Text(' ${initiator}')
                    )
                  ]

    );
  }
}
