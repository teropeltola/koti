
import 'package:koti/logic/my_permanent_variable.dart';

class DropdownContent {

  List <String> _dropdownOptions = [];
  late MyPermanentVariable<int> _current;

  DropdownContent.empty();

  DropdownContent(List <String> initOptions, String variableName, int initValue) {
    init(initOptions, variableName, initValue);
  }

  void init(List <String> initOptions, String variableName, int initValue) {
    _dropdownOptions = initOptions;

    _current = MyPermanentVariable<int>(variableName,initValue);

    if ((_current.value() < 0) || (_current.value() >= initOptions.length)) {
      _current.set(0);
    }
  }

  String permanentId() {
    return _current.variableName();
  }

  setIndex(int newValue) {

    if ((newValue >= 0) && (newValue < _dropdownOptions.length)) {
      _current.set(newValue);
    }
  }

  String getValue(int index) {

    if ((index < 0) || (index >= _dropdownOptions.length)) {
      return '';
    }
    else {
      return _dropdownOptions[index];
    }
  }

  String currentString() {
    return getValue(_current.value());
  }

  int currentIndex() {
    return _current.value();
  }

  List <String> options() {
    return _dropdownOptions;
  }

  int optionIndex(String optionText) {
    for (int i=0; i<_dropdownOptions.length; i++) {
      if (_dropdownOptions[i] == optionText) {
        return i;
      }
    }
    return -1;
  }
}