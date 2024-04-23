import 'package:flutter_test/flutter_test.dart';
import 'package:koti/functionalities/electricity_price/electricity_price.dart';

void main() {
  group('ElectricityPriceTable tests', () {
    test('findIndex should return correct index', () {
      var electricityPriceTable = ElectricityPriceTable();
      electricityPriceTable.startingTime = DateTime(2024, 4, 16, 0, 0);
      electricityPriceTable.slotSizeInMinutes = 60;
      electricityPriceTable.slotPrices = [1.0, 2.0, 3.0]; // Example slot prices.

      expect(electricityPriceTable.findIndex(DateTime(2024, 4, 16, 1, 0)), 1);
      expect(electricityPriceTable.findIndex(DateTime(2024, 4, 16, 2, 30)), 2);
      // Add more test cases for different scenarios.
    });

    // Add more test cases for other methods of ElectricityPriceTable.
  });

  group('ElectricityPriceTable tests', () {
    test('findIndex should return correct index', () {
      var electricityPriceTable = ElectricityPriceTable();
      electricityPriceTable.startingTime = DateTime(2024, 4, 16, 0, 0);
      electricityPriceTable.slotSizeInMinutes = 60;
      electricityPriceTable.slotPrices = [1.0, 2.0, 3.0]; // Example slot prices.

      // Test for finding an index within the slot prices range.
      expect(electricityPriceTable.findIndex(DateTime(2024, 4, 16, 1, 0)), 1);

      // Test for finding an index before the starting time.
      expect(electricityPriceTable.findIndex(DateTime(2024, 4, 15, 23, 0)), -1);

      // Test for finding an index after the slot prices range.
      expect(electricityPriceTable.findIndex(DateTime(2024, 4, 16, 4, 0)), -1);

      // Add more test cases for different scenarios.
    });

    test('crop should return a cropped DateTime', () {
      var electricityPriceTable = ElectricityPriceTable();
      electricityPriceTable.slotSizeInMinutes = 60;

      // Test for cropping DateTime with slot size of 60 minutes.
      expect(electricityPriceTable.crop(DateTime(2024, 4, 16, 1, 20)), DateTime(2024, 4, 16, 1, 0));

      // Test for cropping DateTime with slot size of 15 minutes.
      electricityPriceTable.slotSizeInMinutes = 15;
      expect(electricityPriceTable.crop(DateTime(2024, 4, 16, 1, 20)), DateTime(2024, 4, 16, 1, 15));

      // Add more test cases for different scenarios.
    });

    test('findPercentile tests', () {
      var electricityPriceTable = ElectricityPriceTable();
      electricityPriceTable.slotPrices = [0.0, 1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9];

      expect(electricityPriceTable.findPercentile(-0.1), 0.0);
      expect(electricityPriceTable.findPercentile(10.1), 9.9);
      expect(electricityPriceTable.findPercentile(0.5), 4.4);

      electricityPriceTable.slotPrices = [10.0, 1.0];

      expect(electricityPriceTable.findPercentile(0.5), 1.0);
      expect(electricityPriceTable.findPercentile(-0.1), 1.0);
      expect(electricityPriceTable.slotPrices[0],10.0);


    });

  });

  // Add more test groups for other classes and methods as needed.
}
