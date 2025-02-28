import 'package:flutter_test/flutter_test.dart';
import 'package:koti/functionalities/electricity_price/electricity_price.dart';
import 'package:koti/functionalities/electricity_price/trend_electricity.dart';
import 'package:koti/logic/electricity_price_data.dart';
import 'package:koti/logic/observation.dart';
import 'package:koti/look_and_feel.dart'; // Change this to the correct import path

void main() {
  group('ElectricityTotalPriceItem tests', () {
    test('basic tests', () {
      ElectricityTotalPriceItem item = ElectricityTotalPriceItem();
      expect(item.timestamp, 0);
      expect(item.electricityPrice, noValueDouble);
      expect(item.transferPrice, noValueDouble);
      expect(item.totalPrice, noValueDouble);

      item.electricityPrice = 10.0;
      expect(item.totalPrice, noValueDouble);

      item.transferPrice = 20.0;
      expect(item.totalPrice, 30.0);

    });
  });

  group('ElectricityPriceData tests', () {
    test('empty data tests', () {
      ElectricityPriceData data = ElectricityPriceData();
      expect(data.prices.isEmpty, isTrue);

      data.storeElectricityPrice([]);
      expect(data.prices.isEmpty, isTrue);

      ElectricityDistributionPrice electricityDistributionPrice = ElectricityDistributionPrice();
      electricityDistributionPrice.setConstantParameters('test', 10.0, 20.0);
      data.storeTransferPrice(electricityDistributionPrice);
      expect(data.prices.length, 0);
      expect(data.priceAtDateTime(DateTime(2025,2,1)), noValueDouble);

    });

    test('single item', () {
      ElectricityPriceData data = ElectricityPriceData();
      data.storeElectricityPrice([TrendElectricity(100, 10.0), TrendElectricity(200, noValueDouble)]);
      expect(data.prices.length, 2);

      ElectricityDistributionPrice electricityDistributionPrice = ElectricityDistributionPrice();
      electricityDistributionPrice.setConstantParameters('test', 10.0, 20.0);
      data.storeTransferPrice(electricityDistributionPrice);
      expect(data.prices.length, 2);
      expect(data.priceAtTimestamp(99), noValueDouble);
      expect(data.priceAtTimestamp(100), 20.0);
      expect(data.priceAtTimestamp(199), 20.0);
      expect(data.priceAtTimestamp(200), noValueDouble);
    });

    test('single day with transfer time', () {
      ElectricityPriceData data = ElectricityPriceData();
      data.storeElectricityPrice([
        TrendElectricity(DateTime(2025,2,14).millisecondsSinceEpoch, 10),
        TrendElectricity(DateTime(2025,2,15).millisecondsSinceEpoch, noValueDouble)]);

      expect(data.prices.length, 2);

      ElectricityDistributionPrice electricityDistributionPrice = ElectricityDistributionPrice();
      electricityDistributionPrice.setTimeOfDayParameters('test', 7, 22, 4.0, 2.0, 1.0);
      data.storeTransferPrice(electricityDistributionPrice);
      expect(data.prices.length, 4);
      expect(data.priceAtDateTime(DateTime(2025,2,13,23)), noValueDouble);
      expect(data.priceAtDateTime(DateTime(2025,2,15,0,1)), noValueDouble);
      expect(data.priceAtDateTime(DateTime(2025,2,14)), 10+2+1);
      expect(data.priceAtDateTime(DateTime(2025,2,14,6,59)), 10+2+1);
      expect(data.priceAtDateTime(DateTime(2025,2,14,7,0)), 10+4+1);
      expect(data.priceAtDateTime(DateTime(2025,2,14,21,59,59)), 10+4+1);
      expect(data.priceAtDateTime(DateTime(2025,2,14,22,00)), 10+2+1);
    });

    test('single day with tariff and transfer time change at the same time', () {
      ElectricityPriceData data = ElectricityPriceData();
      data.storeElectricityPrice([
        TrendElectricity(DateTime(2025,2,14).millisecondsSinceEpoch, 10),
        TrendElectricity(DateTime(2025,2,14,7).millisecondsSinceEpoch, 20),
        TrendElectricity(DateTime(2025,2,15).millisecondsSinceEpoch, noValueDouble)]);

      expect(data.prices.length, 2);

      ElectricityDistributionPrice electricityDistributionPrice = ElectricityDistributionPrice();
      electricityDistributionPrice.setTimeOfDayParameters('test', 7, 22, 4.0, 2.0, 1.0);
      data.storeTransferPrice(electricityDistributionPrice);
      expect(data.prices.length, 4);
      expect(data.priceAtDateTime(DateTime(2025,2,13,23)), noValueDouble);
      expect(data.priceAtDateTime(DateTime(2025,2,15,0,1)), noValueDouble);
      expect(data.priceAtDateTime(DateTime(2025,2,14)), 10+2+1);
      expect(data.priceAtDateTime(DateTime(2025,2,14,6,59)), 10+2+1);
      expect(data.priceAtDateTime(DateTime(2025,2,14,7,0)), 20+4+1);
      expect(data.priceAtDateTime(DateTime(2025,2,14,21,59,59)), 20+4+1);
      expect(data.priceAtDateTime(DateTime(2025,2,14,22,00)), 20+2+1);
    });

  });


  group('ElectricityPriceData 1', () {
    test('findIndex returns -1 if myTime is before startingTime', () {
      final table = ElectricityPriceData();
      expect(table.findIndex(DateTime(2024, 2, 8, 9)), equals(-1));
    });

  });

    group('ElectricityPriceData 2', () {
      test('normal case', () {
        final e = ElectricityPriceData();
        e.storeElectricityPrice(_electricityPrices(DateTime(2024, 2, 17, 23), 24));
        ElectricityDistributionPrice transfer = ElectricityDistributionPrice();
        expect(e.prices.length, 25);
        printData(e);
        transfer.setTimeOfDayParameters('test', 7, 23, 4.0, 2.0, 1.255);
        e.storeTransferPrice(transfer);
        printData(e);
        expect(e.prices.length, 25);
      });

      test('long electricity price period', () {
        final e = ElectricityPriceData();
        e.storeElectricityPrice([TrendElectricity(DateTime(2025, 2, 15).millisecondsSinceEpoch, 10.0),
          TrendElectricity(DateTime(2025, 2, 18).millisecondsSinceEpoch, noValueDouble)]
        );
        expect(e.prices.length, 2);
        ElectricityDistributionPrice transfer = ElectricityDistributionPrice();
        printData(e);
        transfer.setTimeOfDayParameters('test', 7, 23, 4.0, 2.0, 1.255);
        e.storeTransferPrice(transfer);
        printData(e);
        expect(e.prices.length, 7);
      });

  });


  group('Minimum Price Periods', () {
    test('special cases', () {
      final e = ElectricityPriceData();
      PriceAndTime p = e.findMinPriceWithinDuration(1);
      expect(p.price, noValueDouble);
      double d = e.averagePrice(0, 1);
      expect(d, noValueDouble);

      e.storeElectricityPrice([TrendElectricity(DateTime(2025, 2, 15).millisecondsSinceEpoch, 10.0),
        TrendElectricity(DateTime(2025, 2, 18).millisecondsSinceEpoch, noValueDouble)]
      );
      ElectricityDistributionPrice transfer = ElectricityDistributionPrice();
      transfer.setTimeOfDayParameters('test', 7, 23, 4.0, 2.0, 1.255);
      e.storeTransferPrice(transfer);

      d = e.averagePrice(0, 1);
      expect(d, closeTo(13.255, 0.0001));
      expect( e.averagePrice(0, 7*60),closeTo(13.255, 0.0001));
      expect( e.averagePrice(0, 14*60),closeTo(14.255, 0.0001));
      expect( e.averagePrice(0, 21*60),closeTo(14.255 + 0.33333, 0.0001));
      expect( e.averagePrice(1, 14*60),closeTo(15.255, 0.0001));

      p = e.findMinPriceWithinDuration(1);
      expect(p.price, closeTo(13.255, 0.0001));
      expect(p.time, DateTime(2025, 2, 15));

    });

    test('one hour case', () {
      var e = ElectricityPriceData();
      e.storeElectricityPrice([TrendElectricity(DateTime(2025, 2, 24, 12).millisecondsSinceEpoch, 10.0),
        TrendElectricity(DateTime(2025, 2, 24, 13).millisecondsSinceEpoch, noValueDouble)]
      );
      ElectricityDistributionPrice transfer = ElectricityDistributionPrice();
      transfer.setTimeOfDayParameters('test', 7, 23, 4.0, 2.0, 1.255);
      e.storeTransferPrice(transfer);

      ElectricityChartData d = e.analyse();
      expect(d.minPrice.price, closeTo(15.255, 0.0001));
      expect(d.minPrice.time, DateTime(2025, 2, 24, 12));
      expect(d.min2hourPeriod.price, closeTo(noValueDouble, 0.0001));
      expect(d.min3hourPeriod.price, closeTo(noValueDouble, 0.0001));

    });


    test('first timestamp 0', () {
      var e = ElectricityPriceData();
      e.storeElectricityPrice([
        TrendElectricity(0, noValueDouble),
        TrendElectricity(DateTime(2025, 2, 26).millisecondsSinceEpoch, 10.0),
        TrendElectricity(DateTime(2025, 2, 27).millisecondsSinceEpoch, noValueDouble)]
      );
      expect(e.prices.length, 3);
      ElectricityDistributionPrice transfer = ElectricityDistributionPrice();
      transfer.setTimeOfDayParameters('test', 7, 23, 4.0, 2.0, 1.255);
      e.storeTransferPrice(transfer);
      expect(e.prices.length, 5);
      ElectricityChartData d = e.analyse();
      expect(d.minPrice.price, closeTo(13.255, 0.0001));
      expect(d.minPrice.time, DateTime(2025, 2, 26, 0));

    });
  });


  }

List <TrendElectricity> _electricityPrices(DateTime since, int amount) {
  List <TrendElectricity> result = [];
  const int oneHour = 1000 * 60 * 60;
  int firstTimestamp = since.millisecondsSinceEpoch - oneHour * (amount);
  for (int i = 0; i < amount; i++) {
    result.add(
          TrendElectricity(firstTimestamp + i * oneHour,10.0+ i * 0.01));
  }
  result.add(TrendElectricity(since.millisecondsSinceEpoch, noValueDouble));
  return result;
}

String _epItem(ElectricityTotalPriceItem item) {
  return dumpTimeString(DateTime.fromMillisecondsSinceEpoch(item.timestamp)) +
      ': ${currencyCentInText(item.totalPrice)} ' +
      '(${currencyCentInText(item.electricityPrice)} + ${currencyCentInText(
          item.transferPrice)})';
}

void printData(ElectricityPriceData data) {
  for (var item in data.prices) {
    print(_epItem(item));
  }
}

