// service types
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:koti/devices/ouman/ouman_foreground.dart';
import 'package:koti/trend/trend_event.dart';

import 'app_configurator.dart';
import 'devices/testing_switch_device/testing_switch_device.dart';
import 'functionalities/electricity_price/electricity_price_foreground.dart';
import 'interfaces/foreground_interface.dart';
import 'logic/task_handler_controller.dart';
import 'logic/unique_id.dart';

// foreground service protocol has the following parameters:
const String taskNameKey = 'taskName'; // taskNameKey defines the task type
const String serviceNameKey = 'serviceName'; // serviceNameKey: defines the service name - defines the routines used
const String idKey = 'id'; // idKey: defines the id of the task - that can modify or delete it
const String estateIdKey = 'estateId';
// + task & service based additional parameters

// task names are
const String readDataStructureKey = 'readDataStructure';
const String intervalServiceKey = 'intervalService';
const String timeOfDayServiceKey = 'timeOfDayService';
const String userTaskKey = 'userTask';

// foreground service names are
const String oumanForegroundService = 'ouman';
const String electricityPriceForegroundService = 'electricityPrice';
const String testOnOffForegroundService = 'testOnOff';
const String standardForegroundService = 'standard';

const Map <String, String> foregroundServiceNames = {
  oumanForegroundService : 'Ouman-pumppu',
  electricityPriceForegroundService : 'Sähkön hinnan nouto',
  testOnOffForegroundService : 'Testikytkin',
  standardForegroundService : 'Yksinkertainen'
};

// is the service request recurring or one timer
const String recurringKey = 'recurring';
// interval has the following parameter
const String intervalInMinutesKey = 'intervalInMinutes';
// time of Day has the following additional parameters
const String timeOfDayHourKey = 'timeOfDayHour';
const String timeOfDayMinuteKey = 'timeOfDayMinute';
// price comparison keys
const String priceComparisonTypeKey = 'priceComparison';
const String priceLogicComparisonKey = 'priceLogicComparison';
const String priceComparisonValueKey = 'priceComparisonValue';
const String constantPrice = 'constantPrice';
const String priceDifference = 'priceDifference';
// different services are using these parameters
const String internetPageKey = 'internetPage';
const String electricityTariffKey = 'electricityTariff';
const String distributionTariffKey = 'distributionTariff';
const String boxPathKey = 'boxPath';
const String powerOn = 'powerOn';
const String messagesParameter = 'messages';

// messages from foreground to main has the following parameters
const String messageKey = 'messageKey';
const String dataKey = 'data';

// message key can have the following values
const String messageData = 'messageData';
const String responseMessage = 'responseMessage';

void createFunctionTable() {
  taskFunctions.clear();
  taskFunctions.add(standardForegroundService, foregroundStandardTaskInitFunction, foregroundStandardTaskExecutionFunction);
  taskFunctions.add(oumanForegroundService,oumanInitFunction, oumanExecutionFunction);
  taskFunctions.add(electricityPriceForegroundService, electricityPriceInitFunction, electricityPriceExecutionFunction);
  taskFunctions.add(testOnOffForegroundService, testOnOffInitFunction, testOnOffExecutionFunction);

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

String foregroundExtractDeviceId(String inputString) {
  int hashIndex = inputString.indexOf('*');

  if (hashIndex != -1) {
    // '#' found, extract substring before it
    return inputString.substring(0, hashIndex);
  } else {
    // '#' not found, return the original string
    return inputString;
  }
}

String foregroundCreateUniqueId(String id) {
  return id + UniqueId('*').get();
}

