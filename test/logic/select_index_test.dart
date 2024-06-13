 import 'package:koti/devices/my_device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:koti/logic/select_index.dart';

void main() {
  group('SelectIndex', () {
    late SelectIndex selectIndex;
    late SelectIndex anotherSelectIndex;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await initMySettings();

      selectIndex = SelectIndex('test');
      anotherSelectIndex = SelectIndex('anotherTest');
    });

    test('initialization', () {
      expect(selectIndex.get(), -1);
      //expect(selectIndex.setter, null);
      expect(selectIndex.settingIsValid, isFalse);
    });

    test('setIndex updates the index and invalidates the previous setter', () {
      selectIndex.setIndex(42, anotherSelectIndex);

      expect(selectIndex.get(), 42);
      expect(selectIndex.setter, anotherSelectIndex);
      expect(anotherSelectIndex.settingIsValid, isFalse);
    });

    test('invalidateSetting sets settingIsValid to false', () {
      selectIndex.invalidateSetting();
      expect(selectIndex.settingIsValid, isFalse);
    });

    test('getValue returns the correct value', () {
      selectIndex.setIndex(42, anotherSelectIndex);
      expect(selectIndex.get(), 42);
    });

    test('isValid returns the correct validity status', () {
      expect(selectIndex.isValid(), isFalse);
      selectIndex.settingIsValid = true;
      expect(selectIndex.isValid(), isTrue);
    });
  });
}
