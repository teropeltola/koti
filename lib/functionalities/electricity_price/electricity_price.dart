
import 'dart:async';

import 'package:provider/provider.dart';

import '../../devices/porssisahko/porssisahko.dart';
import '../../functionalities/functionality/functionality.dart';
import '../../devices/porssisahko/json/porssisahko_data.dart';

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

  double findPercentile(double percentile) {
    List <double> sortedList = List.from(slotPrices);
    sortedList.sort();
    int index = _countPercentileIndex(percentile);
    return sortedList[index];
  }

  int _countPercentileIndex(double percentile) {
    return (percentile <= 0) ? 0 : (percentile >= 1) ? (slotPrices.length-1) :
    (percentile * slotPrices.length).ceil()-1;
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

  DateTime slotStartingTime(int index) {
    return (startingTime.add(Duration(minutes:index*slotSizeInMinutes)));
  }

  DateTime lastMinuteOfPeriod() {
    return startingTime.add(Duration(minutes: nbrOfMinutes()- 1));
  }

  int nbrOfMinutes() {
    return slotPrices.length*slotSizeInMinutes;
  }

}

enum PriceChange {decline, flat, increase}

enum TariffType {constant, spot}

enum DistributionTariffType {timeOfDay, constant}

const vatMultiplier = 1.24;

class ElectricityTariff {
  String _name = '';
  TariffType _tariffType = TariffType.spot;
  double _parameterValue = 0.0;

  ElectricityTariff();

  void setValue (String newName, TariffType newType, double newParameter) {
    _name = newName;
    _tariffType = newType;
    _parameterValue = newParameter;
  }

  double price(double stockPrice) {

    if (_tariffType == TariffType.spot) {
      return stockPrice  + _parameterValue;
    }
    else {
      return _parameterValue;
    }
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

  void setConstantParameters(String newName, double tariff, double electricityTax) {
    _name = newName;
    _type = DistributionTariffType.constant;
    _dayTransferTariff = tariff;
    _electricityTax = electricityTax;
  }

  bool constantTariff() {
    return _type == TariffType.constant;
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

  double price(int hour) {
    return currentTransferTariff(hour) + _electricityTax;
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

class ElectricityPrice extends Functionality {

  DateTime loadingTime = DateTime(0);
  ElectricityPriceTable data = ElectricityPriceTable();
  ElectricityTariff tariff = ElectricityTariff();
  ElectricityDistributionPrice distributionPrice = ElectricityDistributionPrice();

  ElectricityPrice() {
    allFunctionalities.addFunctionality(this);
  }

  bool isInitialized() {
    return loadingTime.year != 0;
  }

  Future <void> init() async {

    PorssisahkoData stockElectricityPrice = (device as Porssisahko).data;

    loadingTime = DateTime.now();

    // todo: check if stockEle data is empty
    data.startingTime = data.crop(stockElectricityPrice.prices[0].startDate);
    data.slotPrices.clear();

    for (int i=0; i<stockElectricityPrice.prices.length; i++) {
      data.slotPrices.add(
          tariff.price(stockElectricityPrice.prices[i].price)+
              distributionPrice.price(data.startingTime.hour+i));
    }
  }

  ElectricityPriceTable get([DateTime? startingTimeParameter]) {

    // either use user given starting time or starting time of the whole data
    DateTime startingTime = startingTimeParameter ?? data.startingTime;
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

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['electricityTariff'] = tariff.toJson();
    json['distributionTariff'] = distributionPrice.toJson();
    return json;
  }

  @override
  ElectricityPrice.fromJson(Map<String, dynamic> json)  : super.fromJson(json) {
    tariff = ElectricityTariff.fromJson(json['electricityTariff']);
    distributionPrice = ElectricityDistributionPrice.fromJson(json['distributionTariff']);
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

class slotAndPrice{
  int day = -1;
  int hour = -1;
  int minute = -1;
  double slotPrice = -99.9;
}



