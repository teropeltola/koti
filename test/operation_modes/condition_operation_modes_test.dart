import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/my_device_info.dart';
import 'package:koti/logic/device_attribute_control.dart';
import 'package:koti/operation_modes/analysis_of_modes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:koti/devices/porssisahko/porssisahko.dart';
import 'package:koti/estate/estate.dart';
import 'package:koti/functionalities/electricity_price/electricity_price.dart';
import 'package:koti/main.dart';
import 'package:koti/operation_modes/operation_modes.dart';
import 'package:koti/look_and_feel.dart';

import 'package:koti/operation_modes/conditional_operation_modes.dart';


void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  group('OperationComparisons tests', () {
    test('OperationComparisons text should return correct value', () {
      expect(OperationComparisons.less.text(), 'pienempi kuin');
      expect(OperationComparisons.greater.text(), 'suurempi kuin');
      expect(OperationComparisons.less.comparisonValue(0.0,0.0),false);
      expect(OperationComparisons.greater.comparisonValue(0.0,0.0),false);
      expect(OperationComparisons.equal.comparisonValue(0.0,0.0),true);
      expect(OperationComparisons.lessOrEqual.comparisonValue(0.0,0.0),true);
      expect(OperationComparisons.greaterOrEqual.comparisonValue(0.0,0.0),true);
      expect(OperationComparisons.less.comparisonValue(0.0,0.1),true);
    });
  });

  group('SpotPrizeComparisonType tests', () {
    test('SpotPrizeComparisonType text should return correct value', () {
      expect(SpotPriceComparisonType.constant.text(), 'vakio');
      expect(SpotPriceComparisonType.median.text(), 'mediaani');
      expect(SpotPriceComparisonType.percentile.text(), '%-piste');
      // Add more test cases for other enum values if needed.
    });
  });

  group('SpotCondition tests', () {
    test('SpotCondition should return correct value', () {
      SpotCondition s = SpotCondition();
      ElectricityPriceTable e = ElectricityPriceTable();
      e.slotPrices = [12.0, 11.1, 20.2];
      expect(s.isTrue(1.0,e), false);
      s.parameterValue = 12.0;
      s.myType = SpotPriceComparisonType.constant;
      s.comparison = OperationComparisons.equal;
      expect(s.isTrue(12.0, e), true);
      expect(s.isTrue(12.1, e), false);
      s.comparison = OperationComparisons.greaterOrEqual;
      s.myType = SpotPriceComparisonType.median;
      expect(s.isTrue(12.0, e), true);
      expect(s.isTrue(12.1, e), true);
      expect(s.isTrue(11.9, e), false);
      s.comparison = OperationComparisons.less;
      s.myType = SpotPriceComparisonType.percentile;
      s.parameterValue = 0.33;
      e.slotPrices = List.generate(20, (int index)=>20.0-index);
      expect(s.isTrue(1.0, e), true);
      expect(s.isTrue(6.0, e), true);
      expect(s.isTrue(7.0, e), false);
    });
  });

  group('OperationConditionType tests', () {
    test('OperationConditionType', () {
      expect(OperationConditionType.timeOfDay.text(),'kellonaika');
      // Add more test cases for other condition types if needed.
    });


    group('OperationCondition tests', () {
    test('OperationCondition toString should return correct value', () {
      var condition = OperationCondition();
      expect(condition.toString(), 'internal error'); // Since conditionType is not defined by default.
      // Add more test cases for other condition types if needed.
    });

    test('OperationCondition parametersOK should return correct value', () {
      var condition = OperationCondition();
      expect(condition.parametersOK(), false); // Since conditionType is not defined by default.
      // Add more test cases for other conditions if needed.
    });


    group('ConditionalOperationMode simple tests', ()  {
      test('time test', () async {
        OperationCondition o = OperationCondition();
        o.conditionType = OperationConditionType.timeOfDay;
        o.timeRange = MyTimeRange(startTime: TimeOfDay(hour:1,minute:1),
                                  endTime: TimeOfDay(hour:1, minute:1));

        ConditionalOperationMode c = ConditionalOperationMode(o, ResultOperationMode('result'));
        expect(c.match(DateTime(2024,6,16,1,1),0.0,ElectricityPriceTable()),true);
        expect(c.match(DateTime(2024,6,16,1,0),0.0,ElectricityPriceTable()),false);
        expect(c.match(DateTime(2024,6,16,1,2),0.0,ElectricityPriceTable()),false);

      });
    });

    group('ConditionalOperationModes tests', ()  {
      test('simulate should return correct modes', () async {
        // Create a mock electricity price table.
        var electricityPriceTable = ElectricityPriceTable();
        electricityPriceTable.startingTime = DateTime(2024, 4, 16, 0, 0); // Adjust as needed.
        electricityPriceTable.slotPrices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]; // Example slot prices.
        electricityPriceTable.slotSizeInMinutes = 60; // Example slot size in minutes.

        // Create mock ResultOperationMode instances.
        var resultMode1 = ResultOperationMode("Mode 1");
        var resultMode2 = ResultOperationMode("Mode 2");
        var resultMode3 = ResultOperationMode("Mode 3");

        // Create ConditionalOperationMode instances with mock conditions and results.
        var condition1 = OperationCondition();
        condition1.conditionType = OperationConditionType.timeOfDay;
        condition1.timeRange.startTime = TimeOfDay(hour:2,minute:0);
        condition1.timeRange.endTime = TimeOfDay(hour:2,minute:59);
        var condition2 = OperationCondition();
        condition2.conditionType = OperationConditionType.timeOfDay;
        condition2.timeRange.startTime = TimeOfDay(hour:4,minute:0);
        condition2.timeRange.endTime = TimeOfDay(hour:4,minute:59);
        var condition3 = OperationCondition();
        condition3.conditionType = OperationConditionType.timeOfDay;
        condition3.timeRange.startTime = TimeOfDay(hour:0,minute:0);
        condition3.timeRange.endTime = TimeOfDay(hour:23,minute:59);
        var mode1 = ConditionalOperationMode(condition1, resultMode1);
        mode1.draft = false;
        var mode2 = ConditionalOperationMode(condition2, resultMode2);
        mode2.draft = false;
        var mode3 = ConditionalOperationMode(condition3, resultMode3);
        mode3.draft = false;

        OperationModes op = await _testInitOperationModes(electricityPriceTable);

        // Create the ConditionalOperationModes instance and add the modes.
        var conditionalModes = ConditionalOperationModes();
        conditionalModes.init(op);
        conditionalModes.add(mode3);
        conditionalModes.add(mode2);
        conditionalModes.add(mode1);

        // Call the simulate method.
        var modes = conditionalModes.simulate();

        // Check if the modes list contains the expected values.
        expect(modes, [
          '16.4.2024 0.00-1.59: Mode 3',
          '16.4.2024 2.00-2.59: Mode 1',
          '16.4.2024 3.00-3.59: Mode 3',
          '16.4.2024 4.00-4.59: Mode 2',
          '16.4.2024 5.00-7.59: Mode 3',

        ]);
      });

      test('simulate should return correct modes - test 2', () async {
        // Create a mock electricity price table.
        var electricityPriceTable = ElectricityPriceTable();
        electricityPriceTable.startingTime = DateTime(2024, 4, 16, 15, 0); // Adjust as needed.
        electricityPriceTable.slotPrices = [0.1, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0,
                                            7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0,
                                              5.0, 6.0, 7.0]; // Example slot prices.
        electricityPriceTable.slotSizeInMinutes = 60; // Example slot size in minutes.

        // Create mock ResultOperationMode instances.
        var resultMode1 = ResultOperationMode("Mode 1");
        var resultMode2 = ResultOperationMode("Mode 2");
        var resultMode3 = ResultOperationMode("Mode 3");

        // Create ConditionalOperationMode instances with mock conditions and results.
        var condition1 = OperationCondition();
        condition1.conditionType = OperationConditionType.timeOfDay;
        condition1.timeRange.startTime = TimeOfDay(hour:2,minute:0);
        condition1.timeRange.endTime = TimeOfDay(hour:2,minute:59);
        var condition2 = OperationCondition();
        condition2.conditionType = OperationConditionType.timeOfDay;
        condition2.timeRange.startTime = TimeOfDay(hour:4,minute:0);
        condition2.timeRange.endTime = TimeOfDay(hour:4,minute:59);
        var condition3 = OperationCondition();
        condition3.conditionType = OperationConditionType.timeOfDay;
        condition3.timeRange.startTime = TimeOfDay(hour:0,minute:0);
        condition3.timeRange.endTime = TimeOfDay(hour:23,minute:59);
        var mode1 = ConditionalOperationMode(condition1, resultMode1);
        mode1.draft = false;
        var mode2 = ConditionalOperationMode(condition2, resultMode2);
        mode2.draft = false;
        var mode3 = ConditionalOperationMode(condition3, resultMode3);
        mode3.draft = false;

        OperationModes op = await _testInitOperationModes(electricityPriceTable);

        // Create the ConditionalOperationModes instance and add the modes.
        var conditionalModes = ConditionalOperationModes();
        conditionalModes.init(op);
        conditionalModes.add(mode3);
        conditionalModes.add(mode2);
        conditionalModes.add(mode1);

        // Call the simulate method.
        var modes = conditionalModes.simulate();

        // Check if the modes list contains the expected values.
        expect(modes, [
          '16.4.2024 15.00-1.59: Mode 3',
          '17.4.2024 2.00-2.59: Mode 1',
          '17.4.2024 3.00-3.59: Mode 3',
          '17.4.2024 4.00-4.59: Mode 2',
          '17.4.2024 5.00-7.59: Mode 3',

        ]);
      });

      test('simulate one condition', () async {

        // Create mock ResultOperationMode instances.
        var resultMode3 = ResultOperationMode("Mode 3");

        // Create ConditionalOperationMode instances with mock conditions and results.
        var condition3 = OperationCondition();
        condition3.conditionType = OperationConditionType.timeOfDay;
        condition3.timeRange.startTime = TimeOfDay(hour:0,minute:0);
        condition3.timeRange.endTime = TimeOfDay(hour:23,minute:59);
        var mode3 = ConditionalOperationMode(condition3, resultMode3);
        mode3.draft = false;

        var electricityPriceTable = ElectricityPriceTable();
        electricityPriceTable.startingTime = DateTime(2024, 4, 16, 0, 0); // Adjust as needed.
        electricityPriceTable.slotPrices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]; // Example slot prices.
        electricityPriceTable.slotSizeInMinutes = 60; // Example slot size in minutes.

        OperationModes op = await _testInitOperationModes(electricityPriceTable);

        // Create the ConditionalOperationModes instance and add the modes.
        var conditionalModes = ConditionalOperationModes();
        conditionalModes.init(op);
        conditionalModes.add(mode3);

        // Call the simulate method.
        var modes = conditionalModes.simulate();

        // Check if the modes list contains the expected values.
        expect(modes, [
          '16.4.2024 0.00-7.59: Mode 3',
        ]);
      });

    });
  });
  });

  group('json', () {

    test('OperationComparisons', () {
      log.cleanHistory();
      OperationComparisons.values.forEach((e) {expect(e,e.fromJson(e.toJson()));});
      expect(log.history.length, 0);
      OperationComparisons o = OperationComparisons.greater;
      expect(o.fromJson({'comparison': '44'}),OperationComparisons.less);
      expect(log.history.length, 1);
      expect(o.fromJson({}),OperationComparisons.less);
      expect(log.history.length, 2);

    });

    test('SpotPriceComparisonType', () {
      log.cleanHistory();
      SpotPriceComparisonType.values.forEach((e) {expect(e,e.fromJson(e.toJson()));});
      expect(log.history.length, 0);
      SpotPriceComparisonType o = SpotPriceComparisonType.constant;
      expect(o.fromJson({'spotPriceType': '44'}),SpotPriceComparisonType.constant);
      expect(log.history.length, 1);
      expect(o.fromJson({}),SpotPriceComparisonType.constant);
      expect(log.history.length, 2);

    });

    test('SpotCondition', () {
      SpotCondition s = SpotCondition();
      s.myType = SpotPriceComparisonType.percentile;
      s.comparison = OperationComparisons.equal;
      s.parameterValue = 0.7;

      SpotCondition s2 = SpotCondition.fromJson(s.toJson());

      expect(s2.myType, SpotPriceComparisonType.percentile);
      expect(s2.comparison, OperationComparisons.equal);
      expect(s2.parameterValue, 0.7);

    });

    test('OperationConditionType', () {
      log.cleanHistory();
      OperationConditionType.values.forEach((e) {expect(e,e.fromJson(e.toJson()));});
      expect(log.history.length, 0);
      OperationConditionType o = OperationConditionType.spotPrice;
      expect(o.fromJson({'spotPriceType': '44'}),OperationConditionType.notDefined);
      expect(log.history.length, 1);
      expect(o.fromJson({}),OperationConditionType.notDefined);
      expect(log.history.length, 2);

    });

    test('MyTimeRange', () {
      MyTimeRange m = MyTimeRange(startTime: TimeOfDay(hour: 1, minute:2), endTime: TimeOfDay(hour:3, minute:4));
      var j = m.toJson();
      var m2 = m.fromJson(j);
      expect(m2.startTime.hour, 1);
      expect(m2.startTime.minute, 2);
      expect(m2.endTime.hour, 3);
      expect(m2.endTime.minute, 4);

    });

    test('OperationCondition', () {
      OperationCondition o = OperationCondition();
      OperationCondition o2 = OperationCondition.fromJson(o.toJson());
      expect(o2.conditionType, OperationConditionType.notDefined);
      expect(o2.timeRange.endTime.minute, 59);
      expect(o2.spot.parameterValue, 0.0);
    });

    test('ResultOperationMode', () {
      ResultOperationMode r = ResultOperationMode('name');
      ResultOperationMode r2 = ResultOperationMode.fromJson(r.toJson());
      expect(r2.operationModeName, 'name');
    });

    test('ConditionalOperationMode', () {
      OperationCondition operationCondition = OperationCondition();
      operationCondition.conditionType = OperationConditionType.timeOfDay;
      ResultOperationMode r = ResultOperationMode('name');

      ConditionalOperationMode c = ConditionalOperationMode(operationCondition,r);
      c.draft = false;
      Map<String, dynamic> json = c.toJson();
      ConditionalOperationMode c2 =ConditionalOperationMode.fromJson(json);
      expect(c2.condition.conditionType, OperationConditionType.timeOfDay);
      expect(c2.result.operationModeName, 'name');
    });

    test('ConditionalOperationModes', () async {
      OperationModes op = await _testInitOperationModes(ElectricityPriceTable());

      ConditionalOperationModes c = ConditionalOperationModes();
      c.init(op);
      ConditionalOperationModes c2 =ConditionalOperationModes.fromJson(c.toJson());
      c2.init(op);
      expect(c2.conditions.length, 0);

      c.name = 'c';
      c2 =ConditionalOperationModes.fromJson(c.toJson());
      expect(c2.conditions.length, 0);

      OperationCondition operationCondition = OperationCondition();
      operationCondition.conditionType = OperationConditionType.timeOfDay;
      ResultOperationMode r = ResultOperationMode('op name');

      ConditionalOperationMode cm = ConditionalOperationMode(operationCondition,r);
      cm.draft = false;

      c.add(cm);

      c2 =ConditionalOperationModes.fromJson(c.toJson());
      expect(c2.conditions.length, 1);

    });

  });


  group('timer operations', () {

    test('basic test', () async {

      OperationModes o = await _testTimerInitOperationModes(1);
      await Future.delayed(Duration( seconds: 2));

      var conditions = o.getMode('conditional') as ConditionalOperationModes;
      var modes = conditions.simulate();
      modes.forEach((s)=>log.info(s));

      await o.selectNameAndSetParentInfo('conditional', o);
      expect(o.currentModeName(),'conditional');
      expect(conditions.currentActiveConditionName(),'Mode 0');
      AnalysisItem next = conditions.nextSelectItem();
      expect(next.operationModeName, 'Mode 1');
      await Future.delayed(Duration(minutes: 2, seconds: 5));
      expect(conditions.currentActiveConditionName(),'Mode 1');
      next = conditions.nextSelectItem();
      expect(next.operationModeName, 'Mode 0');
      await Future.delayed(Duration(minutes: 8, seconds: 5));

    });

  });

  }

