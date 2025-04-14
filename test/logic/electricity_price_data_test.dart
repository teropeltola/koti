import 'package:flutter_test/flutter_test.dart';
import 'package:koti/functionalities/electricity_price/electricity_price.dart';
import 'package:koti/functionalities/electricity_price/trend_electricity.dart';
import 'package:koti/logic/electricity_price_data.dart';
import 'package:koti/logic/observation.dart';
import 'package:koti/look_and_feel.dart'; // Change this to the correct import path

const _vatMultiplier = 1.255;

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

  group('ElectricityTariff', () {
    test('toJson converts tariff to JSON', () {
      final tariff = ElectricityTariff();
      tariff.setValue('name', TariffType.spot, 10.0);

      expect(tariff.toJson(), equals({'name': 'name', 'type': 'spot', 'par': 10.0}));
    });

    test('spot tariff', () {
      final tariff = ElectricityTariff();
      tariff.setValue('name', TariffType.spot, 10.0);
      expect(tariff.name, 'name');
      expect(tariff.spot(20),closeTo(10.0, 0.0001));
      expect(tariff.margin(), closeTo(10,0.0001));
      expect(tariff.reversePriceWithoutVat(12.55),closeTo(10.0, 0.0001));
      expect(tariff.priceWithoutVat(0), equals(10.0));
      expect(tariff.priceWithVat(0), closeTo(12.55, 0.001));
      expect(tariff.priceWithoutVat(10), equals(20.0));
      expect(tariff.priceWithVat(10), closeTo(25.1, 0.001));
    });


    test('constant tariff', () {
      final tariff = ElectricityTariff();
      tariff.setValue('name', TariffType.constant, 10.0);
      expect(tariff.priceWithoutVat(0), equals(10.0));
      expect(tariff.priceWithVat(0), closeTo(12.55, 0.001));
      expect(tariff.priceWithoutVat(10), equals(10.0));
      expect(tariff.priceWithVat(10), closeTo(12.55, 0.001));
    });
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

      expect(d.priceWithoutVat(8), equals(22.0));
      expect(d.priceWithoutVat(6), equals(12.0));

      int nextChange = d.previousTariffChange(DateTime(2025,2,14,8).millisecondsSinceEpoch);
      expect(nextChange, equals(DateTime(2025,2,14,7).millisecondsSinceEpoch));
      expect(d.previousTariffChange(nextChange), nextChange);
      expect(d.previousTariffChange(nextChange-1), DateTime(2025,2,13,22).millisecondsSinceEpoch);

    });

    // Add more tests for other methods in ElectricityDistributionPrice
  });


  group('ElectricityPriceData tests', () {
    test('empty data tests', () {
      ElectricityPriceData data = ElectricityPriceData();
      expect(data.prices.isEmpty, isTrue);

      data.storeElectricityPrice([]);
      expect(data.prices.isEmpty, isTrue);

      data.distributionPrice.setConstantParameters('test', 10.0, 20.0);
      expect(data.prices.length, 0);
      expect(data.priceAtDateTime(DateTime(2025,2,1)), noValueDouble);

    });

    test('single item', () {
      ElectricityPriceData data = ElectricityPriceData();
      data.tariff.setValue('test', TariffType.spot, 10.0);
      data.distributionPrice.setConstantParameters('test', 10.0, 20.0);
      data.storeElectricityPrice([TrendElectricity(100, 10.0), TrendElectricity(200, noValueDouble)]);
      expect(data.prices.length, 2);
      expect(data.prices.length, 2);
      expect(data.priceAtTimestamp(99), noValueDouble);
      expect(data.priceAtTimestamp(100), closeTo(50.0*_vatMultiplier,0.0001));
      expect(data.priceAtTimestamp(199), closeTo(50.0*_vatMultiplier, 0.0001));
      expect(data.priceAtTimestamp(200), noValueDouble);
    });

    test('single day with transfer time', () {
      ElectricityPriceData data = ElectricityPriceData();
      data.tariff.setValue('test', TariffType.spot, 0.0);
      data.distributionPrice.setTimeOfDayParameters('test', 7, 22, 4.0, 2.0, 1.0);
      data.storeElectricityPrice([
        TrendElectricity(DateTime(2025,2,14).millisecondsSinceEpoch, 10),
        TrendElectricity(DateTime(2025,2,15).millisecondsSinceEpoch, noValueDouble)]);

      expect(data.prices.length, 4);
      expect(data.priceAtDateTime(DateTime(2025,2,13,23)), noValueDouble);
      expect(data.priceAtDateTime(DateTime(2025,2,15,0,1)), noValueDouble);
      expect(data.priceAtDateTime(DateTime(2025,2,14)), closeTo((10+2+1)*_vatMultiplier, 0000.1));
      expect(data.priceAtDateTime(DateTime(2025,2,14,6,59)), closeTo((10+2+1)*_vatMultiplier, 0000.1));
      expect(data.priceAtDateTime(DateTime(2025,2,14,7,0)), closeTo((10+4+1)*_vatMultiplier, 0000.1));
      expect(data.priceAtDateTime(DateTime(2025,2,14,21,59,59)), closeTo((10+4+1)*_vatMultiplier, 0000.1));
      expect(data.priceAtDateTime(DateTime(2025,2,14,22,00)), closeTo((10+2+1)*_vatMultiplier, 0000.1));
    });

    test('single day with tariff and transfer time change at the same time', () {
      ElectricityPriceData data = ElectricityPriceData();
      data.tariff.setValue('test', TariffType.spot, 0.0);
      data.distributionPrice.setTimeOfDayParameters('test', 7, 22, 4.0, 2.0, 1.0);
      data.storeElectricityPrice([
        TrendElectricity(DateTime(2025,2,14).millisecondsSinceEpoch, 10),
        TrendElectricity(DateTime(2025,2,14,7).millisecondsSinceEpoch, 20),
        TrendElectricity(DateTime(2025,2,15).millisecondsSinceEpoch, noValueDouble)]);

      expect(data.prices.length, 4);
      expect(data.priceAtDateTime(DateTime(2025,2,13,23)), noValueDouble);
      expect(data.priceAtDateTime(DateTime(2025,2,15,0,1)), noValueDouble);
      expect(data.priceAtDateTime(DateTime(2025,2,14)), closeTo((10+2+1)*_vatMultiplier, 0.0001));
      expect(data.priceAtDateTime(DateTime(2025,2,14,6,59)),closeTo((10+2+1)*_vatMultiplier, 0.0001));
      expect(data.priceAtDateTime(DateTime(2025,2,14,7,0)), closeTo((20+4+1)*_vatMultiplier, 0.0001));
      expect(data.priceAtDateTime(DateTime(2025,2,14,21,59,59)), closeTo((20+4+1)*_vatMultiplier, 0.0001));
      expect(data.priceAtDateTime(DateTime(2025,2,14,22,00)), closeTo((20+2+1)*_vatMultiplier, 0.0001));
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
        expect(e.prices.length, 25);
        printData(e);
        e.distributionPrice.setTimeOfDayParameters('test', 7, 23, 4.0, 2.0, 1.255);
        printData(e);
        expect(e.prices.length, 25);
      });

      test('long electricity price period', () {
        final e = ElectricityPriceData();
        e.distributionPrice.setTimeOfDayParameters('test', 7, 22, 4.0, 2.0, 1.255);
        e.storeElectricityPrice([TrendElectricity(DateTime(2025, 2, 15).millisecondsSinceEpoch, 10.0),
          TrendElectricity(DateTime(2025, 2, 18).millisecondsSinceEpoch, noValueDouble)]
        );
        DateTime d1 = DateTime.fromMillisecondsSinceEpoch(e.prices[0].timestamp);
        expect(d1.day, 15);
        expect(d1.hour, 0);
        expect(DateTime.fromMillisecondsSinceEpoch(e.prices[1].timestamp).hour, 7);
        expect(DateTime.fromMillisecondsSinceEpoch(e.prices[2].timestamp).hour, 22);
        expect(DateTime.fromMillisecondsSinceEpoch(e.prices[3].timestamp).hour, 7);
        expect(DateTime.fromMillisecondsSinceEpoch(e.prices[4].timestamp).hour, 22);
        expect(DateTime.fromMillisecondsSinceEpoch(e.prices[5].timestamp).hour, 7);
        expect(DateTime.fromMillisecondsSinceEpoch(e.prices[6].timestamp).hour, 22);
        expect(DateTime.fromMillisecondsSinceEpoch(e.prices[6].timestamp).day, 17);
        DateTime dlast = DateTime.fromMillisecondsSinceEpoch(e.prices[6].timestamp);
        expect(dlast.day, 17);
        expect(dlast.month, 2);
        expect(dlast.year, 2025);
        expect(dlast.hour, 22);
        expect(dlast.minute, 0);
        expect(e.prices.length, 8);
      });

  });


  group('Minimum Price Periods', () {
    test('special cases', () {
      final e = ElectricityPriceData();
      PriceAndTime p = e.findMinPriceWithinDuration(1);
      expect(p.price, noValueDouble);
      double d = e.averagePrice(0, 1);
      expect(d, noValueDouble);
      e.distributionPrice.setTimeOfDayParameters('test', 7, 23, 4.0, 2.0, 1);

      e.storeElectricityPrice([TrendElectricity(DateTime(2025, 2, 15).millisecondsSinceEpoch, 10.0),
        TrendElectricity(DateTime(2025, 2, 18).millisecondsSinceEpoch, noValueDouble)]
      );

      d = e.averagePrice(0, 1);
      expect(d, closeTo((10+2+1)*_vatMultiplier, 0.0001));
      expect( e.averagePrice(0, 7*60),closeTo((10+2+1)*_vatMultiplier, 0.0001));
      expect( e.averagePrice(0, 14*60),closeTo((10+3+1)*_vatMultiplier, 0.0001));
      expect( e.averagePrice(0, 21*60),closeTo((10+10/3+1)*_vatMultiplier,0.0001));
      expect( e.averagePrice(1, 14*60),closeTo((10+4+1)*_vatMultiplier, 0.0001));

      p = e.findMinPriceWithinDuration(1);
      expect(p.price, closeTo((10+2+1)*_vatMultiplier, 0.0001));
      expect(p.time, DateTime(2025, 2, 15));

    });

    test('one hour case', () {
      var e = ElectricityPriceData();
      e.distributionPrice.setTimeOfDayParameters('test', 7, 23, 4.0, 2.0, 1.0 );
      e.storeElectricityPrice([TrendElectricity(DateTime(2025, 2, 24, 12).millisecondsSinceEpoch, 10.0),
        TrendElectricity(DateTime(2025, 2, 24, 13).millisecondsSinceEpoch, noValueDouble)]
      );

      ElectricityChartData d = e.analyse();
      expect(d.minPrice.price, closeTo((10+4+1)*_vatMultiplier, 0.0001));
      expect(d.minPrice.time, DateTime(2025, 2, 24, 12));
      expect(d.min2hourPeriod.price, closeTo(noValueDouble, 0.0001));
      expect(d.min3hourPeriod.price, closeTo(noValueDouble, 0.0001));

    });


    test('first timestamp 0', () {
      var e = ElectricityPriceData();
      e.distributionPrice.setTimeOfDayParameters('test', 7, 23, 4.0, 2.0, 1.255);

      e.storeElectricityPrice([
        TrendElectricity(0, noValueDouble),
        TrendElectricity(DateTime(2025, 2, 26).millisecondsSinceEpoch, 10.0),
        TrendElectricity(DateTime(2025, 2, 27).millisecondsSinceEpoch, noValueDouble)]
      );
      expect(e.prices.length, 5);
      double priceInBegin = e.priceAtDateTime(DateTime(2025, 2, 26));
      ElectricityChartData d = e.analyse();
      expect(d.minPrice.price, closeTo(priceInBegin, 0.0001));
      expect(d.minPrice.time, DateTime(2025, 2, 26, 0));

    });
  });

  group('ElectricityPriceData Analyzer tests', () {
    test('empty data Analyzer tests', () {
      ElectricityPriceData data = ElectricityPriceData();
      expect(data.prices.isEmpty, isTrue);

      data.storeElectricityPrice([]);
      expect(data.prices.isEmpty, isTrue);

      data.distributionPrice.setConstantParameters('test', 0.0, 0.0);

      expect (data.findPercentile(1.0), noValueDouble);
    });

    test('single item Analyzer ', () {
      ElectricityPriceData data = ElectricityPriceData();
      data.storeElectricityPrice([
        TrendElectricity(100, 10.0),
        TrendElectricity(200, noValueDouble)]);

      data.distributionPrice.setConstantParameters('test', 0.0, 0.0);

      expect(data.findPercentile(1.0), 10.0*_vatMultiplier);
      expect(data.findPercentile(0.0), 10.0*_vatMultiplier);
    });


    test('multiple items Analyzer ', () {
      ElectricityPriceData data = ElectricityPriceData();
      data.storeElectricityPrice([
        TrendElectricity(00, 6.0),
        TrendElectricity(200, 5.0),
        TrendElectricity(300, 4.0),
        TrendElectricity(400, 1.0),
        TrendElectricity(500, 2.0),
        TrendElectricity(600, 3.0),
        TrendElectricity(1000, noValueDouble)]);

      data.distributionPrice.setConstantParameters('test', 0.0, 0.0);

      expect(data.findPercentile(0.0), 1.0*1.255);
      expect(data.findPercentile(1.0), 6.0*1.255);
      expect(data.findPercentile(0.5), 3.0*1.255);
      expect(data.findPercentile(0.75), 5.0*1.255);
    });

  });


  group('ElectricityPriceData Update tasks', () {
    test('empty data Analyzer tests', () {
      ElectricityPriceData data = ElectricityPriceData();
      data.distributionPrice.setConstantParameters('test', 0.0, 0.0);
      expect(data.prices.isEmpty, isTrue);

      data.updateElectricityPrice([]);
      expect(data.prices.isEmpty, isTrue);

      expect (data.findPercentile(1.0), noValueDouble);
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

