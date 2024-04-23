
import 'package:flutter/material.dart';

import 'package:koti/logic/temperature.dart';

class Environment extends ChangeNotifier {
  String _name = '';
  Temperature temperature = Temperature();

  List<Environment> _environments = [];

  String get name {
    return _name;
  }

  set name(String newValue) {
    _name = newValue;
  }

  void addEnvironment(Environment environment) {
    _environments.add(environment);
  }

  int nbrOfSubEnvironments() {
    return _environments.length;
  }
}