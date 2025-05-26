import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';

import '../foreground_configurator.dart';
import '../logic/events.dart';
import '../logic/my_change_notifier.dart';
import '../logic/observation.dart';
import '../logic/task_handler_controller.dart';
import '../logic/task_list.dart';
import '../look_and_feel.dart';
import '../my_task_handler.dart';


class ForegroundNotifier extends MyChangeNotifier<Map<String, dynamic>> {
  ForegroundNotifier(super.initData);
}

class ForegroundServiceMessageData {
  String serviceName = '';
  String id = '';
  String deviceId = '';
  ForegroundNotifier _parameterNotifier = ForegroundNotifier({});

  ForegroundServiceMessageData(Map<String, dynamic> data) {
    serviceName = data[serviceNameKey] ?? '';
    id = data[idKey] ?? '';
    deviceId = foregroundExtractDeviceId(id);
    _parameterNotifier.changeData(data);
  }

  ForegroundServiceMessageData.deviceInit(String initServiceName, String initDeviceId) {
    serviceName = initServiceName;
    deviceId = initDeviceId;
    _parameterNotifier.changeData({});
  }

}

class ForegroundData {
  List<ForegroundServiceMessageData> serviceData = [];

  void receiveDataFromForegroundService(Map<String, dynamic> data) {
    String serviceName = data[serviceNameKey] ?? '';
    String id = data[idKey] ?? '';
    String deviceId = foregroundExtractDeviceId(id);


    int index = serviceData.indexWhere((item) => ((item.serviceName == serviceName) && (item.deviceId == deviceId)));

    if (index == -1) {
      serviceData.add(ForegroundServiceMessageData(data));
    }
    else {
      serviceData[index]._parameterNotifier.changeData(data);
    }
  }


  StreamSubscription<Map<String, dynamic>> setServiceListener(String serviceName, String deviceId, Function(Map<String, dynamic>) listeningFunction) {

    int index = serviceData.indexWhere((item) => ((item.serviceName == serviceName) && (item.deviceId == deviceId)));

    if (index == -1) {
      serviceData.add(ForegroundServiceMessageData.deviceInit(serviceName, deviceId));
      index = serviceData.length - 1;
    }

    return serviceData[index]._parameterNotifier.setListener(listeningFunction);
  }

}

class ForegroundTasksNotifier extends ChangeNotifier {
  TaskList _data = TaskList();
  ForegroundTasksNotifier();

  TaskList get data => _data;

  void changeData(TaskList newData) {
    _data = newData;
    notifyListeners();
  }

  set data (TaskList newData) => changeData(newData);

}

class ForegroundInterface {

  bool dataReceivedFromForegroundService = false;
  ForegroundTasksNotifier foregroundTasksNotifier = ForegroundTasksNotifier();
  ForegroundData foregroundData = ForegroundData();

  bool noTasks() {
    return (foregroundTasksNotifier.data.tasks.isEmpty);
  }

  int nbrOfTasks() {
    return (foregroundTasksNotifier.data.tasks.length);
  }

  String taskTitle(int index) {
    String serviceName = foregroundServiceNames[foregroundTasksNotifier.data.tasks[index].serviceName] ?? 'Puuttuva kuvaus';
    return ('${serviceName}');
  }

  String taskDescription(int index) {
    return ('${foregroundTasksNotifier.data.tasks[index].nextExecutionString()}\n'
            '${foregroundTasksNotifier.data.tasks[index].description(foregroundTasksNotifier.data.tasks[index].parameters)}');
  }

  IconData taskIcon(int index) {
    return (foregroundTasksNotifier.data.tasks[index].icon());
  }

  void _onReceiveTaskData(Object data) {
    print('main.foregroundInterface.onReceiveTaskData');
    if (data is Map<String, dynamic>) {
      String _receivedMessageKey = data[messageKey] ?? '';
      if (_receivedMessageKey == messageData ) {
        dataReceivedFromForegroundService = true;
        foregroundTasksNotifier.data = TaskList.fromJson(data[dataKey] ?? {})
        ;
      }
      else if (_receivedMessageKey == responseMessage) {
        foregroundData.receiveDataFromForegroundService(data);
      }
      else {
        events.write('', '', ObservationLevel.alarm, "Foreground Interface received data of unknown type: $_receivedMessageKey");
      }

    }
    else {
      events.write('', '', ObservationLevel.alarm, "Foreground Interface received data of unknown type format");
    }
  }


