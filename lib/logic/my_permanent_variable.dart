import 'package:flutter_settings_screens/flutter_settings_screens.dart';

//import 'observation_category.dart';

class MyPermanentVariable <T> {
  late String _variableName;
  late T _value;

  MyPermanentVariable(String variableName, T defaultValue) {
    init(variableName, defaultValue);
  }

  void init(String variableName, T defaultValue) {
    _variableName = variableName;
    if (_variableName == '') {
      _value = defaultValue;
    }
    else {
      _value = Settings.getValue<T>(variableName, defaultValue:defaultValue) ?? defaultValue;
    }
  }

  T value() {
    return _value;
  }

  // set this can be called with or without waiting
  void set(T newValue) async {

    bool updatePermanentStorage = (_variableName != '') && (newValue != _value);

    _value = newValue;

    if (updatePermanentStorage) {
      await Settings.setValue(_variableName,newValue);
    }
  }

  String variableName() {
    return _variableName;
  }
}
/*
class PermanentObservationCategory {
  late MyPermanentVariable<int> _variable;

  PermanentObservationCategory(String variableName, ObservationCategory defaultValue) {
    _variable = MyPermanentVariable(variableName, defaultValue.index);
  }

  ObservationCategory value() {
    return ObservationCategory.values[_variable.value()];
  }

  void set(ObservationCategory newValue) async {
    _variable.set(newValue.index);
  }

  bool equals(ObservationCategory obs) {
    return value() == obs;
  }

}
*/

