import 'package:flutter_test/flutter_test.dart';
import 'package:koti/functionalities/electricity_price/electricity_price_foreground.dart';

const String _testUrl = 'https://api.porssisahko.net/v1/latest-prices.json';
void main() {
  group('ElectricityPriceForegroung', () {
    test('Basic functionality', () async {
      ElectricityPriceForeground e = ElectricityPriceForeground(internetPage: _testUrl);

      await e.init();

      bool success = await e.fetchDataFromNetwork();
    });
  });
}
