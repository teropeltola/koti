// used from foreground service => no global data & service use
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_foreground_task/task_handler.dart';
import 'package:koti/logic/price_collection.dart';
import 'package:koti/logic/task_list.dart';
import 'package:koti/operation_modes/conditional_operation_modes.dart';


import '../app_configurator.dart';
import '../foreground_configurator.dart';
import '../functionalities/electricity_price/trend_electricity.dart';
import 'electricity_price_data.dart';

class TaskServiceFunction {
  String serviceName = '';
  Future<bool> Function(TaskHandlerController, Map <String, dynamic>) initFunction;
  Future<bool> Function(TaskHandlerController, Map<String, dynamic>) executionFunction;
  TaskServiceFunction(this.serviceName, this.initFunction, this.executionFunction);
}

class TaskServiceFunctions {
  List <TaskServiceFunction> taskServiceFunctions = [];

  void clear() => taskServiceFunctions.clear();

  void add(String taskServiceName, Future<bool> Function(TaskHandlerController, Map <String, dynamic>) initFunction, Future<bool> Function(TaskHandlerController, Map <String, dynamic>) executionFunction) {
    taskServiceFunctions.add(TaskServiceFunction(taskServiceName, initFunction, executionFunction));
  }

  Future <bool> Function(TaskHandlerController, Map <String, dynamic>) getInitFunction(String serviceName) {
    for (var taskServiceFunction in taskServiceFunctions) {
      //print('serviceName=$serviceName and taskServiceFunction.serviceName= ${taskServiceFunction.serviceName}');
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
Future<bool> _dummy (TaskHandlerController, Map<String, dynamic> data) async { return false;}


class TaskHandlerController {

  TaskList taskList = TaskList();
  TaskServiceFunctions taskFunctions = TaskServiceFunctions();

  PriceCollection priceCollection = PriceCollection();

  bool appInitiated = false;

  int counter = 10;

  TaskHandlerController() {
    createFunctionTable(this.taskFunctions);
  }

  @override
  String toString() {
    return taskList.toString();
  }

  Future <void> initOnStart(DateTime timestamp, TaskStarter starter, bool unitTesting) async {
    if (! unitTesting) {
      await Hive.initFlutter();
      initHiveAdapters();
    }
    appInitiated = (starter == TaskStarter.developer);
    counter++;
  }

  void _removeExistingService(String id) {

    int index = taskList.tasks.indexWhere((element) => element.taskId == id);

    if (index >= 0) {
      taskList.tasks.removeAt(index);
    }
  }


  // this is called whenever the price list is updated (once a day)
  void updatePriceData(DateTime now, String estateId, List<TrendElectricity> trendElectricity) {
    priceCollection.updateEstateData(estateId, trendElectricity);

    for (var task in taskList.tasks) {
      if ((task.runtimeType == PriceTask) && (task.estateId == estateId)) {
        // possible update the next execution time
        (task as PriceTask).updateAfterPriceDataUpdate(now);
      }
    }
  }

  void _onIntervalService(DateTime now, Map<String, dynamic> data) {
    final String serviceName = data[serviceNameKey] ?? 'serviceNameNotFound';
    final String id = data[idKey] ?? 'idNotFound';
    final String estateId = data[estateIdKey] ?? 'estateIdNotFound';
    final bool recurring = data[recurringKey] ?? true;
    final int intervalInMinutes = data[intervalInMinutesKey] ?? 9999;
    print('IntervalService: $serviceName, $intervalInMinutes, ${recurring ? 'recurring' : 'not recurring'}, $counter');
    _removeExistingService(id);

    taskList.tasks.add(IntervalTask(serviceName, estateId, id, recurring, intervalInMinutes, data, now,taskFunctions.getExecutionFunctionIndex(serviceName)));
    taskFunctions.getInitFunction(serviceName)(this, data);
  }

  void _onTimeOfDayService(DateTime now, Map<String, dynamic> data) {
    final String serviceName = data[serviceNameKey] ?? 'serviceNameNotFound';
    final String estateId = data[estateIdKey] ?? 'estateIdNotFound';
    final String id = data[idKey] ?? 'idNotFound';
    final bool recurring = data[recurringKey] ?? true;

    final int hour = data[timeOfDayHourKey] ?? 12;
    final int minute = data[timeOfDayMinuteKey] ?? 00;
    print('onDailyRecurringService: $serviceName, $hour:$minute, ${recurring ? 'recurring' : 'not recurring'} $counter');

    _removeExistingService(id);

    taskList.tasks.add(TimeOfDayTask(serviceName, estateId, id, recurring, hour, minute, data, now, taskFunctions.getExecutionFunctionIndex(serviceName)));
    taskFunctions.getInitFunction(serviceName)(this, data);
  }

  void _onPriceService(DateTime now, Map<String, dynamic> data) {
    final String serviceName = data[serviceNameKey] ?? 'serviceNameNotFound';
    final String id = data[idKey] ?? 'idNotFound';
    final bool recurring = data[recurringKey] ?? true;
    final String estateId = data[estateIdKey] ?? 'estateIdNotFound';

    print('onPriceService: $serviceName, ${recurring ? 'recurring' : 'not recurring'} $counter');

    _removeExistingService(id);

    PriceTask priceTask = PriceTask(serviceName, estateId, id, recurring, data, now,
        taskFunctions.getExecutionFunctionIndex(serviceName),
        priceCollection.getEstateData(estateId).electricityPriceData);

    taskList.tasks.add(priceTask);

    priceTask.updateAfterPriceDataUpdate(now); // updating the first execution time
  }

  void _onUserTask(DateTime now, Map<String, dynamic> data) {
    final bool isPriceService = (data[priceComparisonTypeKey] != null);
    if (isPriceService) {
      _onPriceService(now, data);
    }
    else {
      final bool timeOfDay = (data[timeOfDayHourKey] != null);
      if (timeOfDay) {
        _onTimeOfDayService(now, data);
      }
      else {
        _onIntervalService(now, data);
      }
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

  Map <String, dynamic> onReceiveControl(DateTime now, Map <String, dynamic> data) {
    counter++;
    print('onReceiveControlA: $counter' );
    final String taskName = data[taskNameKey] ?? 'taskNameNotFound';
    print('onReceiveControlB: $taskName');
    switch (taskName) {
      case readDataStructureKey:
        return _onReadDataStructure();
        break;
      case intervalServiceKey:
        _onIntervalService(now, data);
        break;
      case timeOfDayServiceKey:
        _onTimeOfDayService(now, data);
        break;
      case userTaskKey:
        _onUserTask(now, data);
        break;

      default:
        print('Unknown task name: $taskName');
    }
    return {};
  }

  // onRepeatEvent is the main iteration function in foreground.
  // The system invokes it in the frequently set interval.
  Future <void> onRepeatEvent(DateTime timeOfEvent) async {
    bool updateMainTask = false;
    bool tasksToBeRemoved = false;

    print('#ofTasks = ${taskList.tasks.length}');
    for (var task in taskList.tasks) {

      if (timeOfEvent.isAfter(task.nextExecution)) {
        // next execution time has passed
        print('next execution time has passed: $task');
        bool success = await taskFunctions.taskServiceFunctions[task.taskExecutionFunctionIndex].executionFunction(this, task.parameters);
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