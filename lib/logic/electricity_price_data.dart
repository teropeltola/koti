
import 'package:koti/devices/porssisahko/json/porssisahko_data.dart';

import '../functionalities/electricity_price/electricity_price.dart';
import '../functionalities/electricity_price/json/electricity_price_parameters.dart';
import '../functionalities/electricity_price/trend_electricity.dart';
import '../look_and_feel.dart';


enum PriceChange {decline, flat, increase}

enum TariffType {constant, spot}

enum DistributionTariffType {timeOfDay, constant}

class ElectricityTariff {
  String _name = '';
  TariffType _tariffType = TariffType.spot;
  double _parameterValue = 0.0;

  ElectricityTariff();

  String get name => _name;
  set name(String newName) { _name = newName; }

  void setValue (String newName, TariffType newType, double newParameter) {
    _name = newName;
    _tariffType = newType;
    _parameterValue = newParameter;
  }

  double priceWithoutVat(double stockPrice) {

    if (_tariffType == TariffType.spot) {
      return stockPrice  + _parameterValue;
    }
    else {
      return _parameterValue;
    }
  }

  double priceWithVat(double stockPrice) {
    return priceWithoutVat(stockPrice) * electricityPriceParameters.vatMultiplier();
  }

  double reversePriceWithoutVat(double stockPrice) {
    return stockPrice / electricityPriceParameters.vatMultiplier();
  }

  double spot(double stockPrice) {
    return (stockPrice-_parameterValue);
  }

  double margin() {
    return (_parameterValue);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json['name'] = _name;
    json['type'] = _tariffType == TariffType.spot ? 'spot' : 'const';
    json['par'] = _parameterValue;
    return json;
  }

  ElectricityTariff.fromJson(Map<String, dynamic> json) {
    _name = json['name'] ?? '';
    _tariffType = (json['type'] == 'spot' ? TariffType.spot : TariffType.constant);
    _parameterValue = json['par'];
  }

}

class ElectricityDistributionPrice {
  String _name = '';
  DistributionTariffType _type = DistributionTariffType.timeOfDay;
  int _dayTimeStartingHour = 0;
  int _dayTimeEndingHour = 0;
  double _dayTransferTariff = 0.0;
  double _nightTransferTariff = 0.0;
  double _electricityTax = 0.0;

  ElectricityDistributionPrice();

  String get name => _name;
  set name(String newName) { _name = newName; }

  void setTimeOfDayParameters(String newName,
      int dayTimeStarting,
      int dayTimeEnding,
      double dayTariff,
      double nightTariff,
      double electricityTax) {
    _name = newName;
    _type = DistributionTariffType.timeOfDay;
    _dayTimeStartingHour = dayTimeStarting;
    _dayTimeEndingHour = dayTimeEnding;
    _dayTransferTariff = dayTariff;
    _nightTransferTariff = nightTariff;
    _electricityTax = electricityTax;
  }

  double electricityTaxWithoutVat() {
    return _electricityTax;
  }

  void setConstantParameters(String newName, double tariff, double electricityTax) {
    _name = newName;
    _type = DistributionTariffType.constant;
    _dayTransferTariff = tariff;
    _electricityTax = electricityTax;
  }

  bool constantTariff() {
    return _type == DistributionTariffType.constant;
  }

  bool dayTime(int originalHour) {
    int hour = originalHour % 24;
    return ((hour >= _dayTimeStartingHour) && (hour < _dayTimeEndingHour));
  }

  double currentTransferTariff(int hour) {
    if (constantTariff()) {
      return _dayTransferTariff;
    }
    else {
      return (dayTime(hour) ? _dayTransferTariff : _nightTransferTariff);
    }
  }

  double priceWithoutVat(int hour) {
    return currentTransferTariff(hour) + _electricityTax;
  }

  double priceWithVat(int hour) {
    return priceWithoutVat(hour) * electricityPriceParameters.vatMultiplier();
  }

