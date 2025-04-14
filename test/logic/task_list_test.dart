import 'package:flutter_test/flutter_test.dart';
import 'package:koti/logic/task_list.dart';

void main() {
  group('TaskItem Tests', () {
    test('TaskItem constructor and properties', () {
      final now = DateTime.now();
      final task = TaskItem('TestService', {'key': 'value'}, now, 1);
      expect(task.serviceName, 'TestService');
      expect(task.parameters, {'key': 'value'});
      expect(task.nextExecution, now);
      expect(task.taskExecutionFunctionIndex, 1);
    });

    test('updateNextExecution prints a message', () {
      final task = TaskItem('TestService', {}, DateTime.now(), 1);
      expect(() => task.updateNextExecution(),
          prints('task item TaskItem missing updateNextExecution\n'));
    });

    test('toString method', () {
      final now = DateTime.parse('2023-10-27T10:00:00.000');
      final task = TaskItem('TestService', {}, now, 1);
      expect(task.toString(),
          '(taskName: TestService, nextExecution: 2023-10-27 10:00:00.000)');
    });

    test('toJson method', () {
      final now = DateTime.parse('2023-10-27T10:00:00.000');
      final task = TaskItem('TestService', {'key': 'value'}, now, 1);
      final json = task.toJson();
      expect(json['serviceName'], 'TestService');
      expect(json['parameters'], {'key': 'value'});
      expect(json['nextExecution'], '2023-10-27T10:00:00.000');
      expect(json['taskExecutionFunctionIndex'], 1);
    });

    test('fromJson method', () {
      final json = {
        'serviceName': 'TestService',
        'parameters': {'key': 'value'},
        'nextExecution': '2023-10-27T10:00:00.000',
        'taskExecutionFunctionIndex': 2,
      };
      final task = TaskItem.fromJson(json);
      expect(task.serviceName, 'TestService');
      expect(task.parameters, {'key': 'value'});
      expect(task.nextExecution, DateTime.parse('2023-10-27T10:00:00.000'));
      expect(task.taskExecutionFunctionIndex, 2);
    });

    test('fromJson method with null values', () {
      final json = {
        'nextExecution': '2023-10-27T10:00:00.000',
      };
      final task = TaskItem.fromJson(json);
      expect(task.serviceName, 'serviceNameNotFound');
      expect(task.parameters, {});
      expect(task.taskExecutionFunctionIndex, 60);
    });
  });

  group('RecurringTask Tests', () {
    test('RecurringTask constructor and properties', () {
      final now = DateTime.parse('2023-10-27T10:00:00.000');
      final task = IntervalTask('RecurringTest', 30, {'key': 'value'}, now, 1);
      expect(task.serviceName, 'RecurringTest');
      expect(task.intervalInMinutes, 30);
      expect(task.parameters, {'key': 'value'});
      expect(task.nextExecution, now);
      expect(task.taskExecutionFunctionIndex, 1);
    });

    test('updateNextExecution method', () {
      final now = DateTime.parse('2023-10-27T10:00:00.000');
      final task = IntervalTask('RecurringTest', 30, {}, now, 1);
      task.updateNextExecution();
      expect(task.nextExecution, DateTime.parse('2023-10-27T10:30:00.000'));
    });

    test('toString method', () {
      final now = DateTime.parse('2023-10-27T10:00:00.000');
      final task = IntervalTask('RecurringTest', 30, {}, now, 1);
      expect(task.toString(),
          '(recurring task: RecurringTest, intervalInMinutes: 30, nextExecution: 2023-10-27 10:00:00.000)');
    });

    test('toJson method', () {
      final now = DateTime.parse('2023-10-27T10:00:00.000');
      final task = IntervalTask('RecurringTest', 30, {'key': 'value'}, now, 1);
      final json = task.toJson();
      expect(json['serviceName'], 'RecurringTest');
      expect(json['parameters'], {'key': 'value'});
      expect(json['nextExecution'], '2023-10-27T10:00:00.000');
      expect(json['intervalInMinutes'], 30);
      expect(json['taskExecutionFunctionIndex'], 1);
    });

    test('fromJson method', () {
      final json = {
        'serviceName': 'RecurringTest',
        'parameters': {'key': 'value'},
        'nextExecution': '2023-10-27T10:00:00.000',
        'intervalInMinutes': 45,
        'taskExecutionFunctionIndex': 2,
      };
      final task = IntervalTask.fromJson(json);
      expect(task.serviceName, 'RecurringTest');
      expect(task.intervalInMinutes, 45);
      expect(task.parameters, {'key': 'value'});
      expect(task.nextExecution, DateTime.parse('2023-10-27T10:00:00.000'));
      expect(task.taskExecutionFunctionIndex, 2);
    });
    test('fromJson method with null values', () {
      final json = {
        'serviceName': 'RecurringTest',
        'nextExecution': '2023-10-27T10:00:00.000',
        'taskExecutionFunctionIndex': 2,
      };
      final task = IntervalTask.fromJson(json);
      expect(task.intervalInMinutes, 60);
    });
  });

  group('DailyRecurringTask Tests', () {
    test('DailyRecurringTask constructor and properties', () {
      final now = DateTime.parse('2023-10-27T10:00:00.000');
      final task = TimeOfDayTask(
          'DailyTest', 12, 30, {'key': 'value'}, now, 1);
      expect(task.serviceName, 'DailyTest');
      expect(task.hour, 12);
      expect(task.minute, 30);
      expect(task.parameters, {'key': 'value'});
      expect(task.nextExecution, now);
      expect(task.taskExecutionFunctionIndex, 1);
    });

    test('updateNextExecution method (future)', () {
      final now = DateTime.parse('2023-10-27T09:00:00.000');
      final task = TimeOfDayTask('DailyTest', 10, 00, {}, now, 1);
      task.updateNextExecution();
      expect(task.nextExecution, DateTime.parse('2023-10-28T10:00:00.000'));
    });

    test('updateNextExecution method (past)', () {
      final now = DateTime.parse('2023-10-27T11:00:00.000');
      final task = TimeOfDayTask('DailyTest', 10, 00, {}, now, 1);
      task.updateNextExecution();
      expect(task.nextExecution, DateTime.parse('2023-10-28T10:00:00.000'));
    });

    test('updateNextExecution method (same time)', () {
      final now = DateTime.parse('2023-10-27T10:00:00.000');
      final task = TimeOfDayTask('DailyTest', 10, 00, {}, now, 1);
      task.updateNextExecution();
      expect(task.nextExecution, DateTime.parse('2023-10-28T10:00:00.000'));
    });

    test('toString method', () {
      final now = DateTime.parse('2023-10-27T10:00:00.000');
      final task = TimeOfDayTask('DailyTest', 10, 30, {}, now, 1);
      expect(task.toString(),
          '(daily task: DailyTest, at 10:30 nextExecution: 2023-10-27 10:00:00.000)');
    });

    test('toJson method', () {
      final now = DateTime.parse('2023-10-27T10:00:00.000');
      final task = TimeOfDayTask(
          'DailyTest', 12, 30, {'key': 'value'}, now, 1);
      final json = task.toJson();
      expect(json['serviceName'], 'DailyTest');
      expect(json['parameters'], {'key': 'value'});
      expect(json['nextExecution'], '2023-10-27T10:00:00.000');
      expect(json['hour'], 12);
      expect(json['minute'], 30);
      expect(json['taskExecutionFunctionIndex'], 1);
    });

    test('fromJson method', () {
      final json = {
        'serviceName': 'DailyTest',
        'parameters': {'key': 'value'},
        'nextExecution': '2023-10-27T10:00:00.000',
        'hour': 14,
        'minute': 15,
        'taskExecutionFunctionIndex': 2,
      };
      final task = TimeOfDayTask.fromJson(json);
      expect(task.serviceName, 'DailyTest');
      expect(task.hour, 14);
      expect(task.minute, 15);
      expect(task.parameters, {'key': 'value'});
      expect(task.nextExecution, DateTime.parse('2023-10-27T10:00:00.000'));
      expect(task.taskExecutionFunctionIndex, 2);
    });
    test('fromJson method with null values', () {
      final json = {
        'serviceName': 'DailyTest',
        'nextExecution': '2023-10-27T10:00:00.000',
        'taskExecutionFunctionIndex': 2,
      };
      final task = TimeOfDayTask.fromJson(json);
      expect(task.hour, 0);
      expect(task.minute, 0);
    });
  });
  group('TaskList Tests', () {
    test('TaskList toJson method', () {
      final now = DateTime.parse('2023-10-27T10:00:00.000');
      final task1 = TaskItem('Task1', {'key1': 'value1'}, now, 1);
      final task2 = IntervalTask('Task2', 30, {'key2': 'value2'}, now, 2);
      final task3 = TimeOfDayTask(
          'Task3', 12, 30, {'key3': 'value3'}, now, 3);
      final taskList = TaskList();
      taskList.tasks = [task1, task2, task3];
      final json = TaskList().toJson();
      expect(json['tasks'].length, 3);
      expect(json['tasks'][0]['serviceName'], 'Task1');
      expect(json['tasks'][1]['serviceName'], 'Task2');
      expect(json['tasks'][2]['serviceName'], 'Task3');
    });

    test('TaskList fromJson method', () {
      final json = {
        'tasks': [
          {
            'serviceName': 'Task1',
            'parameters': {'key1': 'value1'},
            'nextExecution': '2023-10-27T10:00:00.000',
            'taskExecutionFunctionIndex': 1,
          },
          {
            'serviceName': 'Task2',
            'parameters': {'key2': 'value2'},
            'nextExecution': '2023-10-27T10:00:00.000',
            'intervalInMinutes': 30,
            'taskExecutionFunctionIndex': 2,
          },
          {
            'serviceName': 'Task3',
            'parameters': {'key3': 'value3'},
            'nextExecution': '2023-10-27T10:00:00.000',
            'hour': 12,
            'minute': 30,
            'taskExecutionFunctionIndex': 3,
          },
        ],
      };
      final taskList = TaskList.fromJson(json);
      expect(taskList.tasks.length, 3);
      expect(taskList.tasks[0].serviceName, 'Task1');
      expect((taskList.tasks[1] as IntervalTask).intervalInMinutes, 30);
      expect((taskList.tasks[2] as TimeOfDayTask).hour, 12);
    });

    test('TaskList fromJson method with empty tasks', () {
      final json = {'tasks': []};
      final taskList = TaskList.fromJson(json);
      expect(taskList.tasks.length, 0);
    });

    test('TaskList fromJson method with null tasks', () {
      final Map <String, dynamic> json = {};
      final taskList = TaskList.fromJson(json);
      expect(taskList.tasks.length, 0);
    });
  });
}
