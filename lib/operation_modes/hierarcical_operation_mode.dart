import 'package:koti/functionalities/functionality/functionality.dart';

import '../estate/estate.dart';
import '../logic/device_attribute_control.dart';
import '../main.dart';
import 'operation_modes.dart';
import '../../../look_and_feel.dart';

class FunctionalityAndOperationMode {
  late String functionalityId;
  late String operationName;

  FunctionalityAndOperationMode(this.functionalityId, this.operationName);

  FunctionalityAndOperationMode fromJson(Map<String, dynamic> json) {
    FunctionalityAndOperationMode f = FunctionalityAndOperationMode.fromJson(json);
    return f;
  }
  FunctionalityAndOperationMode.fromJson(Map<String, dynamic> json){
    functionalityId = json['functionalityId'] ?? '';
    operationName = json['operationName'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['functionalityId'] = functionalityId;
    json['operationName'] = operationName;

    return json;
  }
}

class HierarchicalOperationMode extends OperationMode {

  List <FunctionalityAndOperationMode> items = [];

  HierarchicalOperationMode();

  void add(String functionalityName, String operationName) {
    int existingIndex = items.indexWhere((item) =>
                          item.functionalityId == functionalityName);
    if (existingIndex >= 0) {
      items[existingIndex].operationName = operationName;
    }
    else {
      items.add(
          FunctionalityAndOperationMode(functionalityName, operationName));
    }
  }

  String operationCode(String functionalityId) {
    int existingIndex = items.indexWhere((item) =>
                          item.functionalityId == functionalityId);
    if (existingIndex < 0) {
      return '';
    }
    else {
      return items[existingIndex].operationName;
    }

  }

  @override select(ControlledDevice controlledDevice, OperationModes? parentOperationModes) async {
    log.info('Koostevalinta "$name"');
    for (int i=0; i<items.length; i++) {
      var functionality = myEstates.currentEstate().functionality(items[i].functionalityId);
      if (functionality == allFunctionalities.noFunctionality()) {
        log.error('Hierarchical selectation failure: functionality "${items[i].functionalityId} was not found');
      }
      else {
        functionality.operationModes.selectNameAndSetParentInfo(items[i].operationName, parentOperationModes!);
      }
    }
  }

  @override
  OperationMode clone() {
    return HierarchicalOperationMode.fromJson(toJson());
  }

  @override
  HierarchicalOperationMode.fromJson(Map<String, dynamic> json): super.fromJson(json) {

    items = List.from(json['items']).map((e)=>FunctionalityAndOperationMode.fromJson(e)).toList();
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
