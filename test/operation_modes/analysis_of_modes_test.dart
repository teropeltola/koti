import 'package:flutter_test/flutter_test.dart';
import 'package:koti/operation_modes/analysis_of_modes.dart';
import 'package:koti/operation_modes/operation_modes.dart';

OperationMode _operationMode(String n1, String n2) {
  OperationMode x = OperationMode();
  x.name = n1;
  return x;
}

void main() {

  group('ModelAnalysis', () {

    test('add basic items', () {
      AnalysisOfModes analysis = AnalysisOfModes();
      analysis.add(DateTime(2024, 4, 23, 9, 0), 30, 'mode1');
      expect(analysis.items.length, 1);
      analysis.add(DateTime(2024, 4, 23, 9, 30), 30, 'mode2');
      expect(analysis.items.length, 2);
      analysis.compress();
      expect(analysis.items.length, 2);
    });

    test('add illegal items', () {
      AnalysisOfModes analysis = AnalysisOfModes();
      analysis.add(DateTime(2024, 4, 23, 9, 0), 30, 'mode1');
      analysis.add(DateTime(2024, 4, 23, 9, 31), 30, 'mode2');
      expect(analysis.items.length, 1);
    });

    test('compress items 1', () {
      OperationMode myMode = _operationMode('mode1','notFound');
      AnalysisOfModes analysis = AnalysisOfModes();
      analysis.compress();
      analysis.add(DateTime(2024, 4, 23, 9, 0), 30, 'mode1');
      expect(analysis.items.length, 1);
      analysis.compress();
      analysis.add(DateTime(2024, 4, 23, 9, 30), 30, 'mode1');
      expect(analysis.items.length, 2);
      analysis.compress();
      expect(analysis.items.length, 1);
    });

    test('compress items 1', () {
      OperationMode myMode = _operationMode('mode1','notFound');
      AnalysisOfModes analysis = AnalysisOfModes();
      analysis.add(DateTime(2024, 4, 23, 9, 0), 30, 'mode1');
      analysis.add(DateTime(2024, 4, 23, 9, 30), 30, 'mode1');
      analysis.compress();
      expect(analysis.items.length, 1);
    });
  });
}
