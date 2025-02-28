/*

import 'package:hive_flutter/hive_flutter.dart';
import 'package:koti/app_configurator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../trend/trend_event.dart';
import 'observation.dart';

const String taskPrefix = 'com.mosahybrid.koti';
const String testTask = '$taskPrefix.test';
const String test2Task = '$taskPrefix.test2';
const String oumanTask = '$taskPrefix.ouman';

Future <void> initHiveForWorkmanager() async {
  await Hive.initFlutter();
  initHiveAdapters();
}

class WorkmanagerTrendEventBox {

  late Box<TrendEvent> box;

  Future<void> init() async {
    await Hive.openBox<TrendEvent>(hiveTrendEventName);
    box = Hive.box<TrendEvent>(hiveTrendEventName);
  }

}


@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {

    for (int index=0; index<workmanagerTasks.length;index++) {
      if (workmanagerTasks[index] == task) {
        return await workmanagerFunctions[index](task, inputData);
      }
    }
    switch (task) {
      case testTask:
        {
          print("$testTask was executed. inputData = $inputData");
          final prefs = await SharedPreferences.getInstance();
          prefs.setInt("test", 1);
          print("Int from prefs in workmanager: ${prefs.getInt("test") ?? 99}");
          break;
        }
      case test2Task: {

        final prefs = await SharedPreferences.getInstance();
        prefs.setInt("test2", 1);
        print("$test2Task was started. inputData = $inputData");
        prefs.setInt("test2", 2);
        await initHiveForWorkmanager();
        prefs.setInt("test2", 3);
        await Hive.openBox<TrendEvent>(hiveTrendEventName);
        prefs.setInt("test2", 4);
        Box<TrendEvent> myBox = Hive.box<TrendEvent>(hiveTrendEventName);
        prefs.setInt("test2", 5);
        print("$test2Task 2 boxin koko: ${myBox.length}");
        prefs.setInt("test2", 6);
        await myBox.add(TrendEvent(DateTime.now().millisecondsSinceEpoch,
            '',
            '',
            ObservationLevel.ok,
            'testiloki'));
        prefs.setInt("test2", 7);
        print("$test2Task 3 boxin koko: ${myBox.length}");
        print("$test2Task was executed. inputData = $inputData");

      }

      default:
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt("test2", 111);
        print("default $task was found. inputData = $inputData");
        break;
    }
    return Future.value(true);
  });
}

class MyWorkManager {
  void initialize() {
    Workmanager().initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );
  }

  cancelTask(String uniqueTaskName) {
    Workmanager().cancelByUniqueName(uniqueTaskName);
  }

  void registerPeriodicTask(
    String uniqueName,
    String taskName, {
    required Map <String, dynamic> inputData,
    required Duration initialDelay,
    required Duration frequency
  }
  ) {
    cancelTask(uniqueName);
    Workmanager().registerPeriodicTask(
      uniqueName,
      taskName,
      initialDelay: initialDelay,
      inputData: inputData,
      frequency: frequency
    );
  }

  void test1() {
    Workmanager().registerOneOffTask(
        testTask,
        testTask,
        inputData: <String, dynamic>{
        'int': 1,
        'bool': true,
        'double': 1.0,
        'string': 'string',
        'array': [1, 2, 3],
        }
    );
  }

  void test2() {
    Workmanager().registerOneOffTask(
        test2Task,
        test2Task,
        inputData: <String, dynamic>{
          'int': 1,
          'bool': true,
          'double': 1.0,
          'string': 'string',
          'array': [1, 2, 3],
        },
        initialDelay: const Duration(seconds:10)
    );
  }

}

MyWorkManager myWorkManager = MyWorkManager();

 */

