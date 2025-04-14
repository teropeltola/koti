import 'dart:async';

import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';

import '../estate/estate.dart';
import '../functionalities/electricity_price/electricity_price.dart';
import '../logic/device_attribute_control.dart';
import '../logic/electricity_price_data.dart';
import '../logic/events.dart';
import '../logic/observation.dart';
import '../look_and_feel.dart';
import 'analysis_of_modes.dart';
import 'operation_modes.dart';

const String dynamicOperationModeText = 'Vaihtuva';

enum OperationComparisons {less, greater, equal, lessOrEqual, greaterOrEqual;
  static const comparisonText = ['pienempi kuin', 'suurempi kuin', 'yhtäsuuri kuin', 'pienempi tai yhtäsuuri kuin', 'suurempi tai yhtäsuuri kuin' ];
  static const comparisonChangeText = ['pienemmäksi kuin', 'suuremmaksi kuin', 'yhtäsuureksi kuin', 'pienemmäksi tai yhtäsuureksi kuin', 'suuremmaksi tai yhtäsuureksi kuin' ];
  static const jsonText = ['<','>','==','<=','>=' ];
  String text() => comparisonText[index];
  String changeText() => comparisonChangeText[index];

  bool comparisonValue(double par1, double par2) {
    switch (this) {
      case OperationComparisons.less: return (par1 < par2);
      case OperationComparisons.greater: return (par1 > par2);
      case OperationComparisons.equal: return (par1 == par2);
      case OperationComparisons.lessOrEqual: return (par1 <= par2);
      case OperationComparisons.greaterOrEqual: return (par1 >= par2);
    }
  }

  OperationComparisons fromJson(Map<String, dynamic> json){
    int myIndex = jsonText.indexOf(json['comparison'] ?? '');
    if (myIndex < 0) {
      events.write(myEstates.currentEstate().id, '', ObservationLevel.warning,'OperationComparison fromJson, invalid json: $json');
      return OperationComparisons.less;
    }
    else {
      return OperationComparisons.values[myIndex];
    }
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['comparison'] = jsonText[index];

    return json;
  }
}

enum SpotPriceComparisonType {
  constant,
  median,
  percentile;

  static const typeText = ['vakio','mediaani', '%-piste'];
  static const jsonText = ['const','median', 'percentile'];

  String text() => typeText[index];

  SpotPriceComparisonType fromJson(Map<String, dynamic> json){
    int myIndex = jsonText.indexOf(json['spotPriceType'] ?? '');
    if (myIndex < 0) {
      log.error('SpotPriceComparisonType fromJson, invalid json: $json');
      return SpotPriceComparisonType.constant;
    }
    else {
      return SpotPriceComparisonType.values[myIndex];
    }
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['spotPriceType'] = jsonText[index];

    return json;
  }

}

class SpotCondition {
  SpotPriceComparisonType myType = SpotPriceComparisonType.constant;
  OperationComparisons comparison = OperationComparisons.less;
  double parameterValue = 0.0;

  SpotCondition();

  bool isTrue(double spotPrice, ElectricityPriceData eTable) {
    switch (myType) {
      case SpotPriceComparisonType.constant: return comparison.comparisonValue(spotPrice, parameterValue);
      case SpotPriceComparisonType.median: {
        double referenceValue = eTable.findPercentile(0.5);
        return comparison.comparisonValue(spotPrice, referenceValue);
      }
      case SpotPriceComparisonType.percentile: {
        double referenceValue = eTable.findPercentile(parameterValue);
        return comparison.comparisonValue(spotPrice, referenceValue);
      }
    }

  }

