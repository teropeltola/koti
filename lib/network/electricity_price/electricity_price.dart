
import 'dart:async';

import '../../look_and_feel.dart';
import 'json/porssisahko_fi.dart';

class ElectricityPriceTable {
  DateTime startingTime = DateTime(0);
  int slotSizeInMinutes = 60;
  List <double> slotPrices = [];

  int findIndex(DateTime myTime) {
    Duration diff = myTime.difference(startingTime);

    if (diff.inMinutes < 0) {
      return -1;
    }

    int slotIndex = diff.inMinutes ~/ slotSizeInMinutes;

    if ((slotIndex >= 0) && (slotIndex < slotPrices.length)) {
      return slotIndex;
    }
    else {
      return -1;
    }
  }

  DateTime crop(DateTime d) {
    switch (slotSizeInMinutes) {
      case 60:
        return DateTime(d.year, d.month, d.day, d.hour);
      case 15:
        return DateTime(d.year, d.month, d.day, d.hour, 15 * (d.minute ~/ 15));
      default:
        return DateTime(0);
    }
  }

  bool isEmpty() {
    return slotPrices.isEmpty;
  }

  ElectricityChartData analyse() {
    ElectricityChartData e = ElectricityChartData();

    for (int i=0; i<slotPrices.length; i++) {
      if (slotPrices[i] < e.minPrice) {
        e.minPrice = slotPrices[i];
        e.minPriceTime = DateTime(startingTime.year, startingTime.month, startingTime.day, startingTime.hour+i);
      }
      if (slotPrices[i] > e.maxPrice) {
        e.maxPrice = slotPrices[i];
        e.maxPriceTime = DateTime(startingTime.year, startingTime.month, startingTime.day, startingTime.hour+i);
      }
    }
    for (int i=0; i<slotPrices.length-1; i++) {
      double x = (slotPrices[i]+slotPrices[i+1])/2;
      if (x < e.min2hourPeriodPrice) {
        e.min2hourPeriodPrice = x;
        e.min2hourPeriod = DateTime(startingTime.year, startingTime.month, startingTime.day, startingTime.hour+i);
      }
    }
    for (int i=0; i<slotPrices.length-2; i++) {
      double x = (slotPrices[i]+slotPrices[i+1]+slotPrices[i+2])/3;
      if (x < e.min3hourPeriodPrice) {
        e.min3hourPeriodPrice = x;
        e.min3hourPeriod = DateTime(startingTime.year, startingTime.month, startingTime.day, startingTime.hour+i);
      }
    }
    e.yAxisMax = e.maxPrice;
    e.yAxisMin = 0; // e.minPrice;
    e.yAxisInterval = ((e.yAxisMax- e.yAxisMin) / 10);

    return e;
  }

  double currentPrice() {
    int index = findIndex(DateTime.now());
    if (index == -1) {
      return -9999.0;
    }
    else {
      return slotPrices[index];
    }
  }

  PriceChange priceChange() {
    int index = findIndex(DateTime.now());
    if (index == -1) {
      return PriceChange.flat;
    }
    double currentPrice = slotPrices[index];
    double delta = currentPrice * 0.1;
    double sum = 0.0;
    int count = 0;

    for (int i=index+1; i<slotPrices.length; i++) {
      sum += slotPrices[i];
      count++;
    }
    if (sum/count < currentPrice - delta) {
      return PriceChange.decline;
    }
    else if (sum/count > currentPrice + delta) {
      return PriceChange.increase;
    }
    else {
      return PriceChange.flat;
    }
  }

  double maxPrice() {
    return 30.0;
  }

  double minPrice() {
    return 5.0;
  }

}

enum PriceChange {decline, flat, increase}

const vatMultiplier = 1.24;

class FortumTariff {
  final addOnMargin = 0.4;

  double price(double stockPrice) {
    return stockPrice+addOnMargin;
  }
}

class TransferCost {
  final dayTimeStartingHour = 7;
  final dayTimeEndingHour = 21;
  final dayTransferTariff = 2.59;
  final nightTransferTariff = 1.35;
  final electricityTax = 2.79372;

