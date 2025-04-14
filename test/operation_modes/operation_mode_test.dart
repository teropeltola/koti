import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/my_device_info.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:koti/devices/device/device.dart';
import 'package:koti/estate/estate.dart';
import 'package:koti/operation_modes/operation_modes.dart';

OperationMode _operationMode(String n1) {
  OperationMode x = OperationMode();
  x.name = n1;
  return x;
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  /*
  group('ParameterHandlingFunction', ()  {
    test('basic operation', () async {
      expect(_testInt, 0);
      expect(p.functionName,'name');
      await p.call({});
      expect(_testInt, 1);
    });
  });

  group('ParameterHandlingFunctions', ()  {
    test('basic operations', () async {
      ParameterHandlingFunctions p = ParameterHandlingFunctions();
      OperationMode o = _operationMode('operationMode', 'notFound');

      expect(_testInt, 0);
      await p.call(o);
      expect(_testInt, 0);

      p.add(ParameterHandlingFunction('name1', _testFunction1));
      expect(_testInt, 0);
      await p.call(o);

      o.selectFunctionName = 'name1';
      await p.call(o);
      expect(_testInt, 1);

    });
  });

 */

  group('OperationMode', () {
    test('name() returns correct name', () {
      final operationMode = _operationMode('TestMode');
      expect(operationMode.name, 'TestMode');
    });

    /*
    test('select() calls selectFunction', () {
      bool functionCalled = false;
      myParameterHandlingFunctions.clear();
      myParameterHandlingFunctions.addFunction(ParameterHandlingFunction('testFunction', (Map<String, dynamic> parameters) {functionCalled = true; }));

      final operationMode = _operationMode('TestMode', 'testFunction');

      operationMode.select();
      expect(functionCalled, true);
    });
     */
    test('json', () {

      ConstantOperationMode operationMode = ConstantOperationMode.fromJson(_operationMode('TestMode').toJson());
      operationMode.parameters = {'temp': 10.1 };

      final o2 = ConstantOperationMode.fromJson(operationMode.toJson());
      expect(o2.name, 'TestMode');
      expect(o2.parameters['temp'], 10.1);

      final o3 = ConstantOperationMode.fromJson({});
      expect(o3.name, '');
      expect(o3.parameters, {});
    });

  });

  group('OperationModeType', () {
    test('basic name', () {
      final operationModeType = OperationModeType();
      expect(operationModeType.name, '');
      expect(operationModeType.parameters, {});
    });

    test('json', () {

      OperationModeType o1 = OperationModeType();
      o1.name = 'TestType';
      o1.parameters = {'temp': 10.1 };

      final o2 = OperationModeType.fromJson(o1.toJson());
      expect(o2.name, 'TestType');
      expect(o2.parameters['temp'], 10.1);

      final o3 = OperationModeType.fromJson({});
      expect(o3.name, '');
      expect(o3.parameters, {});
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
      operationModes.add(_operationMode('TestMode'));
      expect(operationModes.newNameOK('TestMode'), false);
    });

    test('select() updates currentIndex correctly', () async {
      final operationModes = OperationModes();
      operationModes.add(_operationMode('Mode1'));
      operationModes.add(_operationMode('Mode2'));
      await operationModes.selectNameAndSetParentInfo('Mode2', operationModes);
      expect(operationModes.currentModeName(), 'Mode2');
    });

    test('add() increases length of modes list', () async {
      final operationModes = OperationModes();
      operationModes.add(_operationMode('TestMode'));
      await operationModes.selectNameAndSetParentInfo('TestMode', operationModes);
      expect(operationModes.currentModeName(), 'TestMode');
    });

    test('remove() decreases length of modes list', () {
      final operationModes = OperationModes();
      operationModes.add(_operationMode('TestMode' ));
      operationModes.remove('TestMode');
      expect(operationModes.current(), equals(noOperationMode));
    });

  });

  group('OperationModeTypes', () {
    test('basic', () {
      OperationModeTypes o = OperationModeTypes();
      expect(o.alternatives(),[]);
      o.add('type1');
      expect(o.alternatives(),['type1']);
      o.add('type2');
      expect(o.alternatives(),['type1', 'type2']);

    });

    test('json', () {
      OperationModeTypes o1 = OperationModeTypes();
      OperationModeTypes o2 = OperationModeTypes.fromJson(o1.toJson());
      expect(o2.alternatives(),[]);
      o1.add('alt1');
      o2 = OperationModeTypes.fromJson(o1.toJson());
      expect(o2.alternatives(),['alt1']);
      o1.add('alt2');
      o2 = OperationModeTypes.fromJson(o1.toJson());
      expect(o2.alternatives(),['alt1', 'alt2']);
//      o1.parameters = {'par1': 1.2, 'par2' : 'yesyes' };
    });

  });

      group('Operation Modes', () {
      test('Couple modes', () async {

        Estate estate = Estate();
        Device device = Device();
        estate.addDevice(device);
        final operationModes = estate.operationModes;
        operationModes.initModeStructure(
            environment:estate,
            parameterSettingFunctionName: 'dummy',
            deviceId:  device.id,
            deviceAttributes: [],
            setFunction: _testFunction1,
            getFunction: _testFunction1);
        _testInt = 0;
        operationModes.add(_operationMode('Mode 1'));
        operationModes.add(_operationMode('Mode 2'));
        await operationModes.selectNameAndSetParentInfo('Mode 1', operationModes);
        expect(operationModes.currentModeName(),'Mode 1');
        expect(_testInt, 1);
        await operationModes.selectNameAndSetParentInfo('Mode 2', operationModes);
        expect(operationModes.currentModeName(),'Mode 2');
        expect(_testInt, 2);

      });

      test('json', () async {
        final operationModes = OperationModes();
        var o2 = OperationModes.fromJson(operationModes.toJson());
        expect(o2.nbrOfModes(),0);
        _testInt = 0;
        operationModes.add(_operationMode('Mode 1' ));
        operationModes.add(_operationMode('Mode 2' ));

        o2 = OperationModes.fromJson(operationModes.toJson());
        expect(o2.operationModeNames(), ['Mode 1', 'Mode 2']);

      });

      });

  group('inheritance test', () {
    test('basics 1', () async {
      ConstantOperationMode c0 = ConstantOperationMode();
      c0.name = 'O_name';

      ConstantOperationMode c1 = c0.clone() as ConstantOperationMode;
      expect(c1.name, 'O_name');

    });

    test('basics 2', () async {
      ConstantOperationMode c1 = ConstantOperationMode();
      c1.name = 'name';
      c1.parameters = {'a': 'b' };
      ConstantOperationMode c2 = ConstantOperationMode.fromJson(c1.toJson());
      expect(c2.name, 'name');
      expect(c2.parameters['a'],'b');
      OperationMode o1 = OperationMode();
      o1.name = 'o1';
      o1 = c1;
      ConstantOperationMode c3 = o1 as ConstantOperationMode;
      expect(c3.parameters['a'],'b');

    });

  });
    }

int _testInt = 0;
Future <void> _testFunction1(Map<String, dynamic> parameters) async {
  _testInt = 1;
}

Future <void>  _testFunction2(Map<String, dynamic> parameters) async {
  _testInt = 2;
}