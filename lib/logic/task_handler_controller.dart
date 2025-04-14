// used from foreground service => no global data & service use
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_foreground_task/task_handler.dart';
import 'package:koti/logic/price_collection.dart';
import 'package:koti/logic/task_list.dart';


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

  int getExecutionFunctionIndex(String serviceName) {
    for (int index=0; index < taskServiceFunctions.length; index++) {
      if (taskServiceFunctions[index].serviceName == serviceName) {
        return index;
      }
    }
    print('No task execution function found for service: $serviceName');
    return -1;
  }

}
Future<bool> _dummy (Map<String, dynamic> data) async { return false;}

TaskServiceFunctions taskFunctions = TaskServiceFunctions();

PriceCollection priceCollection = PriceCollection();


class TaskHandlerController {

  TaskList taskList = TaskList();

  bool appInitiated = false;

  int counter = 10;

  TaskHandlerController() {
    createFunctionTable();
  }

  @override
  String toString() {
    return taskList.toString();
  }

  Future <void> initOnStart(DateTime timestamp, TaskStarter starter) async {
    await Hive.initFlutter();
    initHiveAdapters();
    appInitiated = (starter == TaskStarter.developer);
    counter++;
  }

  void _removeExistingService(String id) {

    int index = taskList.tasks.indexWhere((element) => element.id == id);

    if (index >= 0) {
      taskList.tasks.removeAt(index);
    }
  }

  void _onIntervalService(Map<String, dynamic> data) {
    final String serviceName = data[serviceNameKey] ?? 'serviceNameNotFound';
    final String id = data[idKey] ?? 'idNotFound';
    final bool recurring = data[recurringKey] ?? true;
    final int intervalInMinutes = data[intervalInMinutesKey] ?? 9999;
    print('IntervalService: $serviceName, $intervalInMinutes, ${recurring ? 'recurring' : 'not recurring'}, $counter');
    _removeExistingService(data[idKey]);

    taskList.tasks.add(IntervalTask(serviceName, id, recurring, intervalInMinutes, data, DateTime.now(),taskFunctions.getExecutionFunctionIndex(serviceName)));
    taskFunctions.getInitFunction(serviceName)(data);
  }

  void _onTimeOfDayService(Map<String, dynamic> data) {
    final String serviceName = data[serviceNameKey] ?? 'serviceNameNotFound';
    final String id = data[idKey] ?? 'idNotFound';
    final bool recurring = data[recurringKey] ?? true;

    final int hour = data[timeOfDayHourKey] ?? 12;
    final int minute = data[timeOfDayMinuteKey] ?? 00;
    print('onDailyRecurringService: $serviceName, $hour:$minute, ${recurring ? 'recurring' : 'not recurring'} $counter');

    _removeExistingService(data[idKey]);

    taskList.tasks.add(TimeOfDayTask(serviceName, id, recurring, hour, minute, data, DateTime.now(), taskFunctions.getExecutionFunctionIndex(serviceName)));
    taskFunctions.getInitFunction(serviceName)(data);
  }

  void _onUserTask(Map<String, dynamic> data) {
    final bool timeOfDay = (data[timeOfDayHourKey] != null);
    if (timeOfDay) {
      _onTimeOfDayService(data);
    }
    else {
      _onIntervalService(data);
    }
  }

  Map <String, dynamic> _onReadDataStructure() {
    final Map<String,dynamic> data = {
      messageKey: messageData,
      dataKey: taskList.toJson(),
    };
    print('TaskHandlerController.onReadDataStructure');
    return data;
  }

  Map <String, dynamic> onReceiveControl(Map <String, dynamic> data) {
    counter++;
    print('onReceiveControlA: $counter' );
    final String taskName = data[taskNameKey] ?? 'taskNameNotFound';
    print('onReceiveControlB: $taskName');
    switch (taskName) {
      case readDataStructureKey:
        return _onReadDataStructure();
        break;
      case intervalServiceKey:
        _onIntervalService(data);
        break;
      case timeOfDayServiceKey:
        _onTimeOfDayService(data);
        break;
      case userTaskKey:
        _onUserTask(data);
        break;

      default:
        print('Unknown task name: $taskName');
    }
    return {};
  }

  // onRepeatEvent is the main iteration function in foreground.
  // The system invokes it in the frequently set interval.
  Future <void> onRepeatEvent(DateTime timestamp) async {
    bool updateMainTask = false;
    bool tasksToBeRemoved = false;

    print('#ofTasks = ${taskList.tasks.length}');
    for (var task in taskList.tasks) {

      if (timestamp.isAfter(task.nextExecution)) {
        // next execution time has passed
        print('next execution time has passed: $task');
        bool success = await taskFunctions.taskServiceFunctions[task.taskExecutionFunctionIndex].executionFunction(task.parameters);
        if (success) {
          // if not successful, then we leave the task in the list => it will be
          // called again in the round
          updateMainTask = true;

          if (task.recurring) {
            task.updateNextExecution();
          }
          else {
            task.removeThis = true;
            tasksToBeRemoved = true;
          }
        }
      }
    }
    if (tasksToBeRemoved) {
      taskList.removeMarked();
    }
    if (updateMainTask) {
      FlutterForegroundTask.sendDataToMain(_onReadDataStructure());
    }
  }


}