import 'package:flutter_test/flutter_test.dart';
import 'package:koti/look_and_feel.dart';
import 'package:koti/operation_modes/operation_modes.dart';

void main() {
  group('OperationMode', () {
    test('name() returns correct name', () {
      final operationMode = OperationMode('TestMode', () {});
      expect(operationMode.name, 'TestMode');
    });

    test('select() calls selectFunction', () {
      bool functionCalled = false;
      final operationMode = OperationMode('TestMode', () {
        functionCalled = true;
      });
      operationMode.select();
      expect(functionCalled, true);
    });
  });

  group('OperationModes', () {
    test('current() returns noOperationMode when empty', () {
      final operationModes = OperationModes();
      expect(operationModes.current(), equals(noOperationMode));
    });

    test('currentModeName() returns empty string when empty', () {
      final operationModes = OperationModes();
      expect(operationModes.currentModeName(), '');
    });

    test('nameOK() returns true for unique name', () {
      final operationModes = OperationModes();
      expect(operationModes.newNameOK('UniqueName'), true);
    });

    test('nameOK() returns false for empty name', () {
      final operationModes = OperationModes();
      expect(operationModes.newNameOK(''), false);
    });

    test('nameOK() returns false for duplicate name', () {
      final operationModes = OperationModes();
      operationModes.add('TestMode', () {});
      expect(operationModes.newNameOK('TestMode'), false);
    });

    test('select() updates currentIndex correctly', () async {
      final operationModes = OperationModes();
      operationModes.add('Mode1', () {});
      operationModes.add('Mode2', () {});
      await operationModes.select('Mode2');
      expect(operationModes.currentModeName(), 'Mode2');
    });

    test('add() increases length of modes list', () async {
      final operationModes = OperationModes();
      operationModes.add('TestMode', () {});
      await operationModes.select('TestMode');
      expect(operationModes.currentModeName(), 'TestMode');
    });

    test('remove() decreases length of modes list', () {
      final operationModes = OperationModes();
      operationModes.add('TestMode', () {});
      operationModes.remove('TestMode');
      expect(operationModes.current(), equals(noOperationMode));
    });

  });

  group('Real execution simulation', () {
      test('Couple modes', () async {
        final operationModes = OperationModes();
        _testInt = 0;
        operationModes.add('Mode 1', _testFunction1 );
        operationModes.add('Mode 2', _testFunction2 );
        await operationModes.select('Mode 1');
        expect(operationModes.currentModeName(),'Mode 1');
        expect(_testInt, 1);
        await operationModes.select('Mode 2');
        expect(operationModes.currentModeName(),'Mode 2');
        expect(_testInt, 2);
      });

  });
}

int _testInt = 0;
void _testFunction1() {
  _testInt = 1;
}

void _testFunction2() {
  _testInt = 2;
}