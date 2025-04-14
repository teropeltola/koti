// The callback function should always be a top-level or static function.
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'logic/task_handler_controller.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {

  TaskHandlerController taskHandlerController = TaskHandlerController();

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('onStart(starter: ${starter.name})');
    await taskHandlerController.initOnStart(timestamp, starter);
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {
    print('onRepeatEvent: $timestamp/${taskHandlerController.toString()}');
    taskHandlerController.onRepeatEvent(timestamp);
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('onDestroy');
  }

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) {
    print('MyTaskHandler.onReceiveData: ${data.runtimeType.toString()}/$data');
    if (data is Map<String, dynamic>) {
      Map<String, dynamic> response = taskHandlerController.onReceiveControl(data);
      print('MyTaskHandler: response=$response');
      if (response.isNotEmpty) {
        print('MyTaskHandler: response=$response');
        FlutterForegroundTask.sendDataToMain(response);
      }
    }
    else {
      print('Unknown data type: ${data.runtimeType.toString()}');
    }
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {
    print('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }
}