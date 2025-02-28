import 'package:flutter_test/flutter_test.dart';
import 'package:koti/logic/observation.dart';
import 'package:koti/look_and_feel.dart'; // Change this to the correct import path

void main() {
  group('ObservationLevel tests', () {
    test('ObservationLevel instantiation', () {
      expect(ObservationLevel.ok.description, 'Everything is ok with this observation');
      expect(ObservationLevel.informatic.description, 'Something worth of informing in the log is happening');
      expect(ObservationLevel.warning.description, 'User should be warned - but not immediate action needed');
      expect(ObservationLevel.alarm.description, 'User should be alarmed for immediate action');
    });

    test('ObservationLevel fromString', () {
      expect(ObservationLevel.fromString('ok'), ObservationLevel.ok);
      expect(ObservationLevel.fromString('informatic'), ObservationLevel.informatic);
      expect(ObservationLevel.fromString('warning'), ObservationLevel.warning);
      expect(ObservationLevel.fromString('alarm'), ObservationLevel.alarm);
      expect(ObservationLevel.fromString('invalid'), isNull);
    });

    test('ObservationLevel isLessSerious', () {
      expect(ObservationLevel.ok.isLessSerious(ObservationLevel.informatic), isTrue);
      expect(ObservationLevel.warning.isLessSerious(ObservationLevel.alarm), isTrue);
      expect(ObservationLevel.alarm.isLessSerious(ObservationLevel.warning), isFalse);
    });
  });

  group('ObservationLogItem tests', () {
    test('ObservationLogItem instantiation', () {
      DateTime now = DateTime.now();
      ObservationLevel level = ObservationLevel.warning;
      ObservationLogItem logItem = ObservationLogItem(now, level);

      expect(logItem.startDateTime, now);
      expect(logItem.endDateTime, now);
      expect(logItem.observationLevel, level);
    });
  });

  group('ObservationLog tests', () {
    test('ObservationLog add', () {
      ObservationLog testLog = ObservationLog();
      DateTime now = DateTime.now();
      ObservationLevel level = ObservationLevel.warning;
      ObservationLogItem logItem = ObservationLogItem(now, level);

      expect(testLog.add(logItem), isTrue);
      expect(testLog.log.length, 1);
      expect(testLog.log[0].startDateTime, now);
      expect(testLog.log[0].endDateTime, now);
      expect(testLog.log[0].observationLevel, level);

      // Test adding an item with the same level
      DateTime later = now.add(const Duration(minutes: 5));
      ObservationLogItem logItem2 = ObservationLogItem(later, level);
      expect(testLog.add(logItem2), isFalse);
      expect(testLog.log.length, 1);
      expect(testLog.log[0].startDateTime, now);
      expect(testLog.log[0].endDateTime, later);
      expect(testLog.log[0].observationLevel, level);

      // Test adding an item with a different level
      ObservationLevel newLevel = ObservationLevel.alarm;
      ObservationLogItem logItem3 = ObservationLogItem(now, newLevel);
      expect(testLog.add(logItem3), isTrue);
      expect(testLog.log.length, 2);
      expect(testLog.log[1].startDateTime, now);
      expect(testLog.log[1].endDateTime, now);
      expect(testLog.log[1].observationLevel, newLevel);
    });

    test('ObservationLog currentLevel', () {
      ObservationLog log = ObservationLog();
      expect(log.currentLevel(), ObservationLevel.ok);

      DateTime now = DateTime.now();
      ObservationLevel level = ObservationLevel.warning;
      ObservationLogItem logItem = ObservationLogItem(now, level);
      log.add(logItem);

      expect(log.currentLevel(), level);
    });

    test('ObservationLog previousLevel', () {
      ObservationLog testLog = ObservationLog();
      expect(testLog.previousLevel(), ObservationLevel.ok);

      DateTime now = DateTime.now();
      ObservationLevel level = ObservationLevel.warning;
      ObservationLogItem logItem = ObservationLogItem(now, level);
      testLog.add(logItem);

      expect(testLog.previousLevel(), ObservationLevel.ok);

      testLog.add(ObservationLogItem(now, ObservationLevel.alarm));

      expect(testLog.previousLevel(), ObservationLevel.warning);

    });
  });

  group('ObservationMonitor tests', () {
    test('ObservationMonitor add', () {
      ObservationMonitor monitor = ObservationMonitor();
      monitor.name = 'TestMonitor';

      DateTime now = DateTime.now();
      ObservationLevel level = ObservationLevel.warning;
      ObservationLogItem logItem = ObservationLogItem(now, level);

      expect(() => monitor.add(logItem), returnsNormally);
      expect(monitor.currentLevel(), level);
      String lastLog = log.history.last.message ?? '';
      expect(lastLog.contains('observation level of TestMonitor changed from ok to warning'), true);
    });
  });

  group('Observations tests', () {
    test('Observations add', () {
      Observations observations = Observations();

      DateTime now = DateTime.now();
      ObservationLevel level = ObservationLevel.warning;
      ObservationLogItem logItem = ObservationLogItem(now, level);

      ObservationMonitor monitor = ObservationMonitor();
      monitor.name = 'TestMonitor';
      monitor.add(logItem);

      expect(() => observations.add(monitor), returnsNormally);
      expect(observations.obsList.length, 1);
      expect(observations.sumObservationLevel(), level);
      String lastLog = log.history.last.message ?? '';
      expect(lastLog.contains('observation level of TestMonitor changed from ok to warning'), true);
    });
  });
}
