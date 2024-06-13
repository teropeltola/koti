
import 'package:koti/operation_modes/conditional_operation_modes.dart';
import 'package:koti/operation_modes/hierarcical_operation_mode.dart';
import '../logic/select_index.dart';
import '../look_and_feel.dart';

const String constWarming = 'Kiinteä';
const String relativeWarming = 'Suhteellinen';

void _noFunction(dynamic dyn) {
  log.error('not existing OperationMode called ${dyn.toString()}');
}

/*
class ParameterHandlingFunction {
  final String _functionName;
  final Function _selectionFunction;

  String get functionName => _functionName;

  ParameterHandlingFunction(this._functionName, this._selectionFunction);

  Future <void> call(Map<String, dynamic> parameters) async {
    await _selectionFunction(parameters);
  }
}


class ParameterHandlingFunctions {
  List<ParameterHandlingFunction> _functions = [];

  void addFunction(ParameterHandlingFunction function) {
    int index = _functionIndex(function.functionName);
    if (index < 0) {
      _functions.add(function);
    }
  }

  int _functionIndex (String name) {
    for (int i=0; i<_functions.length; i++) {
      if (name == _functions[i].functionName) {
        return i;
      }
    }
    return -1;
  }

  Function parameterFunction(OperationMode operationMode)  {
    int i = _functionIndex(operationMode.selectFunctionName);

    if (i<0) {
      log.error('OperationMode "${operationMode.name}" uses missing function "${operationMode.selectFunctionName}"');
      return _noFunction;
    }
    return _functions[i]._selectionFunction;
  }

  void clear() {
    _functions.clear();
  }
}

ParameterHandlingFunctions myParameterHandlingFunctions = ParameterHandlingFunctions();
*/

class OperationMode {
  String _name = '';

  OperationMode();

  String get name => _name;
  set name(String newName) => _name = newName;

  Future<void> select(Function function, OperationModes? operationModes) async {
    log.error('OperationMode select called: missing subclass implementation');
  }

  OperationMode fromJsonFunction(Map<String, dynamic> json){
    OperationMode o = OperationMode.fromJson(json);
    return o;
  }

  bool isHierarchical() {
    return (this is HierarchicalOperationMode);
  }

  OperationMode.fromJson(Map<String, dynamic> json){
    _name = json['name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['name'] = name;
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
  Future<void> select(Function function, OperationModes? operationModes) async {
    function(parameters);
  }


  @override
  ConstantOperationMode.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    parameters = json['parameters'] ?? {};
  }

  ConstantOperationMode cloneFrom(OperationMode sourceMode) {
    ConstantOperationMode newMode = ConstantOperationMode.fromJson(sourceMode.toJson());
    return newMode;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    json['parameters'] = parameters;

    return json;
  }

  @override
  String typeName() {
    return 'Kiinteä';
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
    _types.forEach((e)=>list.add(e.name));
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
  String estateName = '';
  Function selectFunction = _noFunction;

  late SelectIndex _currentIndex;

  OperationModes(String creatorId) {
    _currentIndex = SelectIndex(creatorId);
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
    await _modes[index].select(selectFunction, parentModes);

    _currentIndex.setIndex(index);
  }

  Future<void> selectNameAndSetParentInfo(String name, OperationModes parentModes) async {
    int index = findName(name);
    if (index == -1) {
      log.error('OperationModes select: $name not found');
    }
    else {
      await selectIndex(index);
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
/*
  OperationModes.fromJsonOld(Map<String, dynamic> json){

    _modes = List.from(json['modes']).map((e)=>OperationMode().fromJsonFunction(e)).toList();
    types = OperationModeTypes.fromJson(json['types']);
  }

 */

  OperationModes.fromJson(Map<String, dynamic> json){

    _modes = List.from(json['modes']).map((e)=>extendedOperationModeFromJson(this, e)).toList();
    types = OperationModeTypes.fromJson(json['types']);
    _currentIndex = SelectIndex(json['currentIndexId'] ?? '');
  }

  Map<String, dynamic> toJson() {

    final json = <String, dynamic>{};

    json['modes'] = _modes.map((e)=>e.toJson()).toList();
    json['types'] = types.toJson();
    json['currentIndexId'] = _currentIndex.id();

    return json;
  }

}

OperationMode extendedOperationModeFromJson(OperationModes operationModes, Map<String, dynamic> json) {
  switch (json['type'] ?? '') {
    case 'ConstantOperationMode': return ConstantOperationMode.fromJson(json);
    case 'ConditionalOperationModes': return ConditionalOperationModes.fromJsonExtended(operationModes, json);
    case 'HierarchicalOperationMode': return HierarchicalOperationMode.fromJson(json);
    // case '': return
  }
  log.error('unknown OperationMode jsonObject: "${json['type'] ?? '- not found at all-'}"');
  return noOperationMode;
}


