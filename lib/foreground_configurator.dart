// service types
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:koti/devices/ouman/ouman_foreground.dart';
import 'package:koti/trend/trend_event.dart';

import 'app_configurator.dart';
import 'functionalities/electricity_price/electricity_price_foreground.dart';
import 'logic/task_handler_controller.dart';

// foreground service tasks
const String oumanForegroundService = 'ouman';
const String electricityPriceForegroundService = 'electricityPrice';

// map protocol parameter keys
const String taskNameKey = 'taskName';
const String serviceNameKey = 'serviceName';
const String recurringServiceKey = 'setRecurringService';
const String dailyRecurringServiceKey = 'setDailyRecurringService';
const String readDataStructureKey = 'readDataStructure';
const String intervalInMinutesKey = 'intervalInMinutes';
const String timeOfDayHourKey = 'timeOfDayHour';
const String timeOfDayMinuteKey = 'timeOfDayMinute';
const String internetPageKey = 'internetPage';
const String boxPathKey = 'boxPath';

void createFunctionTable() {
  taskFunctions.clear();
  taskFunctions.add(oumanForegroundService,oumanInitFunction, oumanExecutionFunction);
  taskFunctions.add(electricityPriceForegroundService, electricityPriceInitFunction, electricityPriceExecutionFunction);
}

Map <String, dynamic> defineForegroundTask(String taskName, String serviceName, Map <String, dynamic> parameters) {
  Map <String, dynamic> data = parameters;
  data[taskNameKey] = taskName;
  data[serviceNameKey] = serviceName;
  return data;
}

class ForegroundTrendEventBox {

  late Box<TrendEvent> box;

  Future<void> init() async {
    await Hive.openBox<TrendEvent>(hiveTrendEventName);
    box = Hive.box<TrendEvent>(hiveTrendEventName);
  }

}
