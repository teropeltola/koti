import 'package:flutter_foreground_task/task_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koti/foreground_configurator.dart';
import 'package:koti/logic/task_handler_controller.dart';
import 'package:koti/logic/task_list.dart';




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


      var data = defineForegroundTask(intervalServiceKey, 'first', {'par1key': 'par1'});
      data[intervalInMinutesKey] = 10;
      t.onReceiveControl(data);
      expect(t.taskList.tasks.length, 1);
      expect(t.taskList.tasks[0].serviceName, 'first');
      expect(t.taskList.tasks[0].runtimeType, IntervalTask);
      expect((t.taskList.tasks[0] as IntervalTask).intervalInMinutes, 10);
      expect(t.taskList.tasks[0].parameters['par1key'], 'par1');

      data = defineForegroundTask(timeOfDayServiceKey, 'another', {'par2key': 'par2'});
      data[timeOfDayHourKey] = 12;
      data[timeOfDayMinuteKey] = 30;
      t.onReceiveControl(data);
      expect(t.taskList.tasks.length, 2);
      expect(t.taskList.tasks[0].serviceName, 'first');
      expect(t.taskList.tasks[0].runtimeType, IntervalTask);
      expect(t.taskList.tasks[0].parameters['par1key'], 'par1');
      expect(t.taskList.tasks[1].serviceName, 'another');
      expect(t.taskList.tasks[1].runtimeType, TimeOfDayTask);
      expect(t.taskList.tasks[1].parameters['par2key'], 'par2');

      data[timeOfDayMinuteKey] = 45;
      data['par3key'] = 'par3';
      t.onReceiveControl(data);
      expect(t.taskList.tasks.length, 2);
      expect(t.taskList.tasks[1].serviceName, 'another');
      expect((t.taskList.tasks[1] as TimeOfDayTask).minute, 45);
      expect(t.taskList.tasks[1].parameters['par3key'], 'par3');
      expect(t.taskList.tasks[1].parameters['par1key'], null);

      await Future.delayed(Duration(milliseconds: 1));
      await t.onRepeatEvent(DateTime.now());
      await Future.delayed(Duration(milliseconds: 1));
      expect(fCounter, 1);
      expect(f2Counter, 1);

      expect(t.taskList.tasks.length, 2);
      expect(t.taskList.tasks[1].serviceName, 'another');
      expect(t.taskList.tasks[1].nextExecution.hour, 12);
      expect(t.taskList.tasks[1].nextExecution.minute, 45);

    });
  });

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
}

class Test {

  int id = 0;
  bool removeThis = true;

  Test(this.id, this.removeThis);
}

Future <bool> initF(Map <String, dynamic> parameters) async {
 return false;
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
