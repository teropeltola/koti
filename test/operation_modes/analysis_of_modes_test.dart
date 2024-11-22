import 'package:flutter_test/flutter_test.dart';
import 'package:koti/look_and_feel.dart';
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
      log.cleanHistory();
      analysis.add(DateTime(2024, 4, 23, 9, 31), 30, 'mode2');
      expect(log.history.length, 1);
      expect(log.history.last.message ?? 'Empty', 'AnalysisOfModes add error: not back to back time slots');
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

  group('AnalysisOfModes', () {

    test('AnalysisItem', () {
      AnalysisItem a = AnalysisItem(DateTime(2000),DateTime(2000),'test');
      expect(a.notFound(),false);
      a = AnalysisItem.empty();
      expect(a.notFound(),true);

    });

    test('AnalysisOfModes ', () {

      AnalysisOfModes analysis = AnalysisOfModes();
      expect(analysis.isEmpty(), true);
      expect(analysis.updateAndGetCurrentItem().notFound(),true);
      expect(analysis.setFirstOperationName(DateTime(2024)),'');
      expect(analysis.updateAndGetCurrentItem().notFound(),true);
      expect(analysis.operationName(DateTime(2024)),'');

      analysis.add(DateTime(2024, 6, 15, 9, 0), 30, 'mode1');
      expect(analysis.items.length, 1);
      expect(analysis.isEmpty(), false);
      expect(analysis.updateAndGetCurrentItem().notFound(),true);
      expect(analysis.setFirstOperationName(DateTime(2024, 6, 15, 8, 59)),'');
      expect(analysis.setFirstOperationName(DateTime(2024, 6, 15, 9, 0)),'mode1');
      expect(analysis.setFirstOperationName(DateTime(2024, 6, 15, 9, 29)),'mode1');
      expect(analysis.setFirstOperationName(DateTime(2024, 6, 15, 9, 30)),'');
      expect(analysis.updateAndGetCurrentItem().notFound(),true);
      expect(analysis.operationName(DateTime(2024, 6, 15, 9, 30)),'');
      expect(analysis.operationName(DateTime(2024, 6, 15, 9, 29)),'mode1');
      expect(analysis.operationName(DateTime(2024, 6, 15, 9, 0)),'mode1');
      expect(analysis.operationName(DateTime(2024, 6, 15, 8, 59)),'');

      analysis.add(DateTime(2024, 6, 15, 9, 30), 30, 'mode2');
      expect(analysis.items.length, 2);
      expect(analysis.isEmpty(), false);
      expect(analysis.updateAndGetCurrentItem().notFound(),true);
      expect(analysis.setFirstOperationName(DateTime(2024, 6, 15, 9, 0)),'mode1');
      AnalysisItem a = analysis.updateAndGetCurrentItem();
      expect(a.notFound(),false);
      expect(a.start.minute, 30);
      expect(a.operationModeName, 'mode2');

      analysis.compress();
      expect(analysis.items.length, 2);

      expect(analysis.toStringList(),['15.6.2024 9.00-9.29: mode1', '15.6.2024 9.30-9.59: mode2']);
    });

  });

  }
