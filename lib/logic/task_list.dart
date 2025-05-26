import 'package:flutter/material.dart';

import '../foreground_configurator.dart';
import '../look_and_feel.dart';
import '../operation_modes/conditional_operation_modes.dart';
import 'electricity_price_data.dart';

class TaskItem {
  late String serviceName;
  late String estateId;
  late String taskId;
  bool recurring = false;
  late Map <String, dynamic> parameters;
  late DateTime nextExecution;
  late int taskExecutionFunctionIndex;
  bool removeThis = false;

  TaskItem(this.serviceName, this.estateId, this.taskId, this.recurring, this.parameters, this.nextExecution, this.taskExecutionFunctionIndex);

  void updateNextExecution() {
    print('task item ${this.runtimeType.toString()} missing updateNextExecution');
  }


  String nextExecutionString() {
    if (nextExecution.year == _noExecutionValue) {
      return '-';
    }
    else {
      return myDateTimeFormatter(nextExecution, withoutYear: true);
    }
  }

  @override
  String toString() {
    return '(taskName: $serviceName, nextExecution: ${nextExecution.toString()})';
  }

  IconData icon() {
    return Icons.task_alt;
  }

  String description(Map <String, dynamic> parameters) {
    return 'Lisää kuvaus: ${this.runtimeType.toString()}';
  }

  Map<String, dynamic> toJson() {
    return {
      'runtimeType': runtimeType.toString(),
      'serviceName': serviceName,
      'id': taskId,
      'recurring': recurring,
      'parameters': parameters,
      'nextExecution': nextExecution.toIso8601String(),// Convert DateTime to ISO 8601 string
      'taskExecutionFunctionIndex': taskExecutionFunctionIndex,
    };
  }

  // JSON Decoding
  TaskItem.fromJson(Map<String, dynamic> json) {
    serviceName = json['serviceName'] ?? 'serviceNameNotFound';
    taskId = json['id'] ?? 'idNotFound';
    recurring = json['recurring'] ?? false;
    parameters = json['parameters'] ?? {};
    nextExecution = DateTime.parse(json['nextExecution']); // Parse ISO 8601 string to DateTime
    taskExecutionFunctionIndex =  json['taskExecutionFunctionIndex'] ?? 60;
  }
}

class IntervalTask extends TaskItem {
  int intervalInMinutes = 60;

  IntervalTask(String serviceName, String estateId, String id, bool recurring, this.intervalInMinutes, Map <String, dynamic> parameters, DateTime dateTime, int functionIndex )
      : super(serviceName, estateId, id, recurring, parameters, dateTime, functionIndex);

  @override
  void updateNextExecution() {
    nextExecution = nextExecution.add(Duration(minutes: intervalInMinutes));
  }

  @override
  String toString() {
    return '(recurring task: $serviceName, intervalInMinutes: $intervalInMinutes, nextExecution: ${nextExecution.toString()})';
  }

  @override
  String description(Map <String, dynamic> parameters) {
    bool _powerOn = parameters[powerOn] ?? false;
    return 'Asetetaan ${_powerOn ? 'päälle' : 'pois päältä'} ${intervalInMinutes} minuutin välein.';
  }

  @override
  IconData icon() {
    return Icons.av_timer;
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['intervalInMinutes'] = intervalInMinutes;
    return json;
  }

  @override
  IntervalTask.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    intervalInMinutes = json['intervalInMinutes'] ?? 60;
  }
}

class TimeOfDayTask extends TaskItem {
  int hour = 0;
  int minute = 0;

  TimeOfDayTask(String serviceName, String estateId, String id, bool recurring, this.hour, this.minute,  Map <String, dynamic> parameters, DateTime dateTime, int functionIndex)
      : super(serviceName, estateId, id, recurring, parameters, dateTime, functionIndex);


  @override
  void updateNextExecution() {
    DateTime now = DateTime.now();
    nextExecution = DateTime(now.year, now.month, now.day, hour, minute);
    if (nextExecution.isBefore(now)) {
      nextExecution = nextExecution.add(Duration(days: 1));
    }
  }

  @override
  IconData icon() {
    return Icons.calendar_today;
  }

  @override
  String toString() {
    return '(daily task: $serviceName, at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} nextExecution: ${nextExecution.toString()})';
  }

  @override
  String description(Map <String, dynamic> parameters) {
    bool _powerOn = parameters[powerOn] ?? false;
    String serviceName = parameters[serviceNameKey] ?? '';
    switch (serviceName) {
      case electricityPriceForegroundService:
        return 'Tieto haetaan noin kello ${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}.';
      case standardForegroundService:
        return 'Asetetaan ${_powerOn ? 'päälle' : 'pois päältä'} noin kello ${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}.';
      default:
        return 'foreground service description missing: $serviceName';
    }
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['hour'] = hour;
    json['minute'] = minute;
    return json;
  }

