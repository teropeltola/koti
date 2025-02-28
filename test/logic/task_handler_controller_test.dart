import 'package:flutter_foreground_task/task_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koti/foreground_configurator.dart';
import 'package:koti/logic/task_handler_controller.dart';




void main() {
  setUpAll(() async {
  });

  group('basic tests', () {
    test('basic test 1', () async {

      TaskHandlerController t = TaskHandlerController();
      expect(t.appInitiated, false);
      await t.initOnStart(DateTime(2025,1,30), TaskStarter.developer);
      expect(t.appInitiated, true);

      int earlierTaskFunctions = taskFunctions.taskServiceFunctions.length;

      taskFunctions.add('first',initF, executionF);
      taskFunctions.add('another',initF, executionF2);

      expect(taskFunctions.taskServiceFunctions.length, earlierTaskFunctions + 2);


      var data = defineForegroundTask(recurringServiceKey, 'first', {'par1key': 'par1'});
      data[intervalInMinutesKey] = 10;
      t.onReceiveControl(data);
      expect(t.tasks.length, 1);
      expect(t.tasks[0].serviceName, 'first');
      expect(t.tasks[0].runtimeType, RecurringTask);
      expect((t.tasks[0] as RecurringTask).intervalInMinutes, 10);
      expect(t.tasks[0].parameters['par1key'], 'par1');

      data = defineForegroundTask(dailyRecurringServiceKey, 'another', {'par2key': 'par2'});
      data[timeOfDayHourKey] = 12;
      data[timeOfDayMinuteKey] = 30;
      t.onReceiveControl(data);
      expect(t.tasks.length, 2);
      expect(t.tasks[0].serviceName, 'first');
      expect(t.tasks[0].runtimeType, RecurringTask);
      expect(t.tasks[0].parameters['par1key'], 'par1');
      expect(t.tasks[1].serviceName, 'another');
      expect(t.tasks[1].runtimeType, DailyRecurringTask);
      expect(t.tasks[1].parameters['par2key'], 'par2');

      data[timeOfDayMinuteKey] = 45;
      data['par3key'] = 'par3';
      t.onReceiveControl(data);
      expect(t.tasks.length, 2);
      expect(t.tasks[1].serviceName, 'another');
      expect((t.tasks[1] as DailyRecurringTask).minute, 45);
      expect(t.tasks[1].parameters['par3key'], 'par3');
      expect(t.tasks[1].parameters['par1key'], null);

      await Future.delayed(Duration(milliseconds: 1));
      await t.onRepeatEvent(DateTime.now());
      await Future.delayed(Duration(milliseconds: 1));
      expect(fCounter, 1);
      expect(f2Counter, 1);

      expect(t.tasks.length, 2);
      expect(t.tasks[1].serviceName, 'another');
      expect(t.tasks[1].nextExecution.hour, 12);
      expect(t.tasks[1].nextExecution.minute, 45);

    });
  });
}

Future <void> initF(Map <String, dynamic> parameters) async {

}

int fCounter = 0;

Future <bool>  executionF(Map <String, dynamic> parameters) async {
  fCounter++;
  return true;
}

int f2Counter = 0;
Future <bool>  executionF2(Map <String, dynamic> parameters) async {
  f2Counter++;
  return true;
}
