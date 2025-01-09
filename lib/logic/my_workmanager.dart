import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:koti/app_configurator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../trend/trend_event.dart';
import 'observation.dart';

const String taskPrefix = 'com.mosahybrid.koti';
const String testTask = '$taskPrefix.test';
const String test2Task = '$taskPrefix.test2';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
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
        await Hive.initFlutter();
        initHiveAdapters();
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
        initialDelay: Duration(seconds:10)
    );
  }

}

MyWorkManager myWorkManager = MyWorkManager();

/*
// In your WorkManager task:
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> myWorkManagerTask() async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/workmanager_data.txt';
  final data = '{"message": "Task completed!"}';

  File file = File(filePath);
  await file.writeAsString(data);
}

// In your UI:
import 'dart:io';
import 'package:path_provider/path_provider/path_provider.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _message = '';

  Future<void> _readData() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/workmanager_data.txt';
    File file = File(filePath);

    if (await file.exists()) {
      String contents = await file.readAsString();
      // Parse the JSON string (if applicable)
      Map<String, dynamic> jsonData = jsonDecode(contents);
      setState(() {
        _message = jsonData['message'];
      });
      // Delete the file after reading
      await file.delete();
    }
  }

  @override
  void initState() {
    super.initState();
    // Periodically check for updates (adjust interval as needed)
    Timer.periodic(Duration(seconds: 5), (_) => _readData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(_message),
      ),
    );
  }
}

 */