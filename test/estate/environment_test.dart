import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/device/device.dart';
import 'package:koti/devices/ouman/ouman_device.dart';
import 'package:koti/devices/wlan/active_wifi_name.dart';
import 'package:koti/estate/environment.dart';
import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/functionalities/heating_system_functionality/heating_system.dart';
import 'package:koti/functionalities/heating_system_functionality/view/heating_system_view.dart';


void main() {
  group('Environment Tests 1', () {

    setUp(() {
    });

    test('Environment test 1', () {
      Environment e = Environment();
      expect(e.name, '');
    });


  });
}