Future <OperationModes> _testTimerInitOperationModes(int startInMinutes) async {
  constantSlotSize = 1;
  var electricityPriceTable = ElectricityPriceTable();
  DateTime now = DateTime.now();
  DateTime start = DateTime(now.year, now.month, now.day, now.hour, now.minute+startInMinutes);
  electricityPriceTable.startingTime = DateTime(now.year, now.month, now.day, now.hour, now.minute); // Adjust as needed.
  electricityPriceTable.slotPrices = List.generate(30, (index){return index.toDouble(); }); // Example slot prices.
  electricityPriceTable.slotSizeInMinutes = 1; // Example slot size in minutes.

  // Create mock ResultOperationMode instances.
  var resultMode0 = ResultOperationMode("Mode 0");
  var resultMode1 = ResultOperationMode("Mode 1");
  var resultMode2 = ResultOperationMode("Mode 2");
  var resultMode3 = ResultOperationMode("Mode 3");

  // Create ConditionalOperationMode instances with mock conditions and results.
  var condition0 = OperationCondition();
  condition0.conditionType = OperationConditionType.timeOfDay;
  condition0.timeRange.startTime = TimeOfDay.fromDateTime(DateTime(start.year, start.month, start.day, start.hour, start.minute-startInMinutes));
  condition0.timeRange.endTime = TimeOfDay.fromDateTime(DateTime(start.year, start.month, start.day, start.hour, start.minute+30));
  var condition1 = OperationCondition();
  condition1.conditionType = OperationConditionType.timeOfDay;
  condition1.timeRange.startTime = TimeOfDay.fromDateTime(DateTime(start.year, start.month, start.day, start.hour, start.minute+1));
  condition1.timeRange.endTime = TimeOfDay.fromDateTime(DateTime(start.year, start.month, start.day, start.hour, start.minute+2));
  var condition2 = OperationCondition();
  condition2.conditionType = OperationConditionType.timeOfDay;
  condition2.timeRange.startTime = TimeOfDay.fromDateTime(DateTime(start.year, start.month, start.day, start.hour, start.minute+4));
  condition2.timeRange.endTime = TimeOfDay.fromDateTime(DateTime(start.year, start.month, start.day, start.hour, start.minute+5));
  var condition3 = OperationCondition();
  condition3.conditionType = OperationConditionType.timeOfDay;
  condition3.timeRange.startTime = TimeOfDay.fromDateTime(DateTime(start.year, start.month, start.day, start.hour, start.minute+7));
  condition3.timeRange.endTime = TimeOfDay.fromDateTime(DateTime(start.year, start.month, start.day, start.hour, start.minute+8));
  var mode0 = ConditionalOperationMode(condition0, resultMode0);
  mode0.draft = false;
  var mode1 = ConditionalOperationMode(condition1, resultMode1);
  mode1.draft = false;
  var mode2 = ConditionalOperationMode(condition2, resultMode2);
  mode2.draft = false;
  var mode3 = ConditionalOperationMode(condition3, resultMode3);
  mode3.draft = false;

  OperationModes op = await _testInitOperationModes(electricityPriceTable);

  op.add(_TestOperationMode.testInit('Mode 0'));
  op.add(_TestOperationMode.testInit('Mode 1'));
  op.add(_TestOperationMode.testInit('Mode 2'));
  op.add(_TestOperationMode.testInit('Mode 3'));
  // Create the ConditionalOperationModes instance and add the modes.
  var conditionalModes = ConditionalOperationModes();
  conditionalModes.init(op);
  conditionalModes.name = 'conditional';
  conditionalModes.add(mode0);
  conditionalModes.add(mode3);
  conditionalModes.add(mode2);
  conditionalModes.add(mode1);

  op.add(conditionalModes);

  return op;
}

