import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:koti/devices/my_device_info.dart';

import 'package:koti/logic/unique_id.dart';


void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  group('UniqueId Tests', () {
    test('basic', () {
      UniqueId id = UniqueId('a');
      UniqueId id2 = UniqueId('a');
      expect(id.get()[0], 'a');
      expect(id.prefix(),'a');
      expect(id.index(), id2.index()-1);
    });

    test('from string', () {
      UniqueId id = UniqueId.fromString('b#abc');
      expect(id.get(), 'b#abc');
      expect(id.prefix(),'b');
    });

    test('from string', () {
      UniqueId id = UniqueId.fromString('b#abc');
      expect(id.get(), 'b#abc');
      expect(id.prefix(),'b');
    });

  });
}
