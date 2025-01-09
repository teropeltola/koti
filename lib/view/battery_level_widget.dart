import 'package:flutter/material.dart';

const List<Icon> _batteryIcons = [
  Icon(Icons.battery_0_bar, color:Colors.red),
  Icon(Icons.battery_1_bar, color:Colors.red),
  Icon(Icons.battery_2_bar, color:Colors.deepOrange),
  Icon(Icons.battery_3_bar, color:Colors.orange),
  Icon(Icons.battery_4_bar, color:Colors.yellow),
  Icon(Icons.battery_5_bar, color:Colors.lightGreen),
  Icon(Icons.battery_6_bar, color:Colors.green),
  Icon(Icons.battery_full, color:Colors.green),
];


Widget _batteryIcon(int batteryLevel) {
  int index =  (batteryLevel/ 100.0 * _batteryIcons.length ).floor();

  if (index < 0) {
    index = 0;
  }
  else if (index > _batteryIcons.length-1) {
    index = _batteryIcons.length-1;
  }
  return _batteryIcons[index];
}

class BatteryLevelWidget extends StatelessWidget {
  final int batteryLevel;
  const BatteryLevelWidget({Key? key, required this.batteryLevel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _batteryIcon(batteryLevel);
  }
}