  SpotCondition.fromJson(Map<String, dynamic> json){
    myType = myType.fromJson(json['type'] ?? {});
    comparison = comparison.fromJson(json['comparison'] ?? {});
    parameterValue = json['parameterValue'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {

    final json = <String, dynamic>{};

    json['type'] = myType.toJson();
    json['comparison'] = comparison.toJson();
    json['parameterValue'] = parameterValue;

    return json;
  }

}

enum OperationConditionType {notDefined, timeOfDay, deviceVariable, spotPrice, spotDiff;
  static const optionTextList = ['','kellonaika', 'laitemuuttuja', 'hinta', 'hintamuutos'];

  String text() => optionTextList[index];
  static const jsonText = ['notDefined','time', 'deviceInfo', 'price', 'priceDelta'];


  OperationConditionType fromJson(Map<String, dynamic> json){
    int myIndex = jsonText.indexOf(json['operationConditionType'] ?? '');
    if (myIndex < 0) {
      log.error('OperationConditionType fromJson, invalid json: $json');
      return OperationConditionType.notDefined;
    }
    else {
      return OperationConditionType.values[myIndex];
    }
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['operationConditionType'] = jsonText[index];

    return json;
  }

}

class MyTimeRange extends TimeRange {
  MyTimeRange({required super.startTime, required super.endTime});

  MyTimeRange fromJson(Map<String, dynamic> json){
    TimeOfDay startTime = _timeOfDayDecode(json['startTime'] ?? {});
    TimeOfDay endTime = _timeOfDayDecode(json['endTime'] ?? {});
    return MyTimeRange(startTime: startTime, endTime: endTime);
  }

  Map<String, dynamic> toJson() {

    final json = <String, dynamic>{};

    json['startTime'] = _timeOfDayEncode(startTime);
    json['endTime'] = _timeOfDayEncode(endTime);
    return json;
  }
}

class DeviceVariableData  {

  String deviceName = '';
  String serviceName = '';

  DeviceVariableData.fromJson(Map<String, dynamic> json){
    deviceName = json['deviceName'] ?? '';
    serviceName = json['serviceName'] ?? '';
  }

  Map<String, dynamic> toJson() {

    final json = <String, dynamic>{};

    json['deviceName'] = deviceName;
    json['serviceName'] = serviceName;
    return json;
  }
}


Map<String, dynamic> _timeOfDayEncode(TimeOfDay timeOfDay) {
  Map<String, dynamic> json = {};
  json['hour'] = timeOfDay.hour;
  json['minute'] = timeOfDay.minute;
  return json;
}

TimeOfDay _timeOfDayDecode(Map<String, dynamic> json) {
  TimeOfDay timeOfDay = TimeOfDay(hour: json['hour'] ?? 0, minute: json['minute'] ?? 0);
  return timeOfDay;
}

class OperationCondition {
  OperationConditionType conditionType = OperationConditionType.notDefined;
  MyTimeRange timeRange = MyTimeRange(startTime: const TimeOfDay(hour: 0, minute: 0),
      endTime: const TimeOfDay(hour: 23, minute: 59));
  SpotCondition spot = SpotCondition();

  OperationCondition();

  @override
  String toString() {
    switch (conditionType) {
      case OperationConditionType.notDefined:
        return 'internal error';
      case OperationConditionType.timeOfDay:
        return '${conditionType.text()} ${timeRange.toString()}';
      case OperationConditionType.deviceVariable:
        return 'deviceVariable';
      case OperationConditionType.spotPrice:
        return 'spotPrice';
      case OperationConditionType.spotDiff:
        return 'increase';
      default:
        return 'Not implemented';
    }
  }

  bool parametersOK() {
    if (conditionType == OperationConditionType.notDefined) {
      return false;
    }
    return true;
  }

  OperationCondition.fromJson(Map<String, dynamic> json){
    conditionType = conditionType.fromJson(json['conditionType'] ?? {});
    timeRange = timeRange.fromJson(json['timeRange'] ?? {});
    spot = (json['spot'] == null) ? SpotCondition() : SpotCondition.fromJson(
        json['spot']);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['conditionType'] = conditionType.toJson();
    json['timeRange'] = timeRange.toJson();
    json['spot'] = spot.toJson();

    return json;
  }
}

class ResultOperationMode {
  String operationModeName = '';

  ResultOperationMode(this.operationModeName);

  ResultOperationMode.fromJson(Map<String, dynamic> json){
    operationModeName = json['operationCodeName'] ?? '';
  }


  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['operationCodeName'] = operationModeName;

    return json;
  }


}

extension TOD on TimeOfDay {
  bool isEarlierOrEqualThan(TimeOfDay other) {
    return ((hour < other.hour) || ((hour == other.hour) && (minute <= other.minute)));
  }
}

class ConditionalOperationMode {
  bool draft = false;
  late OperationCondition condition;
  late ResultOperationMode result;

  ConditionalOperationMode(this.condition, this.result);

  bool parametersOK() {
    return condition.parametersOK();
  }

