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

}

enum StateModel {notInstalled, notConnected, active }