  // returns a timestamp of the time when the previous tariff change will
  // occur earlier than the given timestamp
  int previousTariffChange(int timestamp) {
    if (constantTariff()) {
      return 0;
    }
    else {
      DateTime d = DateTime.fromMillisecondsSinceEpoch(timestamp);
      int hour = d.hour;
      if (dayTime(hour)) {
        return DateTime(d.year, d.month, d.day, _dayTimeStartingHour).millisecondsSinceEpoch;
      }
      else {
        int day = (d.hour < _dayTimeStartingHour) ? d.day-1 : d.day;
        return DateTime(d.year, d.month, day, _dayTimeEndingHour).millisecondsSinceEpoch;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json['name'] = _name;
    json['type'] = _type == DistributionTariffType.timeOfDay ? 'timeOfDay' : 'const';
    json['dayTimeStarting'] = _dayTimeStartingHour;
    json['dayTimeEnding'] = _dayTimeEndingHour;
    json['dayTariff'] = _dayTransferTariff;
    json['nightTariff'] = _nightTransferTariff;
    json['electricityTax'] = _electricityTax;
    return json;
  }

  ElectricityDistributionPrice.fromJson(Map<String, dynamic> json) {
    _name = json['name'] ?? '';
    _type = (json['type'] == 'timeOfDay' ? DistributionTariffType.timeOfDay : DistributionTariffType.constant);
    _dayTimeStartingHour = json['dayTimeStarting'];
    _dayTimeEndingHour = json['dayTimeEnding'];
    _dayTransferTariff = json['dayTariff'];
    _nightTransferTariff = json['nightTariff'];
    _electricityTax = json['electricityTax'];
  }

}



int constantSlotSize = 60; // constant parameter that can be patched
// eg. testing 1 or in future 15

class ElectricityTotalPriceItem {
  int timestamp = 0;
  double electricityPrice = noValueDouble;
  double transferPrice = noValueDouble;

  ElectricityTotalPriceItem();

  double get totalPrice => (electricityPrice != noValueDouble) && (transferPrice != noValueDouble)
      ? electricityPrice + transferPrice
      : noValueDouble;
}

class ElectricityPriceData {
  List <ElectricityTotalPriceItem> prices = [];
  ElectricityTariff tariff = ElectricityTariff();
  ElectricityDistributionPrice distributionPrice = ElectricityDistributionPrice();

  int slotSizeInMinutes = constantSlotSize;

  ElectricityPriceData();


  void storeElectricityPrice(List <TrendElectricity> electricityPrices) {
    prices.clear();
    for (var e in electricityPrices) {
      ElectricityTotalPriceItem item = ElectricityTotalPriceItem();
      item.timestamp = e.timestamp;
      item.electricityPrice = noValue(e.price) ? noValueDouble : tariff.priceWithVat(e.price);
      prices.add(item);
    }
    _storeTransferPrice(0);
  }

  void updateElectricityPrice(List <TrendElectricity> electricityPrices) {
    int latestTimestamp = prices.last.timestamp;
    int startingIndex = 0;
    for (int index=0; index<electricityPrices.length; index++) {
      if (electricityPrices[index].timestamp >= latestTimestamp) {
        startingIndex = index;
        break;
      }
    }
    for (int index=startingIndex; index<electricityPrices.length; index++) {
      ElectricityTotalPriceItem item = ElectricityTotalPriceItem();
      item.timestamp = electricityPrices[index].timestamp;
      item.electricityPrice = noValue(electricityPrices[index].price) ? noValueDouble : tariff.priceWithVat(electricityPrices[index].price);
      prices.add(item);
    }
    _storeTransferPrice(startingIndex);
  }

  void _storeTransferPrice(int fromIndex) {
    if (prices.length <= 1) {
      // only the dummy item is present
      return;
    }
    if (distributionPrice.constantTariff()) {
      for (int index=fromIndex; index<prices.length; index++) {
        prices[index].transferPrice = distributionPrice.priceWithVat(12); // parameter 'hour' is not used
      }
    }
    else {
      // fill transfer prices to the existing items
      for (int index=fromIndex; index<prices.length; index++) {
        if (prices[index].electricityPrice != noValueDouble) {
          prices[index].transferPrice = distributionPrice.priceWithVat(
            DateTime.fromMillisecondsSinceEpoch(
                prices[index].timestamp)
                .hour);
        }
      }

      // add possible tariff changes if they are between items
      int previousTariffChange = distributionPrice.previousTariffChange(prices.last.timestamp);
      int endIndex = prices.length-1;
      for (int index=endIndex; index>=fromIndex; index--) {
        if (prices[index].totalPrice != noValueDouble) {
          while (previousTariffChange >= prices[index].timestamp) {
            // if the tariff change is exactly at the same time as the item timestamp then
            // just skip the tariff change => no need to add items
            if (previousTariffChange > prices[index].timestamp) {
              // tariff change during the slot => add new item for different tariffs
              ElectricityTotalPriceItem item = ElectricityTotalPriceItem();
              item.timestamp = previousTariffChange;
              item.electricityPrice = prices[index].electricityPrice;
              item.transferPrice = distributionPrice.priceWithVat(DateTime
                  .fromMillisecondsSinceEpoch(previousTariffChange)
                  .hour);
              prices.insert(index + 1, item);
            }
            previousTariffChange = distributionPrice.previousTariffChange(
                previousTariffChange - 1);
          }
        }
      }
    }
  }

  double priceAtTimestamp(int timestamp) {
    for (int index=prices.length-1; index>=0; index--) {
      if (prices[index].timestamp <= timestamp) {
        return prices[index].totalPrice;
      }
    }
    return noValueDouble;
  }

  double priceAtDateTime(DateTime dateTime) {
    return priceAtTimestamp(  dateTime.millisecondsSinceEpoch);
  }

  DateTime startingTime() {
    if (prices.isEmpty) {
      return DateTime(0);
    }
    else {
      return DateTime.fromMillisecondsSinceEpoch(prices[0].timestamp);
    }
  }
  //int slotSizeInMinutes = constantSlotSize;
  //List <double> slotPrices = [];

  int findIndex(DateTime myTime) {
    int timestamp = myTime.millisecondsSinceEpoch;

    for (int index=prices.length-1; index>=0; index--) {
      if (prices[index].timestamp <= timestamp) {
        return index;
      }
    }
    return -1;
  }

  DateTime crop(DateTime d) {
    switch (slotSizeInMinutes) {
      case 60:
        return DateTime(d.year, d.month, d.day, d.hour);
      case 15:
        return DateTime(d.year, d.month, d.day, d.hour, 15 * (d.minute ~/ 15));
      case 1:
        return DateTime(d.year, d.month, d.day, d.hour, d.minute);
      default:
        return DateTime(0);
    }
  }

  bool isEmpty() {
    return prices.isEmpty;
  }

  double averagePrice(int firstIndex, int durationInMinutes) {
    int index = firstIndex;
    int durationLeft = durationInMinutes * 60000; // durationLeft in milliseconds
    double weightedSum = 0.0;

    if (prices.isEmpty) {
      return noValueDouble;
    }

    while (durationLeft > 0) {
      if (prices[index].totalPrice == noValueDouble) {
        // no price data for this time period
        return noValueDouble;
      }
      int indexDuration = prices[index+1].timestamp - prices[index].timestamp;
      if (indexDuration < durationLeft) {
        weightedSum += prices[index].totalPrice * indexDuration;
        durationLeft -= indexDuration;
        index++;
        if (index >= prices.length-1) {
          // no price data because the time period is too long
          return noValueDouble;
        }
      }
      else {
        weightedSum += prices[index].totalPrice * durationLeft;
        durationLeft = 0;
      }
    }
    return weightedSum / durationInMinutes / 60000;
  }

  static final _fakeMin  = 123456789.123;

  PriceAndTime findMinPriceWithinDuration(int durationInMinutes) {
    PriceAndTime result = PriceAndTime();
    result.price = _fakeMin;
    for (int index = 0; index<prices.length-1; index++) {
      double price = averagePrice(index, durationInMinutes);
      if ((price != noValueDouble) && (price < result.price)) {
        result.time = DateTime.fromMillisecondsSinceEpoch(prices[index].timestamp);
        result.price = price;
      }
    }
    if (result.price == _fakeMin) {
      result.price = noValueDouble;
    }
    return result;
  }

  ElectricityChartData analyse() {
    ElectricityChartData e = ElectricityChartData();

    e.minPrice = findMinPriceWithinDuration(60);
    e.min2hourPeriod = findMinPriceWithinDuration(120);
    e.min3hourPeriod = findMinPriceWithinDuration(180);

    for (var item in prices) {
      if (item.totalPrice != noValueDouble) {
        if (item.totalPrice > e.maxPrice.price) {
          e.maxPrice.price = item.totalPrice;
          e.maxPrice.time = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
        }
      }
    }

    e.yAxisMax = e.maxPrice.price;
    e.yAxisMin = 0; // e.minPrice;
    e.yAxisInterval = ((e.yAxisMax- e.yAxisMin) / 10);

    return e;
  }


  double findPercentile(double percentile) {
    Analyzer analyzer = Analyzer();
    analyzer.init(this);
    return analyzer.findPercentile(percentile);
  }

  double currentPrice() {
    int index = findIndex(DateTime.now());
    if (index == -1) {
      return noValueDouble;
    }
    else {
      return prices[index].totalPrice;
    }
  }

  PriceComponents currentPriceComponents() {
    int index = findIndex(DateTime.now());
    PriceComponents result = PriceComponents();
    if (index != -1) {
      result.electricityPriceVat = electricityPriceParameters.vatOf(prices[index].electricityPrice);
      double eWithoutVat = prices[index].electricityPrice - result.electricityPriceVat;
      result.spot = tariff.spot(eWithoutVat);
      result.electricityPriceMargin = tariff.margin();
      result.distributionVat = electricityPriceParameters.vatOf(prices[index].transferPrice);
      result.distributionPrice = distributionPrice.currentTransferTariff(DateTime.now().hour);
      result.electricityTax = distributionPrice.electricityTaxWithoutVat();
    }
    return result;
  }

  PriceChange priceChange() {
    int index = findIndex(DateTime.now());
    if (index == -1) {
      return PriceChange.flat;
    }
    double currentPrice = prices[index].totalPrice;
    double delta = currentPrice * 0.1;
    double sum = 0.0;
    int count = 0;

    for (int i=index+1; i<prices.length; i++) {
      sum += prices[i].totalPrice;
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

  DateTime slotStartingTime(int index) {
    return DateTime.fromMillisecondsSinceEpoch(prices[index].timestamp);
  }

  DateTime lastMinuteOfPeriod() {
    return DateTime.fromMillisecondsSinceEpoch(prices.last.timestamp);
  }

  int nbrOfMinutes() {
    return startingTime().difference(lastMinuteOfPeriod()).inMinutes;
  }

  ElectricityPriceData  getData ([DateTime? startingTimeParameter])  {
    if (startingTimeParameter == null) {
      return this;
    }

    ElectricityPriceData result = ElectricityPriceData();
    result.tariff = tariff;
    result.distributionPrice = distributionPrice;
    result.slotSizeInMinutes = slotSizeInMinutes;
    int startingIndex = findIndex(startingTimeParameter);
    if (startingIndex >= 0) {
        result.prices = prices.sublist(startingIndex);
    }
    return result;
  }
}

class PriceComponents {
  double spot = noValueDouble;
  double electricityPriceMargin = noValueDouble;
  double electricityPriceVat = noValueDouble;
  double distributionPrice = noValueDouble;
  double electricityTax = noValueDouble;
  double distributionVat = noValueDouble;
}

class PriceAndTime {
  double price = noValueDouble;
  DateTime time = DateTime(0);
}

class PriceAndDuration {
  int timestamp = 0;
  int duration = 0;
  double price = 0.0;

  PriceAndDuration(this.timestamp, this.duration, this.price);
}

class Analyzer {
  List <PriceAndDuration> sortedList = [];
  int totalDuration = 0;

  void init(ElectricityPriceData electricityPriceData) {
    sortedList.clear();
    totalDuration = 0;

    for (int index = 0; index < electricityPriceData.prices.length-1; index++) {
      if (electricityPriceData.prices[index].totalPrice != noValueDouble) {
        int duration = electricityPriceData.prices[index + 1].timestamp -
            electricityPriceData.prices[index].timestamp;
        totalDuration += duration;
        sortedList.add(PriceAndDuration(
            electricityPriceData.prices[index].timestamp,
            duration,
            electricityPriceData.prices[index].totalPrice));
      }
    }
    sortedList.sort((a, b) => a.price.compareTo(b.price));
  }

  double findPercentile(double percentile) {
    int percentileDuration = (percentile * totalDuration).floor();
    double indexPercentile = 0.0;
    for (var item in sortedList) {
      indexPercentile += item.duration;
      if (indexPercentile >= percentileDuration) {
        return item.price;
      }
    }
    return sortedList.isEmpty ? noValueDouble : sortedList.last.price;
  }
}