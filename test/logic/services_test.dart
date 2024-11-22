import 'package:koti/devices/my_device_info.dart';
import 'package:koti/logic/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:koti/logic/select_index.dart';

class testDevice {
  bool myValue = false;
  Future <void> set(bool value) async {
    myValue = value;
  }

  Future<bool> get() async {
    return await myValue;
  }

}
void main() {
  group('basic tests', () {
    test('DeviceService', () async {
      testDevice t = testDevice();
      SwitchDeviceService s = SwitchDeviceService(serviceName: 'Service1', setFunction: t.set, getFunction: t.get);

      expect(s.serviceName, 'Service1');
      expect(await s.get(), false);
      await s.set(true);
      expect(await s.get(), true);
      expect(t.myValue, true);
    });

    test('Services', () async {
      testDevice t1 = testDevice();
      testDevice t2 = testDevice();
      Services s = Services([SwitchDeviceService(serviceName: 'Service1', setFunction: t1.set, getFunction: t1.get),
        SwitchDeviceService(serviceName: 'Service2', setFunction: t2.set, getFunction: t2.get)]);

      expect(s.offerService('Service0'), false);
      expect(s.offerService('Service1'), true);
      expect(s.offerService('Service2'), true);

      SwitchDeviceService switchDeviceService = s.getService('Service1') as SwitchDeviceService;

      await switchDeviceService.set(true);
      expect(await switchDeviceService.get(), true);
      expect(t1.myValue, true);
      expect(t2.myValue, false);

    });

    test('Services', () async {
      testDevice t1 = testDevice();
      testDevice t2 = testDevice();
      Services s = Services([RWDeviceService<bool>(serviceName: 'Service1', setFunction: t1.set, getFunction: t1.get),
        RWDeviceService<double>(serviceName: 'Service2', setFunction: t2.set, getFunction: t2.get)]);

      expect(s.offerService('Service0'), false);
      expect(s.offerService('Service1'), true);
      expect(s.offerService('Service2'), true);

      SwitchDeviceService switchDeviceService = s.getService('Service1') as SwitchDeviceService;

      await switchDeviceService.set(true);
      expect(await switchDeviceService.get(), true);
      expect(t1.myValue, true);
      expect(t2.myValue, false);

    });

  });
}


