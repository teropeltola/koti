import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../foreground_configurator.dart';
import '../look_and_feel.dart';
import '../my_task_handler.dart';

class ForegroundInterface {

  void _onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      final dynamic timestampMillis = data["timestampMillis"];
      if (timestampMillis != null) {
        final DateTime timestamp =
        DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true);
        print('timestamp: ${timestamp.toString()}');
      }
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
    // Add a callback to receive data sent from the TaskHandler.
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

    // Request permissions and initialize the service.
    _initService();
    var result = await _startService();
    print('startService result: ${result.toString()}');
  }

  Future<bool> sendData(String serviceName, Map<String, dynamic> parameters) async {
    Map<String,dynamic> data = {};
    data['serviceName'] = serviceName;
    FlutterForegroundTask.sendDataToTask(data);
    return true;
  }

  Future<bool> defineRecurringService(String serviceName, int intervalInMinutes, Map<String, dynamic> parameters) async {
    var data = defineForegroundTask(recurringServiceKey, serviceName, parameters);
    data[intervalInMinutesKey] = intervalInMinutes;
    FlutterForegroundTask.sendDataToTask(data);
    return true;
  }

  Future<bool> defineDailyRecurringService(String serviceName, TimeOfDay timeOfDay, Map<String, dynamic> parameters) async {
    var data = defineForegroundTask(dailyRecurringServiceKey, serviceName, parameters);
    data[timeOfDayHourKey] = timeOfDay.hour;
    data[timeOfDayMinuteKey] = timeOfDay.minute;
    print('define Daily data: $data');
    FlutterForegroundTask.sendDataToTask(data);
    return true;
  }

  void dispose() {
    // Remove a callback to receive data sent from the TaskHandler.
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
  }
}

ForegroundInterface foregroundInterface = ForegroundInterface();