  bool matchSpotIndex(int spotIndex, ElectricityPriceData electricityPriceData) {
    return match(electricityPriceData.slotStartingTime(spotIndex),electricityPriceData.prices[spotIndex].totalPrice, electricityPriceData);
  }

  bool match(DateTime dateTime, double price, ElectricityPriceData electricityPriceData) {
    switch (condition.conditionType) {
      case OperationConditionType.notDefined:
        return false;
      case OperationConditionType.timeOfDay:
        {
          TimeOfDay time = TimeOfDay.fromDateTime(dateTime);
          if (condition.timeRange.startTime.isEarlierOrEqualThan(
              condition.timeRange.endTime)) {
            // range is fully in the same day
            return ((condition.timeRange.startTime.isEarlierOrEqualThan(time)) &&
                (time.isEarlierOrEqualThan(condition.timeRange.endTime)));
          }
          else {
            // range is over the midnight
            return ((condition.timeRange.startTime.isEarlierOrEqualThan(time)) ||
                (time.isEarlierOrEqualThan(condition.timeRange.endTime)));
          }
        }
      case OperationConditionType.deviceVariable:
        // TODO: not implemented
        return false; // condition.deviceIfno
      case OperationConditionType.spotPrice: {
        return condition.spot.isTrue(price,electricityPriceData);
      }

      case OperationConditionType.spotDiff:
        return false;
      default:
        return false;
    }
  }


  ConditionalOperationMode.fromJson(Map<String, dynamic> json){
    condition = OperationCondition.fromJson(json['condition'] ?? {});
    result = ResultOperationMode.fromJson(json['result'] ?? {});
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['condition'] = condition.toJson();
    json['result'] = result.toJson();

    return json;
  }
}

class ConditionalOperationModes extends OperationMode {
  List<ConditionalOperationMode> conditions = [];
  String anchorConditionName = ''; // this condition is selected if no conditions match

  OperationModes operationModes = OperationModes();

  String _currentConditionName = '';
  AnalysisOfModes currentAnalysis = AnalysisOfModes();

  Timer? _nextSelectTimer;

  /*
  ElectricityPriceListener electricityPriceListener = ElectricityPriceListener();
*/
  ConditionalOperationModes();

  @override
  void init(/*String enviromentName ,*/ [OperationModes? initOperationModes]) {
    operationModes = initOperationModes!;
    /*
    electricityPriceListener.start(
        myEstates.estates[0].myDefaultElectricityPrice().myBroadcaster(),
        updateCurrentAnalysis);
*/

  }

  //called whenever there are updates to listened electricityPriceTable
  void updateCurrentAnalysis(ElectricityPriceData electricityPriceData) {
    DateTime dateTime = DateTime.now();

    currentAnalysis = _analyse(electricityPriceData,dateTime);
    log.info('ConditionalOperationModes "$name" updateCurrentAnalysis');

  }

  void add(ConditionalOperationMode newMode) {
    conditions.insert(0, newMode);
  }

  ConditionalOperationMode removeAt(int index) {
    return conditions.removeAt(index);
  }

  String getOperationModeName(int spotIndex, ElectricityPriceData electricityPriceData) {
    for (var c in conditions) {
      if (c.matchSpotIndex(spotIndex, electricityPriceData)) {
        return c.result.operationModeName;
      }
    }
    return anchorConditionName;
  }

  void setAnchorCondition(String newAnchorName) {
    anchorConditionName = newAnchorName;
  }

  int nbrOfConditions() {
    return conditions.length;
  }

  int nbrOfCompletedConditions() {
    int nonDraftConditions = 0;
    for (var c in conditions) {
      if (! c.draft) {
        nonDraftConditions++;
      }
    }
    return nonDraftConditions;
  }

  List<String> possibleOperationModes() {
    List <String> modeNames = [];
    for (var c in conditions) {
      if (! modeNames.contains(c.result.operationModeName)) {
        modeNames.add(c.result.operationModeName);
      }
    }
    return modeNames;
  }

  List<String> simulate() {

    ElectricityPriceData data  = myEstates.currentEstate().myDefaultElectricityPrice().electricity.data;
    DateTime startingTime =    data.startingTime();

    AnalysisOfModes analysis = AnalysisOfModes();

    if (nbrOfCompletedConditions() == 0) {
      return [];
    }

    for (int i=0; i<data.nbrOfMinutes(); i++) {
      DateTime slotStartingTime = startingTime.add(Duration(minutes: i));
      String oName = getOperationModeName(i ~/ data.slotSizeInMinutes, data);
      analysis.add(slotStartingTime, 1, oName);
    }
    analysis.compress();

    return analysis.toStringList();
  }

