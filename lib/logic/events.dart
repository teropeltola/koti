import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:koti/trend/trend.dart';
import 'package:koti/trend/trend_event.dart';

import '../app_configurator.dart';
import '../devices/device/device.dart';
import '../estate/estate.dart';
import 'observation.dart';
import '../look_and_feel.dart';

class Events {
  late TrendBox<TrendEvent> eventBox;

  Future<void> init() async {


    await trend.initBox<TrendEvent>(hiveTrendEventName);
    eventBox = trend.open(hiveTrendEventName);

  }

  void write(String estateId, String deviceId,
      ObservationLevel observationLevel, String eventText) {
    eventBox.add(TrendEvent(
      DateTime.now().millisecondsSinceEpoch,
      estateId,
      deviceId,
      observationLevel,
      eventText));

    if ((observationLevel == ObservationLevel.ok) || (observationLevel == ObservationLevel.informatic)) {
      log.info('${_estateAndDeviceHeader(estateId, deviceId)} $eventText');
    }
    else if (observationLevel == ObservationLevel.warning) {
      log.warning('${_estateAndDeviceHeader(estateId, deviceId)} $eventText');
    }
    else {
      log.error('${_estateAndDeviceHeader(estateId, deviceId)} $eventText');
    }
  }

  List<TrendEvent> getAll() {
    return eventBox.getAll();
  }
}

String _estateName(String estateId) {
  return myEstates.estateFromId(estateId).name;
}

String _deviceName(String deviceId) {
  Device d = allDevices.findDevice(deviceId);
  if (d == noDevice) {
    return '???';
  }
  return d.name;
}

String _estateAndDeviceHeader(String estateId, String deviceId) {
  if ((estateId == '') && (deviceId == '')) {
    return '';
  }
  String estateName = (estateId == '') ? '' : _estateName(estateId);
  String deviceNameAddition = (deviceId == '') ? '' : '/${_deviceName(deviceId)}';
  return '$estateName$deviceNameAddition:';
}

Events events = Events();

Widget showEvent(TrendEvent trendEvent) {
  try {
    return Container(
        margin: myContainerMargin,
        padding: myContainerPadding,
        child: InputDecorator(
            decoration: InputDecoration(labelText: timestampToDateTimeString(trendEvent.timestamp)),
            textAlignVertical: TextAlignVertical.top,
            child:
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget> [
                  Text('${_estateAndDeviceHeader(trendEvent.estateId, trendEvent.deviceId)}${_observationLevelText(trendEvent.observationLevel)} ${trendEvent.text}')
                ]
            )
        )
    );
  }
  catch (e, st) {
    log.error('Unvalid trendEvent', e, st);
    return Text('Sisäinen virhe tietojen tulostuksessa');
  }

}

String _observationLevelText(ObservationLevel observationLevel) {
  return (observationLevel == ObservationLevel.alarm) ? '[HÄLYTYS]' :
  (observationLevel == ObservationLevel.warning) ? '[varoitus]' : '';
}

