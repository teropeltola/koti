import 'package:flutter/material.dart';
import 'package:koti/trend/trend.dart';
import 'package:koti/trend/trend_event.dart';

import '../app_configurator.dart';
import '../devices/device/device.dart';
import '../estate/environment.dart';
import '../estate/estate.dart';
import 'observation.dart';
import '../look_and_feel.dart';

class Events {
  late TrendBox<TrendEvent> eventBox;

  Future<void> init() async {


    await trend.initBox<TrendEvent>(hiveTrendEventName);
    eventBox = trend.open(hiveTrendEventName);

  }

  void write(String environmentId, String deviceId,
      ObservationLevel observationLevel, String eventText) {
    eventBox.add(TrendEvent(
      DateTime.now().millisecondsSinceEpoch,
      environmentId,
      deviceId,
      observationLevel,
      eventText));

    if ((observationLevel == ObservationLevel.ok) || (observationLevel == ObservationLevel.informatic)) {
      log.info('${_estateAndDeviceHeader(environmentId, deviceId)} $eventText');
    }
    else if (observationLevel == ObservationLevel.warning) {
      log.warning('${_estateAndDeviceHeader(environmentId, deviceId)} $eventText');
    }
    else {
      log.error('${_estateAndDeviceHeader(environmentId, deviceId)} $eventText');
    }
  }

  List<TrendEvent> getAll() {
    return eventBox.getAll();
  }
}

String _environmentName(String estateId) {
  return myEstates.estateFromId(estateId).name;
}

String _deviceName(String deviceId) {
  Device d = allDevices.findDevice(deviceId);
  if (d == noDevice) {
    return '???';
  }
  return d.name;
}

String _estateAndDeviceHeader(String environmentId, String deviceId) {
  String estateEnvironmentName = '';
  if (environmentId == '') {
    if (deviceId == '') {
      return '';
    }
  }
  else {
    Environment environment = myEstates.environmentFromId(environmentId);
    if (environment.hasParent()) {
      estateEnvironmentName = '${environment
          .myEstate()
          .name}/${environment.name}';
    }
    else {
      estateEnvironmentName = environment.name;
    }
  }
  String deviceNameAddition = (deviceId == '') ? '' : '/${_deviceName(deviceId)}';

  return '$estateEnvironmentName$deviceNameAddition:';
}

Events events = Events();

Widget showEvent(TrendEvent trendEvent) {
  try {
    return Container(
        margin: myContainerMargin,
        padding: myContainerPadding,
        child: InputDecorator(
            decoration: InputDecoration(
                labelText: '${timestampToDateTimeString(
                      trendEvent.timestamp)}${_estateAndDeviceHeader(
                                              trendEvent.environmentId,
                                                  trendEvent.deviceId)}'),
            textAlignVertical: TextAlignVertical.top,
            child:
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget> [
                  Text('${_observationLevelText(trendEvent.observationLevel)} ${trendEvent.text}')
                ]
            )
        )
    );
  }
  catch (e, st) {
    log.error('Unvalid trendEvent', e, st);
    return const Text('Sisäinen virhe tietojen tulostuksessa');
  }

}

String _observationLevelText(ObservationLevel observationLevel) {
  return (observationLevel == ObservationLevel.alarm) ? '[HÄLYTYS]' :
  (observationLevel == ObservationLevel.warning) ? '[varoitus]' : '';
}