class _TestOperationMode extends OperationMode {
  bool isSelected = false;

  _TestOperationMode.testInit(String initName) {
    name = initName;
  }

  @override
  Future<void> select(ControlledDevice unUsedDevice,
      OperationModes? parentModes) async {
    log.info('testOperation $name selected');
    isSelected = true;
  }
}
OperationMode _operationMode(String n1, String n2) {
  OperationMode x = OperationMode();
  x.name = n1;
  return x;
}

Future <OperationModes> _testInitOperationModes(ElectricityPriceTable electricityPriceTable) async {
  myEstates.clearDataStructures();
  Estate estate = Estate();
  estate.init('estate name', 'wifinothere');
  myEstates.addEstate(estate);

  // Create a mock electricity price table.
  ElectricityPrice ep = await addElectricityPrice(estate, 'fake service');

  ep.electricity.data = electricityPriceTable;
  ep.electricity.poke();

  return estate.operationModes;
}

Future<ElectricityPrice> addElectricityPrice(Estate estate, String serviceName) async {
  Porssisahko spot = Porssisahko();
  spot.name = 'spot';
  spot.id = 'spot-pörssisähkö';
  estate.addDevice(spot);
  await spot.init();

  ElectricityPrice ep = ElectricityPrice();
  ep.pair(spot);
  estate.addFunctionality(ep);
  await ep.init();

  return ep;
}




