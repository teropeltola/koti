import 'package:flutter_foreground_task/task_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koti/foreground_configurator.dart';
import 'package:koti/functionalities/electricity_price/trend_electricity.dart';
import 'package:koti/logic/electricity_price_data.dart';
import 'package:koti/logic/price_collection.dart';
import 'package:koti/logic/task_handler_controller.dart';
import 'package:koti/logic/task_list.dart';
import 'package:koti/look_and_feel.dart';
import 'package:koti/operation_modes/conditional_operation_modes.dart';




void main() {
  setUpAll(() async {
  });

  group('basic tests', () {
    test('basic test 1', () async {

      TaskHandlerController t = TaskHandlerController();
      expect(t.appInitiated, false);
      await t.initOnStart(DateTime(2025,1,30), TaskStarter.developer, true);
      expect(t.appInitiated, true);

      int earlierTaskFunctions = t.taskFunctions.taskServiceFunctions.length;

      t.taskFunctions.add('first',initF, executionF);
      t.taskFunctions.add('another',initF, executionF2);

      expect(t.taskFunctions.taskServiceFunctions.length, earlierTaskFunctions + 2);

      var data = defineForegroundTask(intervalServiceKey, 'first', {idKey: 'id1', 'par1key': 'par1'});
      data[intervalInMinutesKey] = 10;
      t.onReceiveControl(DateTime(2025,1,30,1), data);
      expect(t.taskList.tasks.length, 1);
      expect(t.taskList.tasks[0].serviceName, 'first');
      expect(t.taskList.tasks[0].runtimeType, IntervalTask);
      expect((t.taskList.tasks[0] as IntervalTask).intervalInMinutes, 10);
      expect(t.taskList.tasks[0].parameters['par1key'], 'par1');

      data = defineForegroundTask(timeOfDayServiceKey, 'another', {idKey: 'id2', 'par2key': 'par2'});
      data[timeOfDayHourKey] = 12;
      data[timeOfDayMinuteKey] = 30;
      t.onReceiveControl(DateTime(2025,1,30,2), data);
      expect(t.taskList.tasks.length, 2);
      expect(t.taskList.tasks[0].serviceName, 'first');
      expect(t.taskList.tasks[0].runtimeType, IntervalTask);
      expect(t.taskList.tasks[0].parameters['par1key'], 'par1');
      expect(t.taskList.tasks[1].serviceName, 'another');
      expect(t.taskList.tasks[1].runtimeType, TimeOfDayTask);
      expect(t.taskList.tasks[1].parameters['par2key'], 'par2');

      data[timeOfDayMinuteKey] = 45;
      data['par3key'] = 'par3';
      t.onReceiveControl(DateTime(2025,1,30,3), data);
      expect(t.taskList.tasks.length, 2);
      expect(t.taskList.tasks[1].serviceName, 'another');
      expect((t.taskList.tasks[1] as TimeOfDayTask).minute, 45);
      expect(t.taskList.tasks[1].parameters['par3key'], 'par3');
      expect(t.taskList.tasks[1].parameters['par1key'], null);

      await Future.delayed(Duration(milliseconds: 1));
      await t.onRepeatEvent(DateTime(2025,1,30,4));
      await Future.delayed(Duration(milliseconds: 1));
      expect(fCounter, 1);
      expect(f2Counter, 1);

      expect(t.taskList.tasks.length, 2);
      expect(t.taskList.tasks[1].serviceName, 'another');
      expect(t.taskList.tasks[1].nextExecution.hour, 12);
      expect(t.taskList.tasks[1].nextExecution.minute, 45);

    });

    test('basic test 2 with price service', () async {

      ElectricityTariff electricityTariff = ElectricityTariff();
      ElectricityDistributionPrice distributionPrice = ElectricityDistributionPrice();

      electricityTariff.setValue('testTariff', TariffType.spot, 0.0);
      distributionPrice.setConstantParameters('testDistribution', 0.0, 0.0);

      TaskHandlerController t = TaskHandlerController();
      t.priceCollection.createPriceAgent('testEstate', electricityTariff, distributionPrice);

      expect(t.priceCollection.estateData.length,1);
      expect(t.priceCollection.estateData[0].estateId, 'testEstate');
      expect(t.priceCollection.estateData[0].electricityPriceData.prices.length, 0);

      t.updatePriceData(DateTime(2025,4,28,8,49), 'testEstate',[
        TrendElectricity(DateTime(2025,4,28,9).millisecondsSinceEpoch, 20.0),
        TrendElectricity(DateTime(2025,4,28,10).millisecondsSinceEpoch, 10.0),
        TrendElectricity(DateTime(2025,4,28,11).millisecondsSinceEpoch, noValueDouble),
      ]);

      expect(t.priceCollection.estateData[0].electricityPriceData.prices.length, 4);

      await t.initOnStart(DateTime(2025,4,28,9,30), TaskStarter.developer, true);

      int earlierTaskFunctions = t.taskFunctions.taskServiceFunctions.length;

      t.taskFunctions.add('first',initF, executionF);
      t.taskFunctions.add('another',initF, executionF2);

      expect(t.taskFunctions.taskServiceFunctions.length, earlierTaskFunctions + 2);

      var data = defineForegroundTask(userTaskKey, 'first', {idKey: 'id1', estateIdKey: 'testEstate'});

      data[recurringKey] = true;
      SpotCondition spotCondition = SpotCondition();
      spotCondition.myType = SpotPriceComparisonType.constant;
      spotCondition.parameterValue = 15.0;
      spotCondition.comparison = OperationComparisons.less;

      data[priceComparisonTypeKey] = spotCondition.toJson();

      t.onReceiveControl(DateTime(2025,4,28,9,10), data);

      expect(t.taskList.tasks.length, 1);
      expect(t.taskList.tasks[0].serviceName, 'first');
      expect(t.taskList.tasks[0].runtimeType, PriceTask);
      expect(t.taskList.tasks[0].nextExecution.hour, 10);
      expect(t.taskList.tasks[0].runtimeType, PriceTask);

      expect(fCounter, 0);

      await t.onRepeatEvent(DateTime(2025,4,28,9,40));

      expect(t.taskList.tasks.length, 1);
      expect(t.taskList.tasks[0].serviceName, 'first');
      expect(t.taskList.tasks[0].runtimeType, PriceTask);
      expect(t.taskList.tasks[0].nextExecution.hour, 10);
      expect(fCounter, 0);

      await t.onRepeatEvent(DateTime(2025,4,28,10,1)); // price event happens

      expect(t.taskList.tasks.length, 1);
      expect(t.taskList.tasks[0].serviceName, 'first');
      expect(t.taskList.tasks[0].runtimeType, PriceTask);
      expect(t.taskList.tasks[0].nextExecution.hour, 0);
      expect(fCounter, 1);

      await t.onRepeatEvent(DateTime(2025,4,28,10,2)); // price event happens

      expect(t.taskList.tasks.length, 1);
      expect(t.taskList.tasks[0].serviceName, 'first');
      expect(t.taskList.tasks[0].runtimeType, PriceTask);
      expect(t.taskList.tasks[0].nextExecution.hour, 0);
      expect(fCounter, 1);

      t.updatePriceData(DateTime(2025,4,28,10,5), 'testEstate',[
        TrendElectricity(DateTime(2025,4,28,11).millisecondsSinceEpoch, 20.0),
        TrendElectricity(DateTime(2025,4,28,12).millisecondsSinceEpoch, 10.0),
        TrendElectricity(DateTime(2025,4,28,13).millisecondsSinceEpoch, 20.0),
        TrendElectricity(DateTime(2025,4,28,14).millisecondsSinceEpoch, 10.0),
        TrendElectricity(DateTime(2025,4,28,15).millisecondsSinceEpoch, noValueDouble),
      ]);

      expect(t.taskList.tasks.length, 1);
      expect(t.taskList.tasks[0].serviceName, 'first');
      expect(t.taskList.tasks[0].runtimeType, PriceTask);
      expect(t.taskList.tasks[0].nextExecution.hour, 12);
      expect(fCounter, 1);

      expect(t.priceCollection.estateData[0].electricityPriceData.prices.length, 8);

    });
  });

/*
  group('dart practice', ()
  {
    test('test 1', () async {
      List<Test> testList = [Test(0,false), Test(1, false), Test(2, false), Test(3, false)];

      for (var test in testList) {
        if (test.id == 2) {
          test.removeThis = true;
        }
      }
      testList.removeWhere((task) => task.removeThis);
      expect(testList.length, 3);
      expect(testList[0].id, 0);
      expect(testList[1].id, 1);
      expect(testList[2].id, 3);

    });
  });

 */
}

class Test {

  int id = 0;
  bool removeThis = true;

  Test(this.id, this.removeThis);
}

Future <bool> initF(TaskHandlerController taskHandlerController, Map <String, dynamic> parameters) async {
 return false;
}

int fCounter = 0;

Future <bool>  executionF(TaskHandlerController taskHandlerController,Map <String, dynamic> parameters) async {
  fCounter++;
  return true;
}

int f2Counter = 0;
Future <bool>  executionF2(TaskHandlerController taskHandlerController, Map <String, dynamic> parameters) async {
  f2Counter++;
  return true;
}
