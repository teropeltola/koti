import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../../shelly/shelly_scan.dart';
import '../device.dart';

ButtonStyle _buttonStyle (Color backgroundColor, Color foregroundColor) {
  return   ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: EdgeInsets.all(2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      )
  );
}

Widget shortNamedDeviceView(
    BuildContext context,
    Estate estate,
    Device device,
    Color deviceColor,
    Function callback) {

  return ElevatedButton(
      style:_buttonStyle(deviceColor, Colors.white),
      onPressed: () async {
        bool status = await device.editWidget(context, estate);
        callback();
      },
      onLongPress: () {
        callback();
      },
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(device.name,
                 style: const TextStyle(fontSize: 12)),
            Icon(
              device.icon(),
              size: 18,
              color: Colors.white,
            ),
            AutoSizeText(device.shortTypeName(),
                textAlign: TextAlign.center,
                presetFontSizes: [8,10,12,14],

                ),
          ])
  );
}

const int _crossAxisCount = 4;

double _height(int itemCount) {
  if (itemCount == 0) {
    return 100.0;
  }
  else {
    int nbrOfLines = 1 + ((itemCount-1) ~/ _crossAxisCount);
    return 20.0 + 100.0 * nbrOfLines;
  }
}

Widget devicesGrid(
    BuildContext context,
    String title,
    Color deviceColor,
    Estate estate,
    List <Device> devices,
    Function callback
) {
  return  Container(
    margin: myContainerMargin,
    padding: myContainerPadding,
    height: _height(devices.length),
    child:
      InputDecorator(
        decoration: InputDecoration(
          labelText: title),
        child:
          devices.isEmpty
          ? Text('Ei laitteita')
          : GridView.count(
            crossAxisCount: _crossAxisCount,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            padding: const EdgeInsets.all(1.0),
            children: [
              for (var device in devices)
                shortNamedDeviceView(
                  context,
                  estate,
                  device,
                  deviceColor,
                  callback)
            ]
          )
      )
  );
}
