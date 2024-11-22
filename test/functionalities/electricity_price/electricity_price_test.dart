import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/my_device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:koti/devices/porssisahko/porssisahko.dart';
import 'package:koti/functionalities/electricity_price/electricity_price.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  group('ElectricityPriceTable', () {
    test('findIndex returns -1 if myTime is before startingTime', () {
      final table = ElectricityPriceTable();
      table.startingTime = DateTime(2024, 2, 8, 10);
      expect(table.findIndex(DateTime(2024, 2, 8, 9)), equals(-1));
    });

    // Add more tests for findIndex with valid and edge cases

    test('isEmpty returns true if slotPrices is empty', () {
      final table = ElectricityPriceTable();
      expect(table.isEmpty(), isTrue);
    });

    // Add more tests for isEmpty with different scenarios

    // Add more tests for other methods in ElectricityPriceTable
  });

  group('ElectricityTariff', () {
    test('toJson converts tariff to JSON', () {
      final tariff = ElectricityTariff();
      tariff.setValue('name', TariffType.spot, 10.0);
      expect(tariff.toJson(), equals({'name': 'name', 'type': 'spot', 'par': 10.0}));
    });

    // Add more tests for other methods in ElectricityTariff
  });

  group('ElectricityDistributionPrice', () {
    test('toJson converts distribution price to JSON', () {
      final distributionPrice = ElectricityDistributionPrice();
      distributionPrice.setConstantParameters('Name', 5.0, 2.0);
      expect(distributionPrice.toJson(), equals({
        'name': 'Name',
        'type': 'const',
        'dayTimeStarting': 0,
        'dayTimeEnding': 0,
        'dayTariff': 5.0,
        'nightTariff': 0.0,
        'electricityTax': 2.0,
      }));
    });

    // Add more tests for other methods in ElectricityDistributionPrice
  });

  group('ElectricityPrice', () {
    test('isInitialized returns false if loadingTime is not set', () {
      final price = ElectricityPrice();
      expect(price.isInitialized(), isFalse);
    });

    test('ElectricityPrice json functions', () {
      final price = ElectricityPrice();
      Porssisahko p = Porssisahko();
      price.pair(p);

      price.tariff.setValue('TariffName', TariffType.spot, 5.5);
      price.distributionPrice.setTimeOfDayParameters('NightCheaper', 7, 22, 10.0, 1.0, 3.0);
      var json = price.toJson();
      final price2 = ElectricityPrice.fromJson(json);
      price2.pair(p);

      expect(price.tariff.price(-1), price2.tariff.price(-1));
      expect(price.tariff.price(0), price2.tariff.price(0));
      expect(price.tariff.price(1), price2.tariff.price(1));
    });

    // Add more tests for isInitialized with different scenarios

    // Add tests for other methods in ElectricityPrice
  });

  group('ElectricityChartData', () {
    test('minPrice initializes with notAvailablePrice', () {
      final chartData = ElectricityChartData();
      expect(chartData.minPrice, equals(notAvailablePrice));
    });

    // Add more tests for other fields in ElectricityChartData
  });
}
