// used from foreground service => no global data & service use
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_foreground_task/task_handler.dart';


import '../app_configurator.dart';
import '../foreground_configurator.dart';

class TaskServiceFunction {
  String serviceName = '';
  Future<bool> Function(Map <String, dynamic>) initFunction;
  Future<bool> Function(Map <String, dynamic>) executionFunction;
  TaskServiceFunction(this.serviceName, this.initFunction, this.executionFunction);
}

class TaskServiceFunctions {
  List <TaskServiceFunction> taskServiceFunctions = [];

  void clear() => taskServiceFunctions.clear();

  void add(String taskServiceName, Future<bool> Function(Map <String, dynamic>) initFunction, Future<bool> Function(Map <String, dynamic>) executionFunction) {
    taskServiceFunctions.add(TaskServiceFunction(taskServiceName, initFunction, executionFunction));
  }

  Future<bool> Function(Map <String, dynamic>) getInitFunction(String serviceName) {
    for (var taskServiceFunction in taskServiceFunctions) {
      print('serviceName=$serviceName and taskServiceFunction.serviceName= ${taskServiceFunction.serviceName}');
      if (taskServiceFunction.serviceName == serviceName) {
        return taskServiceFunction.initFunction;
      }
    }
    print('No task init function found for service: $serviceName');
    return _dummy;
  }

  Future<bool> Function(Map <String, dynamic>)  getExecutionFunction(String serviceName) {
    for (var taskServiceFunction in taskServiceFunctions) {
      print('serviceName=$serviceName and taskServiceFunction.serviceName= ${taskServiceFunction.serviceName}');
      if (taskServiceFunction.serviceName == serviceName) {
        return taskServiceFunction.executionFunction;
      }
    }
    print('No task execution function found for service: $serviceName');
    return _dummy;
  }

}
Future<bool> _dummy (Map<String, dynamic> data) async { return false;}

TaskServiceFunctions taskFunctions = TaskServiceFunctions();

class TaskItem {
  String serviceName;
  Map <String, dynamic> parameters = {};

  DateTime nextExecution = DateTime.now();
  Future<bool> Function(Map <String, dynamic>) taskExecutionFunction = _dummy;

  TaskItem(this.serviceName, this.parameters) {
    print('TaskItem: $serviceName');
    taskExecutionFunction = taskFunctions.getExecutionFunction(serviceName);
  }

  void updateNextExecution() {
    print('task item ${this.runtimeType.toString()} missing updateNextExecution');
  }

  @override
  String toString() {
    return '(taskName: $serviceName, nextExecution: ${nextExecution.toString()})';
  }
}

class RecurringTask extends TaskItem {
  int intervalInMinutes;

  RecurringTask(String taskName, this.intervalInMinutes, Map <String, dynamic> parameters) : super(taskName, parameters);


  @override
  void updateNextExecution() {
    nextExecution = nextExecution.add(Duration(minutes: intervalInMinutes));
  }

  @override
  String toString() {
    return '(recurring task: $serviceName, intervalInMinutes: $intervalInMinutes, nextExecution: ${nextExecution.toString()})';
  }
}

class DailyRecurringTask extends TaskItem {
  int hour = 0;
  int minute = 0;

  DailyRecurringTask(String taskName, this.hour, this.minute,  Map <String, dynamic> parameters) : super(taskName, parameters);


  @override
  void updateNextExecution() {
    DateTime now = DateTime.now();
    nextExecution = DateTime(now.year, now.month, now.day, hour, minute);
    if (nextExecution.isBefore(now)) {
      nextExecution = nextExecution.add(Duration(days: 1));
    }
  }

  @override
  String toString() {
    return '(daily task: $serviceName, at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} nextExecution: ${nextExecution.toString()})';
  }
}


class TaskHandlerController {

  List <TaskItem> tasks = [];

  bool appInitiated = false;

  int counter = 10;

  TaskHandlerController() {
    createFunctionTable();
  }

  @override
  String toString() {
    return tasks.toString();
  }

  Future <void> initOnStart(DateTime timestamp, TaskStarter starter) async {
    await Hive.initFlutter();
    initHiveAdapters();
    appInitiated = (starter == TaskStarter.developer);
    counter++;
  }

  void _onRecurringService(Map<String, dynamic> data) {
    final String serviceName = data[serviceNameKey] ?? 'serviceNameNotFound';
    final int intervalInMinutes = data[intervalInMinutesKey] ?? 9999;
    print('onRecurringService: $serviceName, $intervalInMinutes, $counter');
    int index = tasks.indexWhere((element) => element.serviceName == serviceName);

    if (index >= 0) {
      tasks.removeAt(index);
    }
    tasks.add(RecurringTask(serviceName, intervalInMinutes, data));
    taskFunctions.getInitFunction(serviceName)(data);
  }

  void _onDailyRecurringService(Map<String, dynamic> data) {
    final String serviceName = data[serviceNameKey] ?? 'serviceNameNotFound';
    final int hour = data[timeOfDayHourKey] ?? 12;
    final int minute = data[timeOfDayMinuteKey] ?? 00;
    print('onDailyRecurringService: $serviceName, $hour:$minute, $counter');
    int index = tasks.indexWhere((element) => element.serviceName == serviceName);

    if (index >= 0) {
      tasks.removeAt(index);
    }
    tasks.add(DailyRecurringTask(serviceName, hour, minute, data));
    taskFunctions.getInitFunction(serviceName)(data);
  }

  void _onReadDataStructure() {
    print('readDataStructure');
  }

  void onReceiveControl(Map <String, dynamic> data) {
    counter++;
    print('onReceiveControlA: $counter' );
    final String taskName = data[taskNameKey];
    print('onReceiveControlB: $taskName');
    switch (taskName) {
      case readDataStructureKey:
        _onReadDataStructure();
        break;
      case recurringServiceKey:
        _onRecurringService(data);
        break;
      case dailyRecurringServiceKey:
        _onDailyRecurringService(data);
        break;
      default:
        print('Unknown task name: $taskName');
    }
  }

  Future <void> onRepeatEvent(DateTime timestamp) async {

    print('#ofTasks = ${tasks.length}');
    for (var task in tasks) {
      if (timestamp.isAfter(task.nextExecution)) {
        // next execution time has passed
        print('next execution time has passed: $task');
        bool success = await task.taskExecutionFunction(task.parameters);
        if (success) {
          // if successful task execution, update next execution time, otherwise
          // leave the tasks in the list => it will be called again in the round
          task.updateNextExecution();
        }
      }
    }
  }


}