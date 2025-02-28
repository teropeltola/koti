
class AtaDevice {
  static const String OPERATION_MODE_HEAT = 'heat';
  static const String OPERATION_MODE_DRY = 'dry';
  static const String OPERATION_MODE_COOL = 'cool';
  static const String OPERATION_MODE_FAN_ONLY = 'fan_only';
  static const String OPERATION_MODE_HEAT_COOL = 'heat_cool';
  static const String OPERATION_MODE_UNDEFINED = 'undefined';

  static const String FAN_SPEED_AUTO = 'auto';

  static const String V_VANE_POSITION_AUTO = 'auto';
  static const String V_VANE_POSITION_1 = '1_up';
  static const String V_VANE_POSITION_2 = '2';
  static const String V_VANE_POSITION_3 = '3';
  static const String V_VANE_POSITION_4 = '4';
  static const String V_VANE_POSITION_5 = '5_down';
  static const String V_VANE_POSITION_SWING = 'swing';
  static const String V_VANE_POSITION_UNDEFINED = 'undefined';

  static const String H_VANE_POSITION_AUTO = 'auto';
  static const String H_VANE_POSITION_1 = '1_left';
  static const String H_VANE_POSITION_2 = '2';
  static const String H_VANE_POSITION_3 = '3';
  static const String H_VANE_POSITION_4 = '4';
  static const String H_VANE_POSITION_5 = '5_right';
  static const String H_VANE_POSITION_SPLIT = 'split';
  static const String H_VANE_POSITION_SWING = 'swing';
  static const String H_VANE_POSITION_UNDEFINED = 'undefined';

  AtaDevice(Map<String, dynamic> deviceConf, Client client,
      {Duration setDebounce = const Duration(seconds: 1)}) {
    // Initialize ATA device
  }

  // Apply writes to state object
  void applyWrite(Map<String, dynamic> state, String key, dynamic value) {
    // Your implementation here
  }

  bool get hasEnergyConsumedMeter {
    // Return true if the device has an energy consumption meter
    return false; // Change this to your implementation
  }

  double? get totalEnergyConsumed {
    // Return total consumed energy as kWh
    return null; // Change this to your implementation
  }

  double? get roomTemperature {
    // Return room temperature reported by the device
    return null; // Change this to your implementation
  }

  double? get targetTemperature {
    // Return target temperature set for the device
    return null; // Change this to your implementation
  }

  double get targetTemperatureStep {
    // Return target temperature set precision
    return 0.0; // Change this to your implementation
  }

  double? get targetTemperatureMin {
    // Return maximum target temperature for the currently active operation mode
    return null; // Change this to your implementation
  }

  double? get targetTemperatureMax {
    // Return maximum target temperature for the currently active operation mode
    return null; // Change this to your implementation
  }

  String get operationMode {
    // Return currently active operation mode
    return OPERATION_MODE_UNDEFINED; // Change this to your implementation
  }

  List<String> get operationModes {
    // Return available operation modes
    return []; // Change this to your implementation
  }

  String? get fanSpeed {
    // Return currently active fan speed
    return null; // Change this to your implementation
  }

  List<String>? get fanSpeeds {
    // Return available fan speeds
    return null; // Change this to your implementation
  }

  String? get vaneHorizontal {
    // Return horizontal vane position
    return null; // Change this to your implementation
  }

  List<String>? get vaneHorizontalPositions {
    // Return available horizontal vane positions
    return null; // Change this to your implementation
  }

  String? get vaneVertical {
    // Return vertical vane position
    return null; // Change this to your implementation
  }

  List<String>? get vaneVerticalPositions {
    // Return available vertical vane positions
    return null; // Change this to your implementation
  }

  String? get actualFanSpeed {
    // Return actual fan speed
    return null; // Change this to your implementation
  }
}

class Client {}

void main() {
  // Example usage:
  final deviceConf = <String, dynamic>{};
  final client = Client();
  final ataDevice = AtaDevice(deviceConf, client);
}
