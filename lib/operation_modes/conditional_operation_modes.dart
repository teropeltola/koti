import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';

import '../functionalities/electricity_price/electricity_price.dart';
import '../look_and_feel.dart';
import '../main.dart';
import 'analysis_of_modes.dart';
import 'operation_modes.dart';

const String dynamicOperationModeText = 'Vaihtuva';

enum OperationComparisons {less, greater, equal, lessOrEqual, greaterOrEqual;
  static const comparisonText = ['pienempi kuin', 'suurempi kuin', 'yhtäsuuri kuin', 'pienempi tai yhtäsuuri kuin', 'suurempi tai yhtäsuuri kuin' ];
  static const jsonText = ['<','>','==','<=','>=' ];
  String text() => comparisonText[this.index];

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
      log.error('OperationComparison fromJson, invalid json: $json');
      return OperationComparisons.less;
    }
    else {
      return OperationComparisons.values[myIndex];
    }
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['comparison'] = jsonText[this.index];

    return json;
  }
}

enum SpotPriceComparisonType {
  constant,
  median,
  percentile;

  static const typeText = ['vakio','mediaani', '%-piste'];
  static const jsonText = ['const','median', 'percentile'];

  String text() => typeText[this.index];

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

    json['spotPriceType'] = jsonText[this.index];

    return json;
  }

}

class SpotCondition {
  SpotPriceComparisonType myType = SpotPriceComparisonType.constant;
  OperationComparisons comparison = OperationComparisons.less;
  double parameterValue = 0.0;

  SpotCondition();

  bool isTrue(double spotPrice, ElectricityPriceTable eTable) {
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

enum OperationConditionType {notDefined, timeOfDay, spotPrice, spotDiff;
  static const optionTextList = ['','kellonaika', 'hinta', 'hintamuutos'];

  String text() => optionTextList[index];
  static const jsonText = ['notDefined','time', 'price', 'priceDelta'];


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
  MyTimeRange timeRange = MyTimeRange(startTime: TimeOfDay(hour: 0, minute: 0),
      endTime: TimeOfDay(hour: 23, minute: 59));
  SpotCondition spot = SpotCondition();

  OperationCondition();

  @override
  String toString() {
    switch (conditionType) {
      case OperationConditionType.notDefined:
        return 'internal error';
      case OperationConditionType.timeOfDay:
        return '${conditionType.text()} ${timeRange.toString()}';
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

  /*
  ResultOperationMode.fromJsonExtended(Map<String, dynamic> json, OperationModes operationModes){
    String name = json['operationCodeName'] ?? '';
    OperationMode opMode = operationModes.getMode(name);
    if (opMode == noOperationMode) {
      log.error('ResultOperationMode not found: $json from operation modes (${operationModes.operationModeNames()})');
    }
    result = opMode;
  }

   */

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
    return ((this.hour < other.hour) || ((this.hour == other.hour) && (this.minute <= other.minute)));
  }
}

class ConditionalOperationMode {
  bool draft = true;
  late OperationCondition condition;
  late ResultOperationMode result;

  ConditionalOperationMode(this.condition, this.result);

  bool parametersOK() {
    return condition.parametersOK();
  }

  bool matchSpotIndex(int spotIndex, ElectricityPriceTable electricityPriceTable) {
    return match(electricityPriceTable.slotStartingTime(spotIndex),electricityPriceTable.slotPrices[spotIndex], electricityPriceTable);
  }

  bool match(DateTime dateTime, double price, ElectricityPriceTable electricityPriceTable) {
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
      case OperationConditionType.spotPrice: {
        return condition.spot.isTrue(price,electricityPriceTable);
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
  final OperationModes operationModes;

  ConditionalOperationModes(this.operationModes);

  void add(ConditionalOperationMode newMode) {
    conditions.insert(0, newMode);
  }

  ConditionalOperationMode removeAt(int index) {
    return conditions.removeAt(index);
  }

  String getOperationModeName(int spotIndex, ElectricityPriceTable electricityPriceTable) {
    for (int i=0; i<conditions.length; i++) {
      if (conditions[i].matchSpotIndex(spotIndex, electricityPriceTable)) {
        return conditions[i].result.operationModeName;
      }
    }
    return '';
  }


  int nbrOfConditions() {
    return conditions.length;
  }

  int nbrOfCompletedConditions() {
    int nonDraftConditions = 0;
    for (int i=0; i<conditions.length; i++) {
      if (! conditions[i].draft) {
        nonDraftConditions++;
      }
    }
    return nonDraftConditions;
  }


  List<String> simulate() {

    ElectricityPriceTable electricityPriceTable = myEstates.estate(operationModes.estateName).myDefaultElectricityPrice().get();
    DateTime startingTime = electricityPriceTable.startingTime;

    AnalysisOfModes analysis = AnalysisOfModes();

    if (nbrOfCompletedConditions() == 0) {
      return [];
    }

    for (int i=0; i<electricityPriceTable.nbrOfMinutes(); i++) {
      analysis.add(startingTime.add(Duration(minutes: i)),1,getOperationModeName(i ~/ electricityPriceTable.slotSizeInMinutes, electricityPriceTable));
    }
    analysis.compress();

    return analysis.toStringList();
  }

  @override
  Future<void> select(Function unUsedFunction, OperationModes? parentModes) async {
    DateTime dateTime = DateTime.now();
    ElectricityPrice electricityPrice = myEstates.estate(operationModes.estateName).myDefaultElectricityPrice();
    double price = electricityPrice.currentPrice();
    ElectricityPriceTable electricityPriceTable = electricityPrice.get();

    for (int i=0; i<conditions.length; i++) {
      String opModeName = conditions[i].result.operationModeName;
      if (conditions[i].match(dateTime, price, electricityPriceTable)) {
        OperationMode opMode = operationModes.getMode(conditions[i].result.operationModeName);
        if (opMode == noOperationMode) {
          log.error('ConditionalOperationModes select: $opModeName not found from operation modes');
        }
        else {
          await opMode.select(operationModes.selectFunction, parentModes);
        }
      }
    }
  }

  ConditionalOperationModes.fromJsonExtended(
      this.operationModes,
      Map<String, dynamic> json) : super.fromJson(json){

    conditions = List.from(json['conditions'] ?? {}).map((e)=>ConditionalOperationMode.fromJson(e)).toList();
  }
/*
  ConditionalOperationModes.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    conditions = List.from(json['conditions'].map((e)=>ConditionalOperationMode.fromJson(e)).toList());
  }


 */
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    json['conditions'] = conditions.map((e)=>e.toJson()).toList();

    return json;
  }

  @override
  String typeName() {
    return 'Muuttuva';
  }

}


