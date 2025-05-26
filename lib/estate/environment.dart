
import 'package:flutter/material.dart';

import 'package:koti/logic/temperature.dart';

import '../functionalities/functionality/functionality.dart';
import '../functionalities/functionality/view/functionality_view.dart';
import '../logic/unique_id.dart';
import '../look_and_feel.dart';
import '../operation_modes/conditional_operation_modes.dart';
import '../operation_modes/hierarcical_operation_mode.dart';
import '../operation_modes/operation_modes.dart';
import 'estate.dart';


void _setOperationModeOn(Map<String, dynamic> parameters) {
  log.info('Environment set operation parameters ${parameters.toString()}');
}

Map<String, dynamic> _getParameters() {
  return {};
}

class Environment extends ChangeNotifier {
  String id = '';
  String _name = '';
  // Temperature temperature = Temperature();

  List <Functionality> features = [];
  List <FunctionalityView> views = [];

  OperationModes operationModes = OperationModes();

  final List<Environment> environments = [];

  Environment? parentEnvironment;

  Environment() {
    id = UniqueId('e').get();
  }

  String get name {
    return _name;
  }

  set name(String newValue) {
    _name = newValue;
  }

  bool hasParent() {
    return parentEnvironment != null;
  }

  void initOperationModes() {
    operationModes.initModeStructure(
        environment: this,
        parameterSettingFunctionName: estateOperationParameterSettingFunction,
        deviceId: '',
        deviceAttributes: [],
        setFunction: _setOperationModeOn,
        getFunction: _getParameters);

    operationModes.addType(HierarchicalOperationMode().typeName());
    operationModes.addType(ConditionalOperationModes().typeName());

    for (var e in environments) {
      e.initOperationModes();
    }
  }

  // connects the functionalities to the devices in the environment tree
  void connectFunctionalitiesToDevices() {

    for (var f in features) {
      for (var d in f.connectedDevices) {
        d.connectedFunctionalities.add(f);
      }
    }
    for (var e in environments) {
      e.connectFunctionalitiesToDevices();
    }
  }

  // inits the functionalities in the environment tree
  Future <void> initFunctionalities() async {
    for (var f in features) {
      await f.init();
    }
    for (var e in environments) {
      await e.initFunctionalities();
    }
  }


  Environment findEnvironmentId(String id) {
    if (this.id == id) {
      return this;
    }
    for (var e in environments) {
      Environment found = e.findEnvironmentId(id);
      if (found != noEnvironment) {
        return found;
      }
    }
    return noEnvironment;
  }


  Environment findEnvironmentFor(Functionality functionality) {
    for (var f in features) {
      if (f == functionality) {
        return this;
      }
    }
    for (var e in environments) {
      Environment found = e.findEnvironmentFor(functionality);
      if (found != noEnvironment) {
        return found;
      }
    }
    return noEnvironment;
  }

  Estate myEstate() {
    if (hasParent()) {
      // recursively find the root of the tree
      return parentEnvironment!.myEstate();
    }
    else {
      return this as Estate;
    }
  }

  void addSubEnvironment(Environment environment) {
    environments.add(environment);
    environment.parentEnvironment = this;
  }

  void removeSubEnvironment(Environment environment) {
    environments.remove(environment);
  }

  void removeEnvironment() {
    if (parentEnvironment != null) {
      parentEnvironment!.removeSubEnvironment(this);
    }
  }

  int nbrOfSubEnvironments() {
    return environments.length;
  }

  void addFunctionality(Functionality newFunctionality) {

    allFunctionalities.addFunctionality(newFunctionality);
    features.add(newFunctionality);
    addView(newFunctionality.myView);
  }

  void addView(FunctionalityView newFunctionalityView) {
    views.add(newFunctionalityView);
  }

  void _removeView(String functionalityId) {
    views.removeWhere((e)=>e.myFunctionality().id == functionalityId);
  }

  void removeFunctionality(Functionality functionality) {

    _removeView(functionality.id);
    int index = _functionalityIndex(functionality.id);
    if (index >= 0) {
      features.removeAt(index);
    }
    else {
      log.error('Environment.removeFunctionality ${functionality.id} not found');
    }
  }

  int _functionalityIndex(String id) {
    return features.indexWhere((e)=>e.id == id);
  }

  Functionality functionality(String functionalityId) {
    for (var f in features) {
      if (f.id == functionalityId) {
        return f  ;
      }
    }
    for (var e in environments) {
      Functionality found = e.functionality(functionalityId);
      if (found != allFunctionalities.noFunctionality()) {
        return found;
      }
    }
    return allFunctionalities.noFunctionality();
  }

  List<String> operationModeNames() {
    List<String> names = operationModes.operationModeNames();
    for (var e in features) {
      names += e.operationModes.operationModeNames();
    }
    names.sort();
    return names;
  }

  void removeData(){

    for (var e in environments) {
      e.removeData();
    }

    environments.clear();

    for (var f in features) {
      f.remove();
    }

    features.clear();

    operationModes.clear();
  }

  Environment clone() {
    Environment newEnvironment = Environment.fromJson(toJson());
    newEnvironment.parentEnvironment = parentEnvironment;
    return newEnvironment;
  }

  // note: estate has duplicate code because of the device initialization order
  Environment.fromJson(Map<String, dynamic> json){
    name = json['name'] ?? '';
    id = json['id'] ?? '';

    for (var e in json['subEnvironments'] ?? [] ) {
      environments.add(Environment.fromJson(e));
      environments.last.parentEnvironment = this;
    }

    features = List.from(json['features']).map((e)=>extendedFunctionalityFromJson(e)).toList();
    for (var f in features) {
      addView(f.myView);
    }
    operationModes = OperationModes.fromJson(json['operationModes'] ?? {});
  }

  Map<String, dynamic> toJson() {

    final json = <String, dynamic>{};

    json['name'] = name;
    json['id'] = id;
    json['subEnvironments'] = environments.map((e)=>e.toJson()).toList();
    json['features'] = features.map((e)=>e.toJson()).toList();
    json['operationModes'] = operationModes.toJson();

    return json;
  }

}

Environment noEnvironment = Environment();