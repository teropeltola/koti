import 'package:flutter/cupertino.dart';
import 'package:koti/devices/my_device_info.dart';
import 'package:koti/logic/observation.dart';
import 'package:koti/trend/trend.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_test/flutter_test.dart';


void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  group('basic tests', () {
    test('Trend tests', () async {
      Trend trend = Trend();
      trend.testing = true;
      await trend.init();
      expect(trend.nbrOfBoxes(), 0);
      TrendBox<TrendData> myData = trend.open<TrendData> ('data');
      expect(trend.nbrOfBoxes(),1);
      myData.add(TrendData(DateTime(2024,12,4,10,0), 'e1', 'd1'));
      List<TrendData> data = myData.getAll();
      expect(data.length, 1);
      expect(data[0].deviceId,'d1');
    });

    test('TrendData constructors', () async {
      TrendData t1 = TrendData(DateTime(2024),'','');
      expect(t1.deviceId, '');

      TrendData t2 = TrendData(DateTime(2024,12,4,10,0), 'estateId', 'deviceId');
      expect(DateTime.fromMillisecondsSinceEpoch(t2.timestamp), DateTime(2024,12,4,10,0));
      expect(t2.estateId,'estateId');
      expect(t2.deviceId,'deviceId');

      TrendEvent t3 = TrendEvent(DateTime(2024,12,4,10,0), 'estateId', 'deviceId', ObservationLevel.alarm, 'myObs');
      expect(DateTime.fromMillisecondsSinceEpoch(t3.timestamp), DateTime(2024,12,4,10,0));
      expect(t3.estateId,'estateId');
      expect(t3.deviceId,'deviceId');
      expect(t3.observationLevelIndex, ObservationLevel.alarm.index);
    });

    test('TrendData routines', () async {
      Trend trend = Trend();
      trend.testing = true;
      await trend.init();
      TrendBox<TrendData> myData = trend.open<TrendData> ('data');

    });
  });
}
