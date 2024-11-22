import 'dart:async';
import 'package:flutter/material.dart';

import '../devices/device/device.dart';
import '../look_and_feel.dart';
import 'my_change_notifier.dart';

enum InfoType { double, bool }

const notifierInUse = -1;
const double stateBrokerServiceNotFound = noValueDouble;
const unknownState = '#tuntematon tila#';

const String anyDevice = '#AnyDeV1ce#';

class StateBoolNotifier extends MyChangeNotifier<bool> {
  StateBoolNotifier(super.initData);
}

class StateDoubleNotifier extends MyChangeNotifier<double> {
  StateDoubleNotifier(super.initData);

}

class StateDoubleListener extends BroadcastListener<double> {
}

class StateBoolListener extends BroadcastListener<bool> {
}

class StateInformer {
  Device device;
  String serviceName;
  int pollFrequencyInMinutes;

  StateDoubleListener stateDoubleListener = StateDoubleListener();
  StateBoolListener stateBoolListener = StateBoolListener();

  Function dataReadingFunction;

  List<StateFollower> followers = [];

  bool notifierUsed() {
    return pollFrequencyInMinutes == notifierInUse;
  }

  void _actionPerDoubleNotifier(double newValue) {
    for (var follower in followers) {
      follower.checkDoubleStateChange(newValue);
    }
  }

  void _actionPerBoolNotifier(bool newValue) {
    // TODO: not implemented - what should be informed with bool values at all?
  }

  StateInformer(this.device, this.serviceName, this.pollFrequencyInMinutes, this.dataReadingFunction, StateDoubleNotifier? initStateDoubleNotifier) {
    if (pollFrequencyInMinutes == notifierInUse) {
      stateDoubleListener.start(initStateDoubleNotifier!, _actionPerDoubleNotifier);
    }
    else { // polling in use
      Timer.periodic(Duration(minutes: pollFrequencyInMinutes), handleTimer);
    }
  }

  StateInformer.bool(this.device, this.serviceName, this.pollFrequencyInMinutes, this.dataReadingFunction, StateBoolNotifier? initStateBoolNotifier) {
    if (pollFrequencyInMinutes == notifierInUse) {
      stateBoolListener.start(initStateBoolNotifier!, _actionPerBoolNotifier);
    }
    else { // polling in use
      Timer.periodic(Duration(minutes: pollFrequencyInMinutes), handleTimer);
    }
  }

  void addFollower(List<StateWithDoubleLimits> myStates, Function stateChangeFunction) {
    followers.add(StateFollower(myStates, stateChangeFunction));
  }

  void handleTimer(Timer t) {
    double newValue = dataReadingFunction();
    for (var follower in followers) {
      follower.checkDoubleStateChange(newValue);
    }
  }

  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: '',
        textLines: [
          'Laite: ${device.name}',
          'Palvelu: ${serviceName}',
          notifierUsed() ? 'Tiedotus suoraan laitteelta' : 'kyselyväli: $pollFrequencyInMinutes minuuttia'
          'Seuraajien lukumäärä: ${followers.length}'
        ],
        widgets: [
          formatterWidget(
              headline: 'Seuraajat',
              textLines: [''
              ],
              widgets: [
                for (var follower in followers)
                  follower.dumpData(formatterWidget: formatterWidget)
              ]
          ) as Widget,

        ]
      //for (int i=0; i<nbrOfModes(); i++)
      //   _dumpOperationMode(getModeAt(i)),

    );
  }
}

class StateFollower {
  List<StateWithDoubleLimits> states;
  Function stateChangeFunction;
  String currentState = unknownState;

  StateFollower(this.states, this.stateChangeFunction);

  void _updateAndInformStateChange(String newState) {
    String oldState = currentState;
    currentState = newState;
    stateChangeFunction(newState: currentState, oldState: oldState);
  }

  void checkDoubleStateChange(double currentValue) {
    for (var state in states) {
      if (state.withinLimits(currentValue)) {
        if (currentState != state.stateName) {
          _updateAndInformStateChange(state.stateName);
        }
        return;
      }
    }
    // currentValue not fitting to defined limits => unknownState
    if (currentState != unknownState) {
      _updateAndInformStateChange(unknownState);
    }
  }

  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: 'vois olla joku nimiparametri',
        textLines: [
          'Tila: ${currentState}',
          'Tilaehtojen lukumäärä: ${states.length}'
        ],
        widgets: [
          formatterWidget(
              headline: 'Tilaehdot',
              textLines: [
                for (var state in states)
                  '${state.low}-${state.high}: ${state.stateName}',
              ],
              widgets: [
              ]
          ) as Widget,

        ]
      //for (int i=0; i<nbrOfModes(); i++)
      //   _dumpOperationMode(getModeAt(i)),

    );
  }

}

class StateWithDoubleLimits {
  String stateName;
  double low;
  double high;

  StateWithDoubleLimits(this.stateName, this.low, this.high) {
    if (low > high) {
      log.error('State($stateName): "low" cant bigger than "high"');
    }
  }

