import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:koti/service_catalog.dart';

// Device color palette: working&on, working&off, not connected, alarm set
const Color deviceWorkingOnBackgroundColor = Colors.green;
const Color deviceWorkingOffBackgroundColor = Colors.yellow;
const Color deviceNotConnectedBackgroundColor = Colors.grey;
const Color deviceAlarmSetBackgroundColor = Colors.red;

const Color deviceWorkingOnTextColor = Colors.white;
const Color deviceWorkingOffTextColor = Colors.black;
const Color deviceNotConnectedTextColor = Colors.black;
const Color deviceAlarmSetTextColor = Colors.white;

const Color deviceWorkingOnIconColor = Colors.white;
const Color deviceWorkingOffIconColor = Colors.black;
const Color deviceNotConnectedIconColor = Colors.black;
const Color deviceAlarmSetIconColor = Colors.white;

const double iconSizeDefault = 50;

enum ColorPaletteMode {alarmSet, notConnected, workingOff, workingOn, all
}

class ColorPaletteItem {
  late Color backgroundColor;
  late Color textColor;
  late Color iconColor;
  late IconData icon;
  late double iconSize;

  ColorPaletteItem(this.backgroundColor, this.textColor, this.iconColor, this.icon, this.iconSize);
  void modify({Color? newBackgroundColor, Color? newTextColor, Color? newIconColor, IconData? newIcon, double? newIconSize}) {
    if (newBackgroundColor != null) {
      backgroundColor = newBackgroundColor;
    }
    if (newTextColor != null) {
      textColor = newTextColor;
    }
    if (newIconColor != null) {
      iconColor = newIconColor;
    }
    if (newIcon != null) {
      icon = newIcon;
    }
    if (newIconSize != null) {
      iconSize = newIconSize;
    }
  }
}
class ColorPalette {

  List<ColorPaletteItem> items = [
    ColorPaletteItem(deviceAlarmSetBackgroundColor, deviceAlarmSetTextColor, deviceAlarmSetIconColor, Icons.alarm_on, iconSizeDefault),
    ColorPaletteItem(deviceNotConnectedBackgroundColor, deviceNotConnectedTextColor, deviceNotConnectedIconColor, Icons.not_interested, iconSizeDefault),
    ColorPaletteItem(deviceWorkingOffBackgroundColor, deviceWorkingOffTextColor, deviceWorkingOffIconColor, Icons.power_off, iconSizeDefault),
    ColorPaletteItem(deviceWorkingOnBackgroundColor, deviceWorkingOnTextColor, deviceWorkingOnIconColor, Icons.power_outlined, iconSizeDefault)
  ];

  ColorPaletteMode currentMode = ColorPaletteMode.notConnected;

  void modify(ColorPaletteMode newMode, {Color? newBackgroundColor, Color? newTextColor, Color? newIconColor, IconData? newIcon, double? newIconSize}) {
    if (newMode == ColorPaletteMode.all) {
      for (var item in items) {
        item.modify(newBackgroundColor: newBackgroundColor,
            newTextColor: newTextColor,
            newIconColor: newIconColor,
            newIcon: newIcon,
            newIconSize: newIconSize);
      }
    }
    else {
      items[newMode.index].modify(newBackgroundColor: newBackgroundColor,
          newTextColor: newTextColor,
          newIconColor: newIconColor,
          newIcon: newIcon,
          newIconSize: newIconSize);
    }
  }

  ColorPaletteItem currentPaletteItem() {
    return items[currentMode.index];
  }

  Color backgroundColor() {
    return currentPaletteItem().backgroundColor;
  }
  Color textColor() {
    return currentPaletteItem().textColor;
  }
  Color iconColor() {
    return currentPaletteItem().iconColor;
  }
  IconData icon() {
    return currentPaletteItem().icon;
  }

  double iconSize() {
    return currentPaletteItem().iconSize;
  }

  Icon iconWidget() {
    ColorPaletteItem current = currentPaletteItem();
    return Icon(current.icon, size: current.iconSize, color: current.iconColor);
  }

  void setCurrentPalette(bool alarmOn, bool connected, bool isOn) {
    if (alarmOn) {
      currentMode = ColorPaletteMode.alarmSet;
    }
    else if (!connected) {
      currentMode = ColorPaletteMode.notConnected;
    }
    else if (isOn) {
      currentMode = ColorPaletteMode.workingOn;
    }
    else {
      currentMode = ColorPaletteMode.workingOff;;
    }
  }
}
