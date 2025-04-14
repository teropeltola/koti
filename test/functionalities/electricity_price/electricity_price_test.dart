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
