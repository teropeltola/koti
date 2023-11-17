import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/device/device.dart';
import 'package:koti/estate/estate.dart';


void main() {
  group('Estate Tests', () {

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
  });

  group('Estates Tests', () {

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


    test('Push and Pop Current Estate', () {
      Estates locations = Estates();
      final location1 = Estate(); // Create location instances for testing
      final location2 = Estate();

      location1.id = 'id 1';
      location2.id = 'id 2';

      locations.addEstate(location1);
      locations.addEstate(location2);

      locations.pushCurrent(location1);
      locations.pushCurrent(location2);

      expect(locations.currentEstate(), equals(location2));
      expect(locations.nbrOfEstates(), equals(2));

      locations.popCurrent();
      expect(locations.currentEstate(), equals(location1));
      expect(locations.nbrOfEstates(), equals(2));

      locations.popCurrent();
      expect(locations.currentEstate().id, '');

      locations.popCurrent();
      expect(locations.currentEstate().id, '');

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
      location1.name = 'id 1';
      location1.myWifi = 'wifi 1';
      locations.addEstate(location1);

      expect(locations.estateNameExists('id 2'), equals(false));
      expect(locations.wifiNameExists('wifi1'), equals(false));
      expect(locations.estateNameExists('id 1'), equals(true));
      expect(locations.wifiNameExists('wifi 1'), equals(true));

      final location2 = Estate();
      location2.name = 'id 2';
      location2.myWifi = 'wifi 2';
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
      location.myWifi = '';
      expect(location.isMyWifi(''), false);
      expect(location.isMyWifi('foo'), false);

      location.myWifi = 'foo';
      expect(location.isMyWifi(''), false);
      expect(location.isMyWifi('foo'), true);
      expect(location.isMyWifi('woodoo'), false);
    });


  });
}