  bool dayTime(int originalHour) {
    int hour = originalHour % 24;
    return ((hour >= dayTimeStartingHour) && (hour <= dayTimeEndingHour));
  }
  double currentTransferTariff(int hour) {
    return (dayTime(hour) ? dayTransferTariff : nightTransferTariff );
  }
  double price(int hour) {
    return currentTransferTariff(hour) + electricityTax;
  }
}

class ElectricityPrice {

  DateTime loadingTime = DateTime(0);
  ElectricityPriceTable data = ElectricityPriceTable();

  bool isInitialized() {
    return loadingTime.year != 0;
  }

  Future <void> init() async {

    PorssisahkoFi stockElectricityPrice = PorssisahkoFi(prices: []);

    stockElectricityPrice = await readPorssisahkoParameters();

    if (stockElectricityPrice.isEmpty()) {
      return;
    }

    loadingTime = DateTime.now();

    data.startingTime = data.crop(stockElectricityPrice.prices[0].startDate);
    data.slotPrices.clear();

    for (int i=0; i<stockElectricityPrice.prices.length; i++) {
      data.slotPrices.add(
          FortumTariff().price(stockElectricityPrice.prices[i].price)+
              TransferCost().price(data.startingTime.hour+i));
    }
  }

  ElectricityPriceTable get(DateTime startingTime) {

    ElectricityPriceTable e = ElectricityPriceTable();
    int startingIndex = data.findIndex(startingTime);

    e.startingTime = data.crop(startingTime);

    if (startingIndex < 0) {
      return e;
    }

    for (int i=startingIndex;i<data.slotPrices.length; i++) {
      e.slotPrices.add(data.slotPrices[i]);
    }
    return e;
  }

  double currentPrice() {
    return data.currentPrice();
  }
}

const double notAvailablePrice = 999999.0;


class ElectricityChartData {
  double minPrice = notAvailablePrice;
  double min2hourPeriodPrice = notAvailablePrice;
  double min3hourPeriodPrice = notAvailablePrice;

  DateTime minPriceTime = DateTime(0);
  DateTime min2hourPeriod = DateTime(0);
  DateTime min3hourPeriod = DateTime(0);

  double maxPrice = -notAvailablePrice;
  DateTime maxPriceTime = DateTime(0);

  double yAxisInterval = 1.0;
  double yAxisMax = 10.0;
  double yAxisMin = 0.0;
}

ElectricityPrice myElectricityPrice = ElectricityPrice();


const int _fetchingStartHour = 14;
const int _fetchingStartMinutes = 15;
const int _retryInterval = 15;

class InternetInfoFetcher {
  late int _fetchingHour;
  late int _fetchingMinutes;
  late int _retryInterval;

  late Timer _dailyTimer;
  late Timer _retryTimer;

  InternetInfoFetcher(int hour, int minutes, int retryInterval) {
    _fetchingHour = hour;
    _fetchingMinutes = minutes;
    _retryInterval = retryInterval;

    _setupDailyTimer();
  }

  void _setupDailyTimer() {
    DateTime now = DateTime.now();

    int hours = 0;

    // Calculate the time until the next 14:00
    if ((now.hour > _fetchingHour) ||
        ((now.hour == _fetchingHour) && (now.minute >= _fetchingMinutes))) {
      hours = 24-now.hour + _fetchingHour;
    }
    else {
      hours = _fetchingHour - now.hour;
    }
    Duration initialDelay = Duration(
      hours: hours,
      minutes: _fetchingMinutes-now.minute,
      seconds: -now.second,
    );

    // Schedule the daily task at given time
    _dailyTimer = Timer(initialDelay, () {
      _fetchInformation();
      _setupRetryTimer();
    });
  }

  void _setupRetryTimer() {
    // Retry every set interval
    _retryTimer = Timer.periodic(Duration(minutes: 15), (timer) {
      _fetchInformation();
      _setupRetryTimer();
    });
  }

  Future<void> _fetchInformation() async {
    // Implement your logic to fetch information from the internet
    // This could involve using HTTP requests, Dio, or any other networking library

    // For example, you might use the http package
    // import 'package:http/http.dart' as http;
    // http.get('your_api_endpoint');

    // Replace the above with your actual implementation
    log.info('fetching information fr');
  }
}