  void _initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
        'This notification appears when the foreground service is running.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(60*1000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<ServiceRequestResult> _startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: '$appName on käynnissä taustalla',
        notificationText: 'Siirry $appName sovellukseen',
        notificationIcon: null,
        notificationButtons: [
          const NotificationButton(id: 'btn_hello', text: 'Moi Anu'),
        ],
        notificationInitialRoute: '/',
        callback: startCallback,
      );
    }
  }

  Future<void> init() async {

    // Request permissions and initialize the service.
    _initService();
    ServiceRequestResult result = await _startService();

    // Add a callback to receive data sent from the TaskHandler.
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

  }
  Future<void> initDataStructures() async {
    await sendData('readDataStructure',{});
  }

  Future<bool> sendData(String serviceName, Map<String, dynamic> parameters) async {
    Map<String,dynamic> data = defineForegroundTask(readDataStructureKey, '', {});
    FlutterForegroundTask.sendDataToTask(data);
    return true;
  }

  Future<bool> defineRecurringService(String serviceName, int intervalInMinutes, Map<String, dynamic> parameters) async {
    var data = defineForegroundTask(intervalServiceKey, serviceName, parameters);
    data[intervalInMinutesKey] = intervalInMinutes;
    data[recurringKey] = true;
    FlutterForegroundTask.sendDataToTask(data);
    return true;
  }

  Future<bool> defineDailyRecurringService(String serviceName, TimeOfDay timeOfDay, Map<String, dynamic> parameters) async {
    var data = defineForegroundTask(timeOfDayServiceKey, serviceName, parameters);
    data[timeOfDayHourKey] = timeOfDay.hour;
    data[timeOfDayMinuteKey] = timeOfDay.minute;
    data[recurringKey] = true;
    print('define Daily data: $data');
    FlutterForegroundTask.sendDataToTask(data);
    return true;
  }

  Future<bool> defineUserTask(String serviceName, Map<String, dynamic> parameters) async {
    var data = defineForegroundTask(userTaskKey, serviceName, parameters);
    FlutterForegroundTask.sendDataToTask(data);
    return true;

  }

  void dispose() {
    // Remove a callback to receive data sent from the TaskHandler.
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
  }
}

ForegroundInterface foregroundInterface = ForegroundInterface();

class ForegroundStandardTask {

  List <String> messages = [];

  String errorClarification = '';

  Future <String> rpcCall(String fullCommandLine) async {
    // todo: should we somehow check the state of the target device

    try {
      var uri = Uri.parse(fullCommandLine);
      final response = await http.get(uri,
          headers: {
            'Content-type': 'application/json; charset=UTF-8'
          });
      if (response.statusCode == 200) {
        String responseString = response.body.toString();
        return responseString;
      }
      else {
        errorClarification = 'statusCode = ${response.statusCode}';
        var x = utf8.decode(response.bodyBytes);
        if (response.statusCode != 500) {
          // status code 500 is a normal response with non existence service
          log.error(
              'foregroundStandardTask: $fullCommandLine/rpcCall error: $errorClarification, ${x
                  .toString()}');
          log.info(uri.toString());
        }
        else {
          log.info(
              'foregroundStandardTask: $fullCommandLine VÄLIAIKAINEN JOTTA TIETÄÄ, PALJON NÄITÄ TULEE.../rpcCall error: $errorClarification, ${x
                  .toString()}');
          log.info(uri.toString());
        }
        return '';
      }
    }
    catch (e, st) {
      log.handle(e, st,
          'exception in foregroundStandardTask: "$fullCommandLine", clarification: "$errorClarification"');
      errorClarification = 'exception $e';
      return '';
    }
  }

  Future<bool> execute() async {
    bool success = true;
    for (var message in messages) {
      String result = await rpcCall(message);
      success = success && result.isNotEmpty;
    }
    return success;
  }

  ForegroundStandardTask.fromJson(Map<String, dynamic> json) {
    messages = List<String>.from(json[messagesParameter] ?? []);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[messagesParameter] = messages;
    return json;
  }
}

Future<bool> foregroundStandardTaskInitFunction(TaskHandlerController controller, Map<String, dynamic> inputData) async {
  return await foregroundStandardTaskExecutionFunction(controller, inputData);
}

Future<bool> foregroundStandardTaskExecutionFunction(TaskHandlerController controller,Map<String, dynamic> inputData) async {
  ForegroundStandardTask standardTask = ForegroundStandardTask.fromJson(inputData);
  print('foregroundStandardTaskExecutionFunction');
  await standardTask.execute();

  return true;
}
