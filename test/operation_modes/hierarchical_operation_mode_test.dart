
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:koti/devices/my_device_info.dart';
import 'package:koti/operation_modes/hierarcical_operation_mode.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  group('FunctionalityAndOperationMode', () {
    test('fromJson creates an instance from a JSON map', () {
      final json = {
        'functionalityId': 'TestFunctionality',
        'operationName': 'TestOperation'
      };

      final functionalityAndOperationMode = IdAndOperationMode.fromJson(json);

      expect(functionalityAndOperationMode.id, 'TestFunctionality');
      expect(functionalityAndOperationMode.operationName, 'TestOperation');
    });

    test('toJson returns a JSON map containing proper data', () {
      final functionalityAndOperationMode = IdAndOperationMode('TestFunctionality', 'TestOperation');

      final json = functionalityAndOperationMode.toJson();

      expect(json['functionalityId'], 'TestFunctionality');
      expect(json['operationName'], 'TestOperation');
    });
  });

  group('HierarchicalOperationMode', () {
    test('fromJson creates an instance from a JSON map', () {
      final json = {
        'items': [
          {
            'functionalityId': 'TestFunctionality1',
            'operationName': 'TestOperation1'
          },
          {
            'functionalityId': 'TestFunctionality2',
            'operationName': 'TestOperation2'
          }
        ]
      };

      final hierarchicalOperationMode = HierarchicalOperationMode.fromJson(json);

      expect(hierarchicalOperationMode.items.length, 2);
      expect(hierarchicalOperationMode.items[0].id, 'TestFunctionality1');
      expect(hierarchicalOperationMode.items[0].operationName, 'TestOperation1');
      expect(hierarchicalOperationMode.items[1].id, 'TestFunctionality2');
      expect(hierarchicalOperationMode.items[1].operationName, 'TestOperation2');
    });

    test('toJson returns a JSON map containing proper data', () {
      final hierarchicalOperationMode = HierarchicalOperationMode()
        ..items = [
          IdAndOperationMode('TestFunctionality1', 'TestOperation1'),
          IdAndOperationMode('TestFunctionality2', 'TestOperation2')
        ];

      final json = hierarchicalOperationMode.toJson();

      expect(json['items'].length, 2);
      expect(json['items'][0]['functionalityId'], 'TestFunctionality1');
      expect(json['items'][0]['operationName'], 'TestOperation1');
      expect(json['items'][1]['functionalityId'], 'TestFunctionality2');
      expect(json['items'][1]['operationName'], 'TestOperation2');
    });

    test('typeName returns correct type name', () {
      final hierarchicalOperationMode = HierarchicalOperationMode();

      expect(hierarchicalOperationMode.typeName(), 'Hierarkkinen');
    });

    test('add', () {
      final hierarchicalOperationMode = HierarchicalOperationMode();

      expect(hierarchicalOperationMode.items.length, 0);
      expect(hierarchicalOperationMode.operationCode('f1'), '');

      hierarchicalOperationMode.add('f1','t1');
      expect(hierarchicalOperationMode.items.length, 1);
      expect(hierarchicalOperationMode.operationCode('f1'), 't1');
      expect(hierarchicalOperationMode.items[0].id, 'f1');
      expect(hierarchicalOperationMode.items[0].operationName, 't1');

      hierarchicalOperationMode.add('f1','t1b');
      expect(hierarchicalOperationMode.items.length, 1);
      expect(hierarchicalOperationMode.items[0].id, 'f1');
      expect(hierarchicalOperationMode.items[0].operationName, 't1b');
      expect(hierarchicalOperationMode.operationCode('f1'), 't1b');
      expect(hierarchicalOperationMode.operationCode('f2'), '');

      hierarchicalOperationMode.add('f2','t1b');
      expect(hierarchicalOperationMode.items.length, 2);
      expect(hierarchicalOperationMode.items[1].id, 'f2');
      expect(hierarchicalOperationMode.items[1].operationName, 't1b');
      expect(hierarchicalOperationMode.operationCode('f1'), 't1b');
      expect(hierarchicalOperationMode.operationCode('f2'), 't1b');
    });

  });
}
