import '../../interfaces/network_connectivity.dart';
import '../../logic/my_change_notifier.dart';
import '../wlan/active_wifi_name.dart';
import 'device.dart';
import 'package:koti/look_and_feel.dart';

const String stateDependantOnWifi = '#wifiDependant#';
const String stateDependantOnIP = '#ipDependant#';


class StateNotifier extends MyChangeNotifier<StateModel> {
  StateNotifier(super.initData);
}

class DeviceState {
  StateNotifier _state = StateNotifier(StateModel.notInstalled);
  String _dependency = '';
  dynamic listenerKey;

  // late ActiveWifiBroadcaster _myWifiBroadcaster;

  StateNotifier stateNotifier() {
    return _state;
  }
  DeviceState clone() {
    DeviceState clone = DeviceState();
    clone.setState(_state.data);
    return clone;
  }

  void defineDependency(String dependency, String myName) {
    log.debug('defineDependency: $dependency / $myName');
    if (listenerKey != null) {
      dispose();
    }

    _dependency = dependency;
    if (dependency == stateDependantOnWifi) {
        //_myWifiBroadcaster = activeWifiBroadcaster;
        //_state.data = (myName == activeWifiBroadcaster.wifiName())
        _state.data = (myName == activeWifi.name)
            ? StateModel.connected
            : StateModel.notConnected;
        log.debug('state is ${_state.data}');
        listenerKey = activeWifi.broadcastStream.listen(
          (String currentWifiName) {
            StateModel newState = (currentWifiName == myName)
                ? StateModel.connected
                : StateModel.notConnected;
            log.debug('wifi listener - old state is ${_state.data}, new state is $newState');
            listenForDependency(newState);
          }
        );
    }
    else if (dependency == stateDependantOnIP) {
      _state.data = ipNetworkState.data;
      listenerKey = ipNetworkState.setListener(listenForDependency);
    }
    else {
      Device dependencyDevice = allDevices.findDevice(dependency);
      if (dependencyDevice == noDevice) {
        log.error(': dependancy device $dependency not found');
      }
      else {
        _state.data = dependencyDevice.state.connected() ? StateModel.connected : StateModel.notConnected;
        listenerKey = dependencyDevice.state.setListener(listenForDependency);
      }
    }
  }

  void dispose() {
    if (_dependency == stateDependantOnWifi) {
      // remove listening for wifi
      listenerKey.cancel();
    }
    else if (_dependency == stateDependantOnIP) {
      ipNetworkState.cancelListening(listenerKey);
    }
    else if (_dependency != '') {
      Device dependencyDevice = allDevices.findDevice(_dependency);
      if (dependencyDevice != noDevice) {
        dependencyDevice.state.cancelListening(listenerKey);
      }
    }
  }

  void listenForDependency(StateModel state) {
    if (state != _state.data) {
      _state.data = state;
    }
  }

  // return a key that can be used to cancel the listening
  dynamic setListener(Function(StateModel) listeningFunction) {
    return _state.setListener(listeningFunction) as dynamic;
  }

  void cancelListening(dynamic key) {
    _state.cancelListening(key);
  }

  void setState(StateModel newState) {
    _state.data = newState;
  }

  StateModel currentState() {
    return _state.data;
  }

  bool connected() {
    return _state.data == StateModel.connected;
  }

  void setConnected() {
    setState(StateModel.connected);
  }

  String stateText() => _state.data.text();
}

enum StateModel {
  notInstalled,
  notConnected,
  connected;
  List<String> textOptions() =>
      ['ei ole asennettu', 'ei ole yhdistetty', 'yhdistetty'];
  String text() => textOptions()[index];
}