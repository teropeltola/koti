class DeviceState {
  StateModel _state = StateModel.notInstalled;

  DeviceState clone() {
    DeviceState clone = DeviceState();
    clone.setState(_state);
    return clone;
  }

  void setState(StateModel newState) {
    _state = newState;
  }

  StateModel currentState() {
    return _state;
  }

  bool connected() {
    return _state == StateModel.connected;
  }

  void setConnected() {
    _state = StateModel.connected;
  }
}

enum StateModel {notInstalled, notConnected, connected }