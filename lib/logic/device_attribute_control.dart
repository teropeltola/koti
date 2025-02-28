enum DeviceAttributeCapability { noCapability, directControl, timeControl, autonomous }
class DeviceLevelCapability {
  bool capability = false;
}

class DeviceAttributeControl {
  List<DeviceLevelCapability> levelCapability = List.filled(4,DeviceLevelCapability());

  void setCapability(DeviceAttributeCapability capability) {
    levelCapability[capability.index].capability = true;
  }

  bool hasCapability(DeviceAttributeCapability level) {
    return (levelCapability[level.index].capability);
  }
}

class ControlledDevice {
  String deviceId = '';
  DeviceAttributeControl attributes = DeviceAttributeControl();
  Function _externalGetValuesFunction = (){};
  Function _externalSetValuesFunction = () {};

  bool _dataNotInitialized = true;


  Map<String, dynamic> _setParameters = {};

  void initStructure( {required String deviceId, required List<DeviceAttributeCapability> deviceAttributes, required Function setFunction, required Function getFunction }) {
    this.deviceId = deviceId;
    for (var e in deviceAttributes) {
      attributes.setCapability(e);
    }
    _externalGetValuesFunction = getFunction;
    _externalSetValuesFunction = setFunction;
  }

  void _initializeData() {
    _setParameters = _externalGetValuesFunction();
    _dataNotInitialized = false;
  }

  bool valuesOn(Map<String, dynamic> parameters) {
    if (_dataNotInitialized) {
      _initializeData();
    }
    for (final entry in parameters.entries) {
      if (_setParameters[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  void setDirectValue(Map<String, dynamic> parameters) {
    if (attributes.hasCapability(DeviceAttributeCapability.directControl)) {
      if (!valuesOn(parameters)) {
        _externalSetValuesFunction(parameters);
        _setParameters = parameters;
      }
    }
  }
}

class ControlledDevices {
  List <DeviceAttributeControl> deviceAttributes = [];
}