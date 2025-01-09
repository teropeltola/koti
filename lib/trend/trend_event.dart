import 'package:hive/hive.dart';
import 'package:koti/trend/trend.dart';

import '../app_configurator.dart';
import '../logic/observation.dart';

part 'trend_event.g.dart';

@HiveType(typeId: hiveTypeTrendEvent)
class TrendEvent extends TrendData {
  @HiveField(3)
  ObservationLevel observationLevel = ObservationLevel.informatic;
  @HiveField(4)
  String text = '';

  TrendEvent(int timestamp,
      String estateId,
      String deviceId,
      ObservationLevel initObservationLevel,
      String observationText) :
        super(timestamp, estateId, deviceId) {
    observationLevel = initObservationLevel;
    text = observationText;
  }
  /*
  TrendObservation(DateTime dateTime,
      String estateId,
      String deviceId,
      ObservationLevel observationLevel,
      String observationText) :
        super(dateTime, estateId, deviceId) {
    observationLevelIndex = observationLevel.index;
    text = observationText;
  }
*/
  @override
  String hiveName() {
    return hiveTrendEventName;
  }
}
