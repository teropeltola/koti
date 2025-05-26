import 'package:flutter/material.dart';

import 'package:koti/estate/estate.dart';
import 'package:koti/logic/device_attribute_control.dart';
import 'package:koti/operation_modes/conditional_operation_modes.dart';
import 'package:koti/operation_modes/hierarcical_operation_mode.dart';
import '../devices/device/device.dart';
import '../devices/mixins/on_off_switch.dart';
import '../estate/environment.dart';
import '../logic/select_index.dart';
import '../logic/services.dart';
import '../look_and_feel.dart';

const String constWarming = 'Kiinteä';
const String constBoolValue = 'Kiinteä On/Off';
const String relativeWarming = 'Suhteellinen';

void _noFunction(dynamic dyn) {
  log.error('not existing OperationMode called ${dyn.toString()}');
}

class OperationMode {
  String _name = '';
  bool preDefined = false;

  OperationMode();

  void init(/* String environmentId ,*/ [OperationModes? initOperationModes]) {
  }

  void clear() {
  }

  String get name => _name;
  set name(String newName) => _name = newName;

  Future<void> select(ControlledDevice controlledDevice, OperationModes? operationModes) async {
    log.error('OperationMode select called: missing subclass implementation');
  }

  OperationMode fromJsonFunction(Map<String, dynamic> json){
    OperationMode o = OperationMode.fromJson(json);
    return o;
  }

  bool isHierarchical() {
    return (this is HierarchicalOperationMode);
  }

  OperationMode clone() {
    return OperationMode.fromJson(toJson());
  }

  OperationMode.fromJson(Map<String, dynamic> json){
    _name = json['name'] ?? '';
    preDefined = json['preDefined'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['name'] = name;
    json['preDefined'] = preDefined;
    json['type'] = runtimeType.toString();

    return json;
  }

  String typeName() {
    return 'operaatio';
  }
}

class ConstantOperationMode extends OperationMode {
  Map<String, dynamic> parameters = {};

  ConstantOperationMode();

  @override
  Future<void> select(ControlledDevice controlledDevice, OperationModes? operationModes) async {
    controlledDevice.setDirectValue(parameters);
  }

  @override
  OperationMode clone() {
    return ConstantOperationMode.fromJson(toJson());
  }

  @override
  ConstantOperationMode.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    parameters = json['parameters'] ?? {};
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    json['parameters'] = parameters;

    return json;
  }

  @override
  String typeName() {
    return constWarming;
  }
}

class BoolServiceOperationMode extends OperationMode {
  String serviceName = '';
  bool value = false;

  BoolServiceOperationMode();

  @override
  Future<void> select(ControlledDevice controlledDevice, OperationModes? operationModes) async {
    Device device = allDevices.findDevice(controlledDevice.deviceId);
    DeviceServiceClass<OnOffSwitchService> deviceService = device.services.getService(serviceName) as DeviceServiceClass<OnOffSwitchService>;
    await deviceService.services.set(value, caller:'toimintotila: "$_name"');
  }

  @override
  OperationMode clone() {
    return BoolServiceOperationMode.fromJson(toJson());
  }


  @override
  BoolServiceOperationMode.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    serviceName = json['serviceName'] ?? '';
    value = json['value'] ?? false;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    json['serviceName'] = serviceName;
    json['value'] = value;

    return json;
  }

  @override
  String typeName() {
    return constBoolValue;
  }
}


OperationMode noOperationMode = OperationMode();

class OperationModeType {
  String name = '';
  Map<String,dynamic> parameters = {};

  OperationModeType();

  OperationModeType fromJson(Map<String, dynamic> json){
    OperationModeType o = OperationModeType.fromJson(json);
    return o;
  }

  OperationModeType.fromJson(Map<String, dynamic> json){
    name = json['name'] ?? '';
    parameters = json['parameters'] ?? {};
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['name'] = name;
    json['parameters'] = parameters;

    return json;
  }

}

class OperationModeTypes {
  List<OperationModeType> _types = [];

  OperationModeTypes();

  List<String> alternatives() {
    List<String> list = [];
    for (var e in _types) {
      list.add(e.name);
    }
    return list;
  }

  void add(String name) {
    OperationModeType o = OperationModeType();
    o.name = name;
    _types.add(o);
  }

