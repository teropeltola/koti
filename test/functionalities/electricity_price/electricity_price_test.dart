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

    test('nextTariffChange tests', () {
      final d = ElectricityDistributionPrice();
      d.setTimeOfDayParameters('Name', 7,22,20.0, 10.0, 2.0);

      expect(d.constantTariff(), isFalse);
      expect(d.dayTime(7), isTrue);
      expect(d.dayTime(22), isFalse);

      expect(d.currentTransferTariff(8), equals(20.0));
      expect(d.currentTransferTariff(6), equals(10.0));

      expect(d.price(8), equals(22.0));
      expect(d.price(6), equals(12.0));

      int nextChange = d.previousTariffChange(DateTime(2025,2,14,8).millisecondsSinceEpoch);
      expect(nextChange, equals(DateTime(2025,2,14,7).millisecondsSinceEpoch));
      expect(d.previousTariffChange(nextChange), nextChange);
      expect(d.previousTariffChange(nextChange-1), DateTime(2025,2,13,22).millisecondsSinceEpoch);

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