  bool withinLimits(double value) {
    return ((low <= value) && (value <= high));
  }
}

class StateBroker {

  List<StateInformer> doubleInformers = [];
  List<StateInformer> boolInformers = [];

  void initNotifyingDoubleStateInformer( {
    required Device device,
    required String serviceName,
    required StateDoubleNotifier stateDoubleNotifier,
    required Function dataReadingFunction }
  )
  {
    int index = doubleInformers.indexWhere((e)=>(e.serviceName==serviceName) && (device.id == e.device.id));
    if (index < 0) {
      // new state informer
      doubleInformers.add(StateInformer(
          device, serviceName, notifierInUse, dataReadingFunction,
          stateDoubleNotifier));
    }
    else {
      // update existing state informer
      doubleInformers[index] = StateInformer(
          device, serviceName, notifierInUse, dataReadingFunction,
          stateDoubleNotifier);
    }

  }

  void initNotifyingBoolStateInformer( {
    required Device device,
    required String serviceName,
    required StateBoolNotifier stateBoolNotifier,
    required Function dataReadingFunction }
      )
  {
    int index = boolInformers.indexWhere((e)=>(e.serviceName==serviceName) && (device.id == e.device.id));
    if (index < 0) {
      // new state informer
      boolInformers.add(StateInformer.bool(
          device, serviceName, notifierInUse, dataReadingFunction,
          stateBoolNotifier));
    }
    else {
      // update existing state informer
      boolInformers[index] = StateInformer.bool(
          device, serviceName, notifierInUse, dataReadingFunction,
          stateBoolNotifier);
    }

  }


  void initPollingStateInformer( {
    required Device device,
    required String serviceName,
    required InfoType infoType,
    required int pollFrequencyInMinutes,
    required Function dataReadingFunction }
  )
  {
    if (infoType == InfoType.double) {
      int index = doubleInformers.indexWhere((e)=>(e.serviceName==serviceName) && (device.id == e.device.id));
      if (index < 0) {
        // new state informer
        doubleInformers.add(StateInformer(device, serviceName, pollFrequencyInMinutes, dataReadingFunction, null ));
      }
      else {
        // update existing state informer
        doubleInformers[index] = StateInformer(
            device, serviceName,  pollFrequencyInMinutes, dataReadingFunction,
            null);
      }
    }
    else {
      int index = boolInformers.indexWhere((e)=>(e.serviceName==serviceName) && (device.id == e.device.id));
      if (index < 0) {
        // new state informer
        boolInformers.add(StateInformer(device, serviceName, pollFrequencyInMinutes, dataReadingFunction, null ));
      }
      else {
        // update existing state informer
        boolInformers[index] = StateInformer(
            device, serviceName,  pollFrequencyInMinutes, dataReadingFunction,
            null);
      }
    }
  }

  int _boolIndex(String serviceName, String deviceName) {
    if (deviceName == anyDevice) {
      return boolInformers.indexWhere((e) => e.serviceName == serviceName);
    }
    else {
      return boolInformers.indexWhere((e) => e.serviceName == serviceName &&
                                              deviceName == e.device.name);
    }
  }

  bool getBoolValue(String serviceName, String deviceName) {
    int index = _boolIndex(serviceName, deviceName);
    if (index >= 0) {
      return boolInformers[index].dataReadingFunction();
    }
    else {
      log.error('getBoolValue($serviceName): service not found');
      return false;
    }
  }

  double getDoubleValue(String serviceName) {
    int index = doubleInformers.indexWhere((e)=>e.serviceName==serviceName);
    if (index >= 0) {
      return doubleInformers[index].dataReadingFunction();
    }
    else {
      log.error('getDoubleValue($serviceName): service not found');
      return stateBrokerServiceNotFound;
    }
  }

  void getStateChange(String serviceName, List<StateWithDoubleLimits> myStates, Function stateChangeFunction) {
    int index = doubleInformers.indexWhere((e)=>e.serviceName==serviceName);
    if (index >= 0) {
      doubleInformers[index].addFollower(myStates, stateChangeFunction);
    }
    else {
      log.error('getDoubleValue($serviceName): service not found');
    }
  }

  void getBoolChange(String serviceName, Function stateChangeFunction) {

  }

  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: 'Informaatiolähteitä',
        textLines: [
          'Reaalilukutietojen lukumäärä: ${doubleInformers.length}',
          'Tosi/epätosi -tietojen lukumäärä: ${boolInformers.length}',
        ],
        widgets: [
          formatterWidget(
              headline: 'Reaalilukutietoja',
              textLines: [''
              ],
              widgets: [
                for (var informer in doubleInformers)
                  informer.dumpData(formatterWidget: formatterWidget)
              ]
          ) as Widget,
          formatterWidget(
              headline: 'on/off-tietoja',
              textLines: [''
              ],
              widgets: [
                for (var informer in boolInformers)
                  informer.dumpData(formatterWidget: formatterWidget)
              ]
          ) as Widget,

        ]
    );
  }


}