import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/porssisahko/json/porssisahko_data.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/porssisahko/json/porssisahko_data.dart';
import 'package:koti/functionalities/electricity_price/trend_electricity.dart';
import 'package:koti/look_and_feel.dart';

void main() {
  group('PorssisahkoData', () {

    setUp(() {
    });

    test('empty list', () async {
      // Arrange
      PorssisahkoData p = PorssisahkoData(prices: []);

      PorssisahkoData p2 = PorssisahkoData.fromJson(p.toJson());

      expect(p2.prices.length,0);
      expect(p2.isEmpty(), true);
      expect(p2.startingTime(), DateTime(0));

      List <TrendElectricity> trend = p2.convert();
      expect(trend.length, 1);
      expect(trend[0].timestamp, 0);
      expect(trend[0].price, noValueDouble);
    });

    test('one item in PorssisahkoData', () async {
      // Arrange
      final now = DateTime.now();
      PorssisahkoData p = PorssisahkoData(prices: [Price(price: 10.0, startDate: DateTime(2025,2,10,13), endDate: DateTime(2025,2,10,14))]);

      PorssisahkoData p2 = PorssisahkoData.fromJson(p.toJson());

      expect(p2.prices.length,1);
      expect(p2.prices[0].price,10.0);
      expect(p2.prices[0].endDate.hour,14);
      expect(p2.isEmpty(), false);
      expect(p2.startingTime(), DateTime(2025,2,10,13));


      List <TrendElectricity> trend = p2.convert();
      expect(trend.length, 2);
      expect(trend[0].timestamp, DateTime(2025,2,10,13).millisecondsSinceEpoch);
      expect(trend[0].price, 10.0);
      expect(trend[1].timestamp, DateTime(2025,2,10,14).millisecondsSinceEpoch);
      expect(trend[1].price, noValueDouble);
    });

    test('two items in PorssisahkoData', () async {
      // Arrange
      final now = DateTime.now();
      PorssisahkoData p = PorssisahkoData(prices: [
        Price(price: 10.0, startDate: DateTime(2025,2,10,13), endDate: DateTime(2025,2,10,14)),
        Price(price: 11.0, startDate: DateTime(2025,2,10,14), endDate: DateTime(2025,2,10,15))]);

      PorssisahkoData p2 = PorssisahkoData.fromJson(p.toJson());

      expect(p2.prices.length,2);
      expect(p2.prices[0].price,10.0);
      expect(p2.prices[0].endDate.hour,14);
      expect(p2.isEmpty(), false);
      expect(p2.startingTime(), DateTime(2025,2,10,13));


      List <TrendElectricity> trend = p2.convert();
      expect(trend.length, 3);
      expect(trend[0].timestamp, DateTime(2025,2,10,13).millisecondsSinceEpoch);
      expect(trend[0].price, 10.0);
      expect(trend[1].timestamp, DateTime(2025,2,10,14).millisecondsSinceEpoch);
      expect(trend[1].price, 11.0);
      expect(trend[2].timestamp, DateTime(2025,2,10,15).millisecondsSinceEpoch);
      expect(trend[2].price, noValueDouble);

      p2.prices[1].price = 10.0;
      trend = p2.convert();
      expect(trend.length, 2);
      expect(trend[0].timestamp, DateTime(2025,2,10,13).millisecondsSinceEpoch);
      expect(trend[0].price, 10.0);
      expect(trend[1].timestamp, DateTime(2025,2,10,15).millisecondsSinceEpoch);
      expect(trend[1].price, noValueDouble);

    });

  });
}