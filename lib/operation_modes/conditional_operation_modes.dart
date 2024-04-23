import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';

import '../functionalities/electricity_price/electricity_price.dart';
import '../look_and_feel.dart';
import 'operation_modes.dart';

enum OperationComparisons {less, greater, equal, lessOrEqual, greaterOrEqual;
  static const comparisonText = ['pienempi kuin', 'suurempi kuin', 'yhtäsuuri kuin', 'pienempi tai yhtäsuuri kuin', 'suurempi tai yhtäsuuri kuin' ];

  String text() => comparisonText[this.index];

  bool value(double par1, double par2) {
    switch (this) {
      case OperationComparisons.less: return (par1 < par2);
      case OperationComparisons.greater: return (par1 > par2);
      case OperationComparisons.equal: return (par1 == par2);
      case OperationComparisons.lessOrEqual: return (par1 <= par2);
      case OperationComparisons.greaterOrEqual: return (par1 >= par2);
    }
  }
}

enum SpotPriceComparisonType {
  constant,
  median,
  percentile;

  static const typeText = ['vakio','mediaani', '%-piste'];

  String text() => typeText[this.index];
}

class SpotCondition {
  SpotPriceComparisonType myType = SpotPriceComparisonType.constant;
  OperationComparisons comparison = OperationComparisons.less;
  double parameterValue = 0.0;

  bool isTrue(double spotPrice, ElectricityPriceTable eTable) {
    switch (myType) {
      case SpotPriceComparisonType.constant: return comparison.value(spotPrice, parameterValue);
      case SpotPriceComparisonType.median: {
        double referenceValue = eTable.findPercentile(0.5);
        return comparison.value(spotPrice, referenceValue);
      }
      case SpotPriceComparisonType.percentile: {
        double referenceValue = eTable.findPercentile(parameterValue);
        return comparison.value(spotPrice, referenceValue);
      }
    }

  }
}

enum OperationConditionType {notDefined, timeOfDay, spotPrice, spotDiff;
  static const optionTextList = ['','kellonaika', 'hinta', 'hintamuutos'];

  String text() => optionTextList[this.index];
}

class OperationCondition {
  OperationConditionType conditionType = OperationConditionType.notDefined;
  TimeRange timeRange = TimeRange(startTime: TimeOfDay(hour: 0, minute: 0),endTime: TimeOfDay(hour: 23,minute: 59));
  SpotCondition spot = SpotCondition();

  @override
  String toString() {
    switch (conditionType) {
      case OperationConditionType.notDefined: return 'internal error';
      case OperationConditionType.timeOfDay: return '${conditionType.text()} ${timeRange.toString()}';
      case OperationConditionType.spotPrice: return 'spotPrice';
      case OperationConditionType.spotDiff: return 'increase';
      default: return 'Not implemented';
    }
  }

  bool parametersOK() {
    if (conditionType == OperationConditionType.notDefined) {
      return false;
    }
    return true;
  }

}

class ResultOperationMode {
  OperationMode result;

  ResultOperationMode(this.result);
}

extension TOD on TimeOfDay {
  bool isEarlierOrEqualThan(TimeOfDay other) {
    return ((this.hour < other.hour) || ((this.hour == other.hour) && (this.minute <= other.minute)));
  }
}

class ConditionalOperationMode {
  bool draft = true;
  OperationCondition condition;
  ResultOperationMode result;

  ConditionalOperationMode(this.condition, this.result);

  bool parametersOK() {
    return condition.parametersOK();
  }

  bool match(int spotIndex, ElectricityPriceTable electricityPriceTable) {
    switch (condition.conditionType) {
      case OperationConditionType.notDefined:
        return false;
      case OperationConditionType.timeOfDay:
        {
          TimeOfDay time = TimeOfDay.fromDateTime(electricityPriceTable.slotStartingTime(spotIndex));
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
        return condition.spot.isTrue(electricityPriceTable.slotPrices[spotIndex],electricityPriceTable);
      }

      case OperationConditionType.spotDiff:
        return false;
      default:
        return false;
    }
  }
}

class ConditionalOperationModes {
  List<ConditionalOperationMode> conditions = [];