  AnalysisOfModes _analyse(ElectricityPriceData electricityPriceData, DateTime startingTime) {
    AnalysisOfModes analysis = AnalysisOfModes();

    for (int i=0; i<electricityPriceData.nbrOfMinutes(); i++) {
      analysis.add(startingTime.add(Duration(minutes: i)),1,getOperationModeName(i ~/ electricityPriceData.slotSizeInMinutes, electricityPriceData));
    }
    analysis.compress();

    return analysis;
  }

  @override
  Future<void> select(ControlledDevice unUsedDevice, OperationModes? parentModes) async {

    if (currentAnalysis.isEmpty()) {
      log.error('conditional select options empty');
      return;
    }
    String opModeName = currentAnalysis.setFirstOperationName(DateTime.now());
    if (await _doSelect(opModeName, parentModes)) {
      _setupTimerForNextSelect(parentModes);
    }
  }

  Future<bool> _doSelect(String operationModeName, OperationModes? parentModes) async {
    OperationMode opMode = operationModes.getMode(operationModeName);
    if (opMode == noOperationMode) {
      log.error('ConditionalOperationModes select: $operationModeName not found from operation modes');
      return false;
    }
    else {
      await opMode.select(operationModes.controlledDevice, parentModes);
      _currentConditionName = operationModeName;
      return true;
    }
  }

  void _setupTimerForNextSelect(OperationModes? parentModes) {

    if (_nextSelectTimer != null) {
      _nextSelectTimer!.cancel();
    }

    AnalysisItem next = currentAnalysis.updateAndGetCurrentItem();
    Duration calcDuration = next.start.difference(DateTime.now());
    if (calcDuration.isNegative) {
      log.error('ConditionalOperationModes duration is negative with ${next.operationModeName}');
    }
    else {
      _nextSelectTimer = Timer(calcDuration, () async {
        if (await _doSelect(next.operationModeName, parentModes)) {
          _setupTimerForNextSelect(parentModes);
        }
      });
    }
  }

  @override
  OperationMode clone() {
    return ConditionalOperationModes.fromJson(toJson());
  }

  ConditionalOperationModes.fromJson(
      Map<String, dynamic> json) : super.fromJson(json){

    conditions = List.from(json['conditions'] ?? {}).map((e)=>ConditionalOperationMode.fromJson(e)).toList();
    anchorConditionName = json['anchorConditionName'] ?? '';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    json['conditions'] = conditions.map((e)=>e.toJson()).toList();
    json['anchorConditionName'] = anchorConditionName;

    return json;
  }

  @override
  String typeName() {
    return dynamicOperationModeText;
  }

  @override
  void clear() {
    if (_nextSelectTimer != null) {
      _nextSelectTimer!.cancel();
    }
    currentAnalysis.clear();
  }

  AnalysisItem nextSelectItem() {
    if ((_nextSelectTimer != null) && (_nextSelectTimer!.isActive)) {
      return currentAnalysis.currentItem();
    }
    else {
      return AnalysisItem.empty();
    }
  }

  String currentActiveConditionName() {
    return _currentConditionName;
  }

  // checks if this have a recursive loop with other ConditionalOperationModes
  // and informs the name of the other. Return '' if no recursive loops
  String recursiveLoopWith() {
    List <String> forbiddenModes = [];
    return _recursiveLoopWith(this, operationModes, forbiddenModes);
  }

  String _recursiveLoopWith(ConditionalOperationModes currentCondition, OperationModes currentOperationModes, List<String> forbiddenModes) {
    forbiddenModes.add( currentCondition.name);
    for (var c in  currentCondition.conditions) {
      String resultName = c.result.operationModeName;
      OperationMode o = currentOperationModes.getMode(resultName);
      if (o is ConditionalOperationModes) {
        if (forbiddenModes.contains(o.name)) {
          return (o.name);
        }
        else {
          String recursiveResult = _recursiveLoopWith(o, currentOperationModes, forbiddenModes);
          if (recursiveResult.isNotEmpty) {
            return recursiveResult;
          }
        }
      }
    }
    return '';
  }

}


