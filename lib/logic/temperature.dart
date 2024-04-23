import '../devices/device/device.dart';


class Temperature {
  double _targetTemperature = temperatureNotAvailable;
  Device _device = Device();

  Temperature();

  double get value {
    return _device.temperatureFunction();
  }

  double get target {
    return _targetTemperature;
  }

  set target(double newTarget) {
    _targetTemperature = newTarget;
  }

  void setSource(Device device) {
    _device = device;
  }

  bool hasTarget() {
    return _targetTemperature != temperatureNotAvailable;
  }

  bool belowTarget() {
    if ((value == temperatureNotAvailable) || !hasTarget()) {
      return false;
    }
    return value < _targetTemperature;
  }

  bool overTarget() {
    if ((value == temperatureNotAvailable) || !hasTarget()) {
      return false;
    }
    return value > _targetTemperature;
  }

  void fromJson(Map<String, dynamic> json){
    _device = findDevice(json['deviceId'] ?? '');
    _targetTemperature = json['target'] ?? temperatureNotAvailable;
  }

  Temperature.fromJson(Map<String, dynamic> json){
    fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['deviceId'] = _device.id;
    if (hasTarget()) {
      json['target'] = _targetTemperature;
    }

    return json;
  }


}