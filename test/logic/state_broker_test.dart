import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:koti/look_and_feel.dart';

import 'package:koti/devices/device/device.dart';
import 'package:koti/logic/state_broker.dart';
void main() {
  group('Basic functionality', () {

    test('StateWithDoubleLimits', () {
      StateWithDoubleLimits s = StateWithDoubleLimits('name', 4.0, 10.0);
      expect(s.withinLimits(4.0), true);
      expect(s.withinLimits(10.0), true);
      expect(s.withinLimits(10.1), false);
      expect(s.withinLimits(3.9), false);

      expect(log.history.isEmpty, true);
      s = StateWithDoubleLimits('name', 4.1, 4.0);
      expect(log.history.isEmpty, false);
      expect(log.history.last.message!.contains('"low" cant bigger than "high"'), true);

    });
    test('StateFollower', () async {
      String _currentState = "";
      String _oldState = "";

      StateFollower s = StateFollower( [
        StateWithDoubleLimits('hot', 23.0, 100.0),
        StateWithDoubleLimits('cold', -50.0, 23.0),
      ],
          ({required String newState, required String oldState}) {
            _currentState = newState;
            _oldState = oldState;
          });

      s.checkDoubleStateChange(25.0);
      expect(_currentState, 'hot');
      expect(_oldState, unknownState);
      s.checkDoubleStateChange(-49.0);
      expect(_currentState, 'cold');
      expect(_oldState, 'hot');
      s.checkDoubleStateChange(-51.0);
      expect(_currentState, unknownState);
      expect(_oldState, 'cold');

    });

    test('StateInformer', () async {
      double myValue = 0.0;
      String myState = 'xx';

      StateInformer s = StateInformer(Device(), 'name', 1, ()=>myValue, null);
      // 1 minute poll time
      await _waitMinutes(1);
      s.addFollower( [
          StateWithDoubleLimits('hot', 23.0, 100.0),
          StateWithDoubleLimits('cold', -50.0, 23.0),
        ],
        ({required String newState, required String oldState}){myState = newState;}
      );
      await _waitMinutes(1);
      expect(myState, 'cold');
      myValue = 30.0;
      await _waitMinutes(1);
      expect(myState, 'hot');
    });



    test('Empty Broker', () async {
      StateBroker stateBroker = StateBroker();
      Device device = Device();
      log.cleanHistory();
      expect(stateBroker.getDoubleValue('temperature'), stateBrokerServiceNotFound);
      expect(log.history.isEmpty, false);
      expect(log.history.last.message!.contains('getDoubleValue(temperature)'), true);
      expect(stateBroker.getBoolValue('temperature'), false);
      expect(log.history.last.message!.contains('getBoolValue(temperature)'), true);
    });

    test('InitStateInformer', () async {
      StateBroker stateBroker = StateBroker();
      Device device = Device();

      stateBroker.initPollingStateInformer(
          device: device,
          serviceName: 'temperature',
          pollFrequencyInMinutes: 10,
          infoType: InfoType.double,
          dataReadingFunction: ()=>2.0);

      expect(stateBroker.getDoubleValue('temperature'), 2.0);

      stateBroker.initPollingStateInformer(
          device: device,
          serviceName: 'status',
          pollFrequencyInMinutes: 5,
          infoType: InfoType.bool,
          dataReadingFunction: ()=>true);

      expect(stateBroker.getBoolValue('status'), true);

    });
  });
}

Future <void> _waitMinutes(int minutes) async {
  await Future.delayed(Duration(minutes:minutes));
}
