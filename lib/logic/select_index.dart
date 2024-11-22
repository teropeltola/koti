import 'my_permanent_variable.dart';

const _currentIsNotValidIndicator = -1;

SelectIndex notSelected = SelectIndex('not selected');

class SelectIndex {


  MyPermanentVariable<int> _index = MyPermanentVariable<int>('',-1);
  SelectIndex? _setter;
  bool settingIsValid = false;

  SelectIndex? get setter => _setter;

  SelectIndex.empty();

  SelectIndex(String uniqueName) {
    _index = MyPermanentVariable<int>(uniqueName,_currentIsNotValidIndicator);
  }

  void setIndex(int newValue ) {
    _index.set(newValue);
    settingIsValid = true;

    if (_setter != null) {
      _setter!.invalidateSetting();
    }
  }

  void setIndexAndParentInfo(int newValue , SelectIndex  newSetter ) {
    _index.set(newValue);
    settingIsValid = true;
    _setter = newSetter;
  }

  void invalidateSetting() {
    settingIsValid = false;
  }

  int get() {
    return _index.value();
  }

  bool isValid() {
    return settingIsValid;
  }

  String id() {
    return _index.variableName();
  }
}