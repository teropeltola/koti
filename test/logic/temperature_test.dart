import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/device/device.dart';
import 'package:koti/logic/temperature.dart';
import 'package:koti/look_and_feel.dart';

class TestDevice extends Device {
  double _x = 1.0;
  void setValue(double x) {
    _x = x;
  }
@override
  double temperatureFunction() {
    return _x;
  }
}

void main() {
  group('Temperature basic tests', () {
    test('Temperature test 1', () {
      Temperature t = Temperature();
      expect(t.target, temperatureNotAvailable);
      expect(t.value, temperatureNotAvailable);
      expect(t.hasTarget(), false);
      expect(t.belowTarget(), false);
      expect(t.overTarget(), false);

      t.target = 3.0;
      expect(t.hasTarget(), true);
      expect(t.belowTarget(), false);
      expect(t.overTarget(), false);

      t = Temperature();
      TestDevice testDevice = TestDevice();
      testDevice.id = '123';
      t.setSource(testDevice);
      testDevice.setValue(11.0);

      expect(t.hasTarget(), false);
      expect(t.belowTarget(), false);
      expect(t.overTarget(), false);

    });

    test('Temperature test 2', () {
      Temperature t = Temperature();
      TestDevice testDevice = TestDevice();
      testDevice.id = '123';
      t.setSource(testDevice);
      testDevice.setValue(3.0);
      t.target = 2.0;
      expect(t.value, 3.0);
      expect(t.target, 2.0);
      expect(t.hasTarget(), true);
      expect(t.belowTarget(), false);
      expect(t.overTarget(), true);

      testDevice.setValue(1.0);
      expect(t.belowTarget(), true);
      expect(t.overTarget(), false);

    });

    test('Temperature jsons', () {
      Temperature temperature = Temperature();
      var json = temperature.toJson();
      expect(json['deviceId'], '');

      Temperature t = Temperature.fromJson(json);
      expect(t.target, temperatureNotAvailable);
      expect(t.value, temperatureNotAvailable);
      expect(t.hasTarget(), false);
      expect(t.belowTarget(), false);
      expect(t.overTarget(), false);

      TestDevice device = TestDevice();
      device.id = 'device.id';
      device.setValue(44.4);
      temperature.setSource(device);
      temperature.target = 33.3;

      json = temperature.toJson();
      t = Temperature.fromJson(json);
      expect(t.target, 33.3);
      expect(t.value, 44.4);
      expect(t.hasTarget(), true);
      expect(t.belowTarget(), false);
      expect(t.overTarget(), true);

    });


  });

}
