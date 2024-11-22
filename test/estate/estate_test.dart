import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/my_device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:koti/devices/device/device.dart';
import 'package:koti/devices/ouman/ouman_device.dart';
import 'package:koti/devices/wlan/active_wifi_name.dart';
import 'package:koti/estate/estate.dart';
import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/functionalities/heating_system_functionality/heating_system.dart';
import 'package:koti/functionalities/heating_system_functionality/view/heating_system_view.dart';


void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  group('Estate Tests 1', () {

    setUp(() {
    });

    test('Add Device to Estate', () {
      Estate location = Estate();
      final device = Device(); // Create a device instance for testing
      location.addDevice(device);
      expect(location.devices, contains(device));
    });

    test('Remove Device from Estate', () {
      Estate location = Estate();
      final device = Device(); // Create a device instance for testing
      location.addDevice(device);
      location.removeDevice(device.id);
      expect(location.devices.length, 0);
    });

    test('json test 1', () {
      Estate e1 = Estate();
      e1.init('abc', 'wifi');
      var j = e1.toJson();
      Estate e2 = Estate.fromJson(j);
      expect(e2.name,'abc');
      expect(e2.myWifi,'wifi');
      expect(e2.devices.isNotEmpty, true);
      expect(e2.devices[0].name,'wifi');
      expect(e2.features.isEmpty, true);
      expect(e2.views.isEmpty, true);
    });

    test('json test 2', () {
      Estate e1 = Estate();
      e1.init('abc','wifi');
      OumanDevice oumanDevice = OumanDevice();
      oumanDevice.name = 'oumanName';
      oumanDevice.ipAddress = '1.2.3.4';
      oumanDevice.id = 'oumanId';
      e1.addDevice(oumanDevice);
      HeatingSystem h = HeatingSystem();
      allFunctionalities.addFunctionality(h);
      h.pair(oumanDevice);
      e1.addFunctionality(h);
      HeatingSystemView hv = HeatingSystemView(h);
      e1.addView(hv);

      var j = e1.toJson();
      Estate e2 = Estate.fromJson(j);
      expect(e2.name,'abc');
      expect(e2.id,e1.id);
      expect(e2.myWifi,'wifi');
      expect(e2.devices.isEmpty, false);
      expect(e2.devices[1].name, 'oumanName');
      expect(e2.devices[1].id, 'oumanId');
      OumanDevice o2 = e2.devices[1] as OumanDevice;
      expect((e2.devices[1] as OumanDevice).ipAddress, '1.2.3.4');

      Functionality fun = e2.views[0].myFunctionality as Functionality;
      HeatingSystem h2 = fun as HeatingSystem;
      expect(h2.id, h.id);
    });

  });

  group('Estates Tests 2', () {

    setUp(() {
    });

    test('Add Estate to Estates', () {
      Estates locations = Estates();
      final location = Estate(); // Create a location instance for testing
      expect(locations.nbrOfEstates(), 0);
      locations.addEstate(location);
      expect(locations.nbrOfEstates(), 1);
    });

    test('Remove Estate from Estates', () {
      Estates locations = Estates();
      final location = Estate(); // Create a location instance for testing
      location.init('test', 'wifi');
      locations.addEstate(location);

      locations.removeEstate(location.id);
      expect(locations.estates.isEmpty, true);
    });

    test('Remove Estate from Estates 2', () {
      Estates locations = Estates();
      final location = Estate(); // Create a location instance for testing
      locations.addEstate(location);
      locations.removeEstate('not found');
      expect(locations.estates.isEmpty, false);
    });

    test('exist and valid tests', () {
      Estates locations = Estates();
      expect(locations.validEstateName(''), equals(false));
      expect(locations.validEstateName('1'), equals(true));
      expect(locations.validWifiName(''), equals(false));
      expect(locations.validWifiName('1'), equals(true));

      expect(locations.estateNameExists(''), equals(false));
      expect(locations.wifiNameExists(''), equals(false));

      final location1 = Estate(); // Create location instances for testing
      location1.init('id 1', 'wifi 1');
      locations.addEstate(location1);

      expect(locations.estateNameExists('id 2'), equals(false));
      expect(locations.wifiNameExists('wifi1'), equals(false));
      expect(locations.estateNameExists('id 1'), equals(true));
      expect(locations.wifiNameExists('wifi 1'), equals(true));

      final location2 = Estate();
      location2.init('id 2', 'wifi 2');
      locations.addEstate(location2);

      expect(locations.estateNameExists('id 1'), equals(true));
      expect(locations.estateNameExists('id 2'), equals(true));
      expect(locations.estateNameExists('id 3'), equals(false));
      expect(locations.wifiNameExists('wifi 1'), equals(true));
      expect(locations.wifiNameExists('wifi 2'), equals(true));
      expect(locations.wifiNameExists('wifi 3'), equals(false));
    });


    test('Test isMyWifi', () {
      final location = Estate();
      location.init('name', '');
      expect(location.myWifi == '', true);
      expect(location.myWifi == 'foo', false);

      location.myWifi = 'foo';
      expect(location.myWifi == '', false);
      expect(location.myWifi == 'foo', true);
      expect(location.myWifi == 'woofoo', false);
    });


  });
}
