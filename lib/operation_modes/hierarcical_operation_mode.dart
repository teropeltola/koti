import 'package:koti/functionalities/functionality/functionality.dart';

import '../estate/environment.dart';
import '../estate/estate.dart';
import '../logic/device_attribute_control.dart';
import 'operation_modes.dart';
import '../../../look_and_feel.dart';

class IdAndOperationMode {
  late String id;
  late String operationName;

  IdAndOperationMode(this.id, this.operationName);

  IdAndOperationMode fromJson(Map<String, dynamic> json) {
    IdAndOperationMode f = IdAndOperationMode.fromJson(json);
    return f;
  }
  IdAndOperationMode.fromJson(Map<String, dynamic> json){
    id = json['functionalityId'] ?? '';
    operationName = json['operationName'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['functionalityId'] = id;
    json['operationName'] = operationName;

    return json;
  }
}

class HierarchicalOperationMode extends OperationMode {

  List <IdAndOperationMode> items = [];

  HierarchicalOperationMode();

  void add(String functionalityName, String operationName) {
    int existingIndex = items.indexWhere((item) =>
                          item.id == functionalityName);
    if (existingIndex >= 0) {
      items[existingIndex].operationName = operationName;
    }
    else {
      items.add(
          IdAndOperationMode(functionalityName, operationName));
    }
  }

  String operationCode(String functionalityId) {
    int existingIndex = items.indexWhere((item) =>
                          item.id == functionalityId);
    if (existingIndex < 0) {
      return '';
    }
    else {
      return items[existingIndex].operationName;
    }

  }

  @override select(ControlledDevice controlledDevice, OperationModes? parentOperationModes) async {
    log.info('Koostevalinta "$name"');
    for (var item in items) {
      // first check if the operationMode is from environment
      var environment = myEstates.currentEstate().findEnvironmentId(item.id);
      if (environment != noEnvironment) {
        environment.operationModes.selectNameAndSetParentInfo(item.operationName, parentOperationModes!);
      }
      else {
        // secondly check the possible functionalities
        var functionality = myEstates.currentEstate().functionality(item.id);
        if (functionality == allFunctionalities.noFunctionality()) {
          log.error('Hierarchical selection failure: id "${item.id}" was not found');
        }
        else {
          functionality.operationModes.selectNameAndSetParentInfo(
              item.operationName, parentOperationModes!);
        }
      }
    }
  }

  @override
  OperationMode clone() {
    return HierarchicalOperationMode.fromJson(toJson());
  }

  @override
  HierarchicalOperationMode.fromJson(Map<String, dynamic> json): super.fromJson(json) {

    items = List.from(json['items']).map((e)=>IdAndOperationMode.fromJson(e)).toList();
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    json['items'] = items.map((e)=>e.toJson()).toList();

    return json;
  }

  @override
  String typeName() {
    return 'Hierarkkinen';
  }
}