  OperationModeTypes.fromJson(Map<String, dynamic> json){

    _types = List.from(json['types']).map((e)=>OperationModeType().fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {


    final json = <String, dynamic>{};

    json['types'] = _types.map((e)=>e.toJson()).toList();

    return json;
  }


}

const _currentIsNotValidIndicator = -1;

class OperationModes {

  List <OperationMode> _modes = [];
  OperationModeTypes types = OperationModeTypes();
  ControlledDevice controlledDevice = ControlledDevice();

  SelectIndex _currentIndex = SelectIndex.empty();

  OperationModes();

  void initModeStructure({ required Environment environment,
              required String parameterSettingFunctionName,
              required String deviceId,
              required List<DeviceAttributeCapability> deviceAttributes,
              required Function setFunction,
              required Function getFunction }) {

    _currentIndex = SelectIndex('${environment.id}/$deviceId');

    controlledDevice.initStructure(
      deviceId: deviceId,
      deviceAttributes: deviceAttributes,
      setFunction: setFunction,
      getFunction: getFunction
    );

    for (var operationMode in _modes) {
      operationMode.init(/*environment.name,*/ this);
    }
  }


  int currentIndex() {
    return _currentIndex.get();
  }

  SelectIndex currentIndexRef() {
    return _currentIndex;
  }

  void invalidateCurrentMode() {
    _currentIndex.invalidateSetting(); // todo: pitäähkö numeroa resetoida?
  }

  bool currentIndexIsValid() {
    return _currentIndex.isValid();
  }

  bool _currentIsInValidRange() {
    return ((_currentIndex.get() >= 0) && (_currentIndex.get() < _modes.length));
  }

  OperationMode current() {
    return (_currentIsInValidRange() ? _modes[_currentIndex.get()] : noOperationMode  );
  }

  String currentModeName() {
    return  (_currentIsInValidRange() ?  _modes[_currentIndex.get()].name : '' );
  }

  bool showCurrent() {
    return (_currentIsInValidRange() && (_modes.length > 1));
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

  bool hasHierarchicalOpModes() {
    for (int i=0; i<_modes.length; i++) {
      if (_modes[i].isHierarchical()) {
        return true;
      }
    }
    return false;
  }

  Future<void> selectIndex(int index, [OperationModes? parentModes]) async {
    await _modes[index].select(controlledDevice, parentModes);

    _currentIndex.setIndex(index);
  }

  Future<void> selectNameAndSetParentInfo(String name, OperationModes parentModes) async {
    int index = findName(name);
    if (index == -1) {
      log.error('OperationModes select: $name not found');
    }
    else {
      await selectIndex(index, parentModes);
      _currentIndex.setIndexAndParentInfo(index, parentModes.currentIndexRef());
    }
  }

  void add(OperationMode operationMode) {
    _modes.add(operationMode);
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
      int index = _currentIndex.get();
      if (index >= removeIndex) {
        // note: works also with the last item.
        _currentIndex.setIndex(index-1);
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

  OperationMode getModeAt(int index) {
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

  void clear() {
    for (var o in _modes) {
      o.clear();
    }
    _modes.clear();
  }

  OperationModes.fromJson(Map<String, dynamic> json){

    _modes = List.from(json['modes']).map((e)=>extendedOperationModeFromJson(this, e)).toList();
  //  types = OperationModeTypes.fromJson(json['types']);
    _currentIndex = SelectIndex(json['currentIndexId'] ?? '');
  }

  Map<String, dynamic> toJson() {

    final json = <String, dynamic>{};

    json['modes'] = _modes.map((e)=>e.toJson()).toList();
   // json['types'] = types.toJson();
    json['currentIndexId'] = _currentIndex.id();

    return json;
  }

  String searchConditionLoops() {
    for (var o in _modes) {
      if (o is ConditionalOperationModes) {
        String problem = o.recursiveLoopWith();
        if (problem.isNotEmpty) {
          return problem;
        }
      }
    }
    return '';
  }

  Widget dumpData({required Function formatterWidget}) {
    String currentModeText = currentModeName();
    return formatterWidget(
        headline: 'Toimintotilat',
        textLines: [
          'Toimintotilojen lukumäärä: ${nbrOfModes()}',
          'Nykyinen tila: ${(currentModeText.isEmpty) ? '-' : currentModeText}',
        ],
        widgets: [const Text('')]
          //for (int i=0; i<nbrOfModes(); i++)
         //   _dumpOperationMode(getModeAt(i)),

    );


  }

}

OperationMode extendedOperationModeFromJson(OperationModes operationModes, Map<String, dynamic> json) {
  switch (json['type'] ?? '') {
    case 'ConstantOperationMode': return ConstantOperationMode.fromJson(json);
    case 'ConditionalOperationModes': return ConditionalOperationModes.fromJson(json);
    case 'HierarchicalOperationMode': return HierarchicalOperationMode.fromJson(json);
    case 'BoolServiceOperationMode': return BoolServiceOperationMode.fromJson(json);
    // case '': return
  }
  log.error('unknown OperationMode jsonObject: "${json['type'] ?? '- not found at all-'}"');
  return noOperationMode;
}

class ObjectRegistry {
  final Map<String, int> _typeMap = {};
  List <OperationMode> list = [];

  void register(OperationMode type) {
    list.add(type);
    _typeMap[type.typeName()] = list.length-1;
  }

  void registerWithName(String name, OperationMode type) {
    list.add(type);
    _typeMap[name] = list.length-1;
  }

  OperationMode createObject(String typeText) {
    final typeIndex = _typeMap[typeText];
    if (typeIndex == null) {
      throw ArgumentError('Unknown type text: $typeText');
    }

    return list[typeIndex].clone();
  }
}

final operationModeTypeRegistry = ObjectRegistry();

void registerOperationModeTypes() {
  operationModeTypeRegistry.register(ConditionalOperationModes());
  operationModeTypeRegistry.register(HierarchicalOperationMode());
  operationModeTypeRegistry.register(ConstantOperationMode());
  operationModeTypeRegistry.register(BoolServiceOperationMode());
}






