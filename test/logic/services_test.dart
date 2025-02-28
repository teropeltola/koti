import 'package:koti/devices/my_device_info.dart';
import 'package:koti/devices/testing_switch_device/testing_switch_device.dart';
import 'package:koti/logic/services.dart';
import 'package:koti/service_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:koti/logic/select_index.dart';

class testDevice {
  bool myValue = false;
  Future <void> set(bool value, String caller) async {
    myValue = value;
  }

  Future<bool> get() async {
    return myValue;
  }

  bool peek() {
    return myValue;
  }

}
void main() {

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  /*
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

   */


  test('Services', () async {
    testDevice t1 = testDevice();
    testDevice t2 = testDevice();

    Services s = Services([RWAsyncDeviceService<bool>(serviceName: 'Service1', setFunction: t1.set, getFunction: t1.get, peekFunction: t1.peek )]);

    expect(s.offerService('Service0'), false);
    expect(s.offerService('Service1'), true);

  });

  test('Services with TestSwitch', () async {
    TestingSwitchDevice t1 = TestingSwitchDevice();

    TestingSwitchDevice t2 = t1.clone();
    TestingSwitchDevice t3 = t1.clone2() as TestingSwitchDevice;

    expect(t2.services.offerService('Service1'),false);
    expect(t3.services.offerService('Service1'),false);
    expect(t2.services.offerService(powerOnOffWaitingService),true);
    expect(t3.services.offerService(powerOnOffWaitingService),true);

    t1.services.setServices([]);

    expect(t1.services.offerService(powerOnOffWaitingService),false);
    expect(t2.services.offerService(powerOnOffWaitingService),true);
    expect(t3.services.offerService(powerOnOffWaitingService),true);

  });

}


