import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../look_and_feel.dart';

enum ObservationLevel {
  ok (description: 'Everything is ok with this observation'),
  informatic (description: 'Something worth of informing in the log is happening'),
  warning (description: 'User should be warned - but not immediate action needed'),
  alarm (description: 'User should be alarmed for immediate action');

  const ObservationLevel({
    required this.description,
  });
  final String description;

  static ObservationLevel? fromString(String name) => ObservationLevel.values.asNameMap()[name];
  bool isLessSerious(ObservationLevel newLevel) => this.index < newLevel.index;
}


class ObservationLogItem {
  late DateTime startDateTime;
  late DateTime endDateTime;
  late ObservationLevel observationLevel;

  ObservationLogItem(DateTime newDateTime, ObservationLevel newObservationLevel) {
    startDateTime = newDateTime;
    endDateTime = newDateTime;
    observationLevel = newObservationLevel;
  }
}

class ObservationLog {
  List<ObservationLogItem> log = [];

  bool add(ObservationLogItem logItem) {
    if ((log.isEmpty) || (log.last.observationLevel != logItem.observationLevel)) {
      log.add(logItem);
      return true;
    }
    else {
      log.last.endDateTime = logItem.startDateTime;
      return false;
    }
  }

  ObservationLevel currentLevel() {
    if (log.isEmpty) {
      return ObservationLevel.ok;
    }
    else {
      return log.last.observationLevel;
    }
  }

  ObservationLevel previousLevel() {
    if (log.length < 2) {
      return ObservationLevel.ok;
    }
    else {
      return log[log.length-2].observationLevel;
    }
  }
}

class ObservationMonitor extends ChangeNotifier {

  ObservationLog _oLog = ObservationLog();
  String name = '';

  ObservationLevel currentLevel() => _oLog.currentLevel();
  ObservationLevel previousLevel() => _oLog.previousLevel();

  void removeAlarm() {

  }
  void removeWarning() {

  }
  void setAlarm() {

  }
  void setWarning() {

  }

  void add(ObservationLogItem logItem) {
    bool changeHappened = _oLog.add(logItem);
    if (changeHappened) {
      ObservationLevel prev = previousLevel();
      ObservationLevel curr = currentLevel();
      if (prev.name != curr.name) {
        log.info('observation level of $name changed from ${prev.name} to ${curr
            .name}');
      }
      if (prev == ObservationLevel.alarm) {
          removeAlarm();
      }
      else if (prev == ObservationLevel.warning) {
        removeWarning();
      }
      switch (curr) {
        case ObservationLevel.ok: {
          break;
        }
        case ObservationLevel.informatic: {
          break;
        }
        case ObservationLevel.warning: {
          setWarning();
          break;
        }
        case ObservationLevel.alarm: {
          setAlarm();
          break;
        }
        default: {
          log.error('ObservationLevel is wrong in log writing');
        }
      }
      notifyListeners();
    }
  }
}

class Observations extends ChangeNotifier {
  List<ObservationMonitor> obsList = [];

  void add(ObservationMonitor observationMonitor) {
    obsList.add(observationMonitor);
    //   observationMonitor.setListener();
  }

  void listenAll() {

  }

  ObservationLevel sumObservationLevel() {
    int obsLevelIndex = 0;
    for (int i=0; i<obsList.length; i++) {
      int nextObsLevelIndex = obsList[i].currentLevel().index;
      if (nextObsLevelIndex > obsLevelIndex) {
        obsLevelIndex = nextObsLevelIndex;
      }
    }
    return ObservationLevel.values[obsLevelIndex];
  }
}

Observations observations = Observations();