  void add(ConditionalOperationMode newMode) {
    conditions.insert(0, newMode);
  }

  ConditionalOperationMode removeAt(int index) {
    return conditions.removeAt(index);
  }

  OperationMode getOperationMode(int spotIndex, ElectricityPriceTable electricityPriceTable) {
    for (int i=0; i<conditions.length; i++) {
      if (conditions[i].match(spotIndex, electricityPriceTable)) {
        return conditions[i].result.result;
      }
    }
    return noOperationMode;
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


  List<String> simulate(ElectricityPriceTable electricityPriceTable) {

    List<String> modes = [_dateLine(electricityPriceTable.startingTime)];
    int deltaMinutes = 0;
    int startingIndex = 0;
    DateTime startingTime = electricityPriceTable.startingTime;
    DateTime endingTime = electricityPriceTable.lastMinuteOfPeriod();

    AnalysisOfModes analysis = AnalysisOfModes();

    if (nbrOfCompletedConditions() == 0) {
      return [];
    }

    for (int i=0; i<electricityPriceTable.nbrOfMinutes(); i++) {
      analysis.add(startingTime.add(Duration(minutes: i)),1,getOperationMode(i ~/ electricityPriceTable.slotSizeInMinutes, electricityPriceTable));
    }
    analysis.compress();

    for (int i=0; i<analysis.items.length; i++) {
      modes.add('${_time(analysis.items[i].start)}-${_time(analysis.items[i].end)}: ${analysis.items[i].operationMode.name}');
    }

    return modes;
    /*

    for (int i=conditions.length-1; i>=0; i--) {
      if (! conditions[i].draft) {
        if (conditions[i].condition == OperationConditionType.timeOfDay) {

          models.add(conditions[i].condition.timeRange.startTime)
        }
        else if (conditions[i].condition == OperationConditionType.spotPrice) {

        }
      }
    }
    for (int i=0;i<electricityPriceTable.slotPrices.length; i++) {
      modeNames.add(getOperationMode(i, electricityPriceTable).name);
    }

    int firstIndex = 0;
    int nbrOfSameMode = 0;
    for (int j=1;j<electricityPriceTable.slotPrices.length; j++) {
      if (modeNames[firstIndex] == modeNames[j]) {
        nbrOfSameMode++;
      }
      else {
        modes.add('${_time(electricityPriceTable.slotStartingTime(firstIndex))}'
          '-${_time(electricityPriceTable.slotStartingTime((j-1)).add(Duration(minutes:59)))}: ${modeNames[firstIndex]}');

        firstIndex = j;
        nbrOfSameMode = 0;
      }
    }
    modes.add('${_time(electricityPriceTable.slotStartingTime(firstIndex))}'
        '-${_time(electricityPriceTable.slotStartingTime(electricityPriceTable.slotPrices.length-1).add(Duration(minutes:59)))}: ${modeNames[firstIndex]}');

    return modes;

     */
  }

  String _time(DateTime dateTime) {
    return '${dateTime.hour}.${dateTime.minute.toString().padLeft(2,'0')}';
  }
  String _dateLine(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }
}


class AnalysislItem {
  DateTime start;
  DateTime end;
  OperationMode operationMode;

  AnalysislItem(this.start, this.end, this.operationMode);
}


class AnalysisOfModes {
  List <AnalysislItem> items = [];

  int _find(int first, DateTime dateTime ) {
    for (int i=first; i < items.length;i++) {
      if (dateTime.isBefore(items[i].end)) {
        return i;
      }
    }
    return items.length;
  }

  void compress() {
    for (int i=items.length-2; i>=0; i--) {
      if (items[i].operationMode == items[i+1].operationMode) {
        items[i].end = items[i+1].end;
        items.removeAt(i+1);
      }
    }

  }

  void add(DateTime start, int durationInMinutes, OperationMode operationMode) {

    if (items.isNotEmpty) {
      if (! items.last.end.add(Duration(minutes: 1)).isAtSameMomentAs(start)) {
        log.error('AnalysisOfModes illegal addition');
        return;
      }
    }
    items.add(AnalysislItem(start, start.add(Duration(minutes: durationInMinutes-1)), operationMode));

  }
}