  @override
  TimeOfDayTask.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    hour = json['hour'] ?? 0;
    minute = json['minute'] ?? 0;
  }
}

const int _noExecutionValue = 9999;

class PriceTask extends TaskItem {

  SpotCondition condition = SpotCondition();
  ElectricityPriceData electricityPriceData = ElectricityPriceData();

  PriceTask(String serviceName, String estateId, String id, bool recurring, Map <String, dynamic> parameters, DateTime dateTime, int functionIndex, ElectricityPriceData initElectricityPriceData)
      : super(serviceName, estateId, id, recurring, parameters, dateTime, functionIndex) {
    condition = SpotCondition.fromJson(parameters[priceComparisonTypeKey] ?? {});
    electricityPriceData = initElectricityPriceData;
  }

  bool findNextExecution(int firstIndex) {
    for (int index = firstIndex+1; index < electricityPriceData.prices.length; index++) {
      double totalPrice = electricityPriceData.prices[index].totalPrice;
      if (noValue(totalPrice)) {
        // don't use this data
      } else if (condition.isTrue(totalPrice, electricityPriceData)) {
        nextExecution = electricityPriceData.slotStartingTime(index);
        return true;
      }
    }
    return false;
  }

  @override
  void updateNextExecution() {

    int nextExecutionIndex = electricityPriceData.findIndex(nextExecution);
    if (nextExecutionIndex < 0) { // not existing  data
      return;
    }

    bool updated = findNextExecution(nextExecutionIndex+1);

    if (!updated) {
      // next execution time not found - update to a future date
      nextExecution = DateTime(_noExecutionValue);
    }
  }

  void updateAfterPriceDataUpdate(DateTime now) {
    int nextExecutionIndex = 0;
    if (nextExecution.year != _noExecutionValue) {
      nextExecutionIndex = electricityPriceData.findIndex(nextExecution);
    }
    else {
      nextExecutionIndex = electricityPriceData.findIndex(now);
    }
    bool updated = findNextExecution(nextExecutionIndex);

    if (!updated) {
      // next execution time not found - update to a future date
      nextExecution = DateTime(_noExecutionValue);
    }
  }

  @override
  IconData icon() {
    return Icons.trending_up;
  }

  @override
  String toString() {
    return '(price task: $serviceName, at ${nextExecution.hour.toString().padLeft(2, '0')}:${nextExecution.minute.toString().padLeft(2, '0')} nextExecution: ${nextExecution.toString()})';
  }

  @override
  String description(Map <String, dynamic> parameters) {
    bool toPowerOn = parameters[powerOn] ?? false;
    SpotCondition spotCondition = SpotCondition.fromJson(parameters[priceComparisonTypeKey]);

    return 'Asetetaan ${toPowerOn ? 'päälle' : 'pois päältä'}, kun sähkön hinta muuttuu ${spotCondition.comparison.changeText()} ${currencyCentInText(spotCondition.parameterValue)}.';
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  PriceTask.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
  }
}


TaskItem extendedTaskItemFromJson( Map<String, dynamic> json) {
  String myType = json['runtimeType'] ?? '';
  switch (myType) {
    case 'TaskItem':
      return TaskItem.fromJson(json);
    case 'IntervalTask':
      return IntervalTask.fromJson(json);
    case 'TimeOfDayTask':
      return TimeOfDayTask.fromJson(json);
    case 'PriceTask':
      return PriceTask.fromJson(json);
    default:
      print('unknown task type: $myType');
  }
  return TaskItem.fromJson(json);
}

class TaskList {
  List <TaskItem> tasks = [];

  TaskList();

  // removes all 'removeThis' marked tasks. Return true if any task was removed
  bool removeMarked() {
    int nbrOfItems = tasks.length;
    tasks.removeWhere((task) => task.removeThis);
    return tasks.length != nbrOfItems;
  }

  bool noTasks() {
    return (tasks.isEmpty);
  }

  int nbrOfTasks() {
    return (tasks.length);
  }

  String taskTitle(int index) {
    String serviceName = foregroundServiceNames[tasks[index].serviceName] ?? 'Puuttuva kuvaus';
    return ('${serviceName}');
  }

  String taskDescription(int index) {
    return ('${tasks[index].nextExecutionString()}\n'
        '${tasks[index].description(tasks[index].parameters)}');
  }

  IconData taskIcon(int index) {
    return (tasks[index].icon());
  }


  Map<String, dynamic> toJson() {
    return {
      'tasks': tasks.map((task) => task.toJson()).toList(),};
  }

  TaskList.fromJson(Map<String, dynamic> json) {
    tasks = List.from(json['tasks']).map((taskJson) => extendedTaskItemFromJson(taskJson)).toList();
  }
}

