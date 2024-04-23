import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koti/functionalities/electricity_price/electricity_price.dart';
import 'package:koti/operation_modes/operation_modes.dart';

import 'package:time_range_picker/time_range_picker.dart'; // Make sure to import this package if not already imported in your test file.

import 'package:koti/operation_modes/conditional_operation_modes.dart';


void main() {
  group('OperationComparisons tests', () {
    test('OperationComparisons text should return correct value', () {
      expect(OperationComparisons.less.text(), 'pienempi kuin');
      expect(OperationComparisons.greater.text(), 'suurempi kuin');
      expect(OperationComparisons.less.value(0.0,0.0),false);
      expect(OperationComparisons.greater.value(0.0,0.0),false);
      expect(OperationComparisons.equal.value(0.0,0.0),true);
      expect(OperationComparisons.lessOrEqual.value(0.0,0.0),true);
      expect(OperationComparisons.greaterOrEqual.value(0.0,0.0),true);
      expect(OperationComparisons.less.value(0.0,0.1),true);
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

    group('ConditionalOperationModes tests', () {
      test('simulate should return correct modes', () {
        // Create a mock electricity price table.
        var electricityPriceTable = ElectricityPriceTable();
        electricityPriceTable.startingTime = DateTime(2024, 4, 16, 0, 0); // Adjust as needed.
        electricityPriceTable.slotPrices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]; // Example slot prices.
        electricityPriceTable.slotSizeInMinutes = 60; // Example slot size in minutes.

        // Create mock ResultOperationMode instances.
        var resultMode1 = ResultOperationMode(OperationMode("Mode 1", (){}));
        var resultMode2 = ResultOperationMode(OperationMode("Mode 2", (){}));
        var resultMode3 = ResultOperationMode(OperationMode("Mode 3", (){}));

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

        // Create the ConditionalOperationModes instance and add the modes.
        var conditionalModes = ConditionalOperationModes();
        conditionalModes.add(mode3);
        conditionalModes.add(mode2);
        conditionalModes.add(mode1);

        // Call the simulate method.
        var modes = conditionalModes.simulate(electricityPriceTable);

        // Check if the modes list contains the expected values.
        expect(modes, [
          '16.4.2024',
          '0.00-1.59: Mode 3',
          '2.00-2.59: Mode 1',
          '3.00-3.59: Mode 3',
          '4.00-4.59: Mode 2',
          '5.00-7.59: Mode 3',

        ]);
      });

      test('simulate should return correct modes - test 2', () {
        // Create a mock electricity price table.
        var electricityPriceTable = ElectricityPriceTable();
        electricityPriceTable.startingTime = DateTime(2024, 4, 16, 15, 0); // Adjust as needed.
        electricityPriceTable.slotPrices = [0.1, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0,
                                            7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0,
                                              5.0, 6.0, 7.0]; // Example slot prices.
        electricityPriceTable.slotSizeInMinutes = 60; // Example slot size in minutes.

        // Create mock ResultOperationMode instances.
        var resultMode1 = ResultOperationMode(OperationMode("Mode 1", (){}));
        var resultMode2 = ResultOperationMode(OperationMode("Mode 2", (){}));
        var resultMode3 = ResultOperationMode(OperationMode("Mode 3", (){}));

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

        // Create the ConditionalOperationModes instance and add the modes.
        var conditionalModes = ConditionalOperationModes();
        conditionalModes.add(mode3);
        conditionalModes.add(mode2);
        conditionalModes.add(mode1);

        // Call the simulate method.
        var modes = conditionalModes.simulate(electricityPriceTable);

        // Check if the modes list contains the expected values.
        expect(modes, [
          '16.4.2024',
          '15.00-1.59: Mode 3',
          '2.00-2.59: Mode 1',
          '3.00-3.59: Mode 3',
          '4.00-4.59: Mode 2',
          '5.00-7.59: Mode 3',

        ]);
      });

      test('simulate one condition', () {
        // Create a mock electricity price table.
        var electricityPriceTable = ElectricityPriceTable();
        electricityPriceTable.startingTime = DateTime(2024, 4, 16, 0, 0); // Adjust as needed.
        electricityPriceTable.slotPrices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]; // Example slot prices.
        electricityPriceTable.slotSizeInMinutes = 60; // Example slot size in minutes.

        // Create mock ResultOperationMode instances.
        var resultMode3 = ResultOperationMode(OperationMode("Mode 3", (){}));

        // Create ConditionalOperationMode instances with mock conditions and results.
        var condition3 = OperationCondition();
        condition3.conditionType = OperationConditionType.timeOfDay;
        condition3.timeRange.startTime = TimeOfDay(hour:0,minute:0);
        condition3.timeRange.endTime = TimeOfDay(hour:23,minute:59);
        var mode3 = ConditionalOperationMode(condition3, resultMode3);
        mode3.draft = false;

        // Create the ConditionalOperationModes instance and add the modes.
        var conditionalModes = ConditionalOperationModes();
        conditionalModes.add(mode3);

        // Call the simulate method.
        var modes = conditionalModes.simulate(electricityPriceTable);

        // Check if the modes list contains the expected values.
        expect(modes, [
          '16.4.2024',
          '0.00-7.59: Mode 3',
        ]);
      });

    });
  });
  });

  group('ModelAnalysis', () {

      test('add basic items', () {
        AnalysisOfModes analysis = AnalysisOfModes();
        analysis.add(DateTime(2024, 4, 23, 9, 0), 30, OperationMode('mode1',(){}));
        expect(analysis.items.length, 1);
        analysis.add(DateTime(2024, 4, 23, 9, 30), 30, OperationMode('mode2',(){}));
        expect(analysis.items.length, 2);
        analysis.compress();
        expect(analysis.items.length, 2);
      });

      test('add illegal items', () {
        AnalysisOfModes analysis = AnalysisOfModes();
        analysis.add(DateTime(2024, 4, 23, 9, 0), 30, OperationMode('mode1',(){}));
        analysis.add(DateTime(2024, 4, 23, 9, 31), 30, OperationMode('mode2',(){}));
        expect(analysis.items.length, 1);
      });

      test('compress items 1', () {
        OperationMode myMode = OperationMode('mode1',(){});
        AnalysisOfModes analysis = AnalysisOfModes();
        analysis.compress();
        analysis.add(DateTime(2024, 4, 23, 9, 0), 30, myMode);
        expect(analysis.items.length, 1);
        analysis.compress();
        analysis.add(DateTime(2024, 4, 23, 9, 30), 30, myMode);
        expect(analysis.items.length, 2);
        analysis.compress();
        expect(analysis.items.length, 1);
      });

      test('compress items 1', () {
        OperationMode myMode = OperationMode('mode1',(){});
        AnalysisOfModes analysis = AnalysisOfModes();
        analysis.add(DateTime(2024, 4, 23, 9, 0), 30, myMode);
        analysis.add(DateTime(2024, 4, 23, 9, 30), 30, myMode);
        analysis.compress();
        expect(analysis.items.length, 1);
      });

  });
}
