import 'package:flutter_test/flutter_test.dart';

import 'package:koti/logic/unique_id.dart';


void main() {
  group('UniqueId Tests', () {
    test('basic', () {
      UniqueId id = UniqueId('a');
      expect(id.get()[0], 'a');
      expect(id.prefix(),'a');
      //DateTime d = id.creationTime();
      //expect(d.hour, DateTime.now().hour);
    });

    test('from string', () {
      UniqueId id = UniqueId.fromString('b#abc');
      expect(id.get(), 'b#abc');
      expect(id.prefix(),'b');
      //DateTime d = id.creationTime();
      //expect(d.year, 0);
    });

  });
}
