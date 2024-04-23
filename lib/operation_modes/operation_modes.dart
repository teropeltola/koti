
import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';

import '../functionalities/electricity_price/electricity_price.dart';
import '../look_and_feel.dart';

class OperationMode {
  String _name;
  Map<String, dynamic> parameters = {};
  final Function _selectFunction;
  OperationMode(this._name, this._selectFunction);

  String get name => _name;
  set name(String newName) => _name = newName;


  Future<void> select() async {
    await _selectFunction();
  }

}

OperationMode noOperationMode = OperationMode('',(){});

class OperationModeType {
  String name = '';
  Map<String,dynamic> parameters = {};

}

class OperationModeTypes {
  List<OperationModeType> _types = [];

  List<String> alternatives() {
    List<String> list = [];
    _types.forEach((e)=>list.add(e.name));
    return list;
  }

  void add(String name) {
    OperationModeType o = OperationModeType();
    o.name = name;
    _types.add(o);
  }
}

class OperationModes {

  List <OperationMode> _modes = [];
  int _currentIndex = -1;
  OperationModeTypes types = OperationModeTypes();

  int currentIndex() {
    return _currentIndex;
  }

  OperationMode current() {
    return (_modes.isEmpty ? noOperationMode : _modes[_currentIndex]);
  }

  String currentModeName() {
    return  (_modes.isEmpty ? '' : _modes[_currentIndex].name);
  }

  bool newNameOK(String newName) {
    if (newName == '') {
      return false;
    }
    for (int i=0; i<_modes.length; i++) {
      if (newName == _modes[i].name) {
        return false;
      }
    }
    return true;
  }

  int findName(String name) {
    return _modes.indexWhere((e)=>e.name == name);
  }

  String modeName(int index) {
    return _modes[index].name;
  }

  Future<void> selectIndex(int index) async {
    await _modes[index].select();
    _currentIndex = index;
  }
  Future<void> select(String name) async {
    int index = findName(name);
    if (index == -1) {
      log.error('OperationModes select: removed item not found');
    }
    else {
      await selectIndex(index);
    }
  }

  void add(String name, Function selectFunction) {
    _modes.add(OperationMode(name, selectFunction));
  }

  // if the removed is the current then the next current is random (-1)
  // if the last item deleted then the current will be old-1
  void remove(String name) {
    int removeIndex = findName(name);
    if (removeIndex == -1) {
      log.error('OperationModes remove: removed item not found');
    }
    else {
      _modes.removeAt(removeIndex);
      if (_currentIndex >= removeIndex) {
        // note: works also with the last item.
        _currentIndex--;
      }
    }
  }

  int nbrOfModes() {
    return _modes.length;
  }

  List <String> operationModeNames() {
    List <String> names = [];
    for (int i=0; i<_modes.length; i++) {
      names.add(_modes[i].name);
    }
    return names;
  }

  OperationMode getMode(String name) {
    int index = findName(name);
    if (index < 0)  {
      return noOperationMode;
    }
    else {
      return _modes[index];
    }
  }

  void addType(String name) {
      types.add(name);
  }

}

