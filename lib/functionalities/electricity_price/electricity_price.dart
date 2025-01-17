
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:koti/functionalities/electricity_price/json/electricity_price_parameters.dart';
import 'package:koti/functionalities/electricity_price/view/electricity_price_view.dart';
import '../../devices/porssisahko/porssisahko.dart';
import '../../estate/estate.dart';
import '../../functionalities/functionality/functionality.dart';
import '../../devices/porssisahko/json/porssisahko_data.dart';
import '../../logic/my_change_notifier.dart';
import '../../look_and_feel.dart';
import '../functionality/view/functionality_view.dart';

int constantSlotSize = 60; // constant parameter that can be patched
                           // eg. testing 1 or in future 15

class ElectricityPriceTable {
  DateTime startingTime = DateTime(0);
  int slotSizeInMinutes = constantSlotSize;
  List <double> slotPrices = [];

  ElectricityPriceTable();

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
      case 1:
        return DateTime(d.year, d.month, d.day, d.hour, d.minute);
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
    if (slotPrices.isEmpty) {
      return 0.0;
    }
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
      return noValueDouble;
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

  String get name => _name;
  set name(String newName) { this._name = newName; }


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

  String get name => _name;
  set name(String newName) { this._name = newName; }

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

class ElectricityPriceDataNotifier extends MyChangeNotifier<ElectricityPriceTable> {
  ElectricityPriceDataNotifier(super.initData);
}

class ElectricityPriceListener extends BroadcastListener<ElectricityPriceTable>{
}


class ElectricityPrice extends Functionality {

  static const String functionalityName = 'sähkön hinta';

  DateTime loadingTime = DateTime(0);

  StockPriceListener stockPriceListener = StockPriceListener();

  ElectricityPriceDataNotifier electricity = ElectricityPriceDataNotifier(ElectricityPriceTable());
  BasicElectricityParameters parameters = BasicElectricityParameters();
  ElectricityTariff tariff = ElectricityTariff();
  ElectricityDistributionPrice distributionPrice = ElectricityDistributionPrice();

  ElectricityPrice() {
    myView = ElectricityGridBlock();
    myView.setFunctionality(this);
  }

  bool isInitialized() {
    return loadingTime.year != 0;
  }

  ElectricityPriceDataNotifier myBroadcaster() {
    return electricity;
  }

  void updateStockData(PorssisahkoData stockData) {

    if (stockData.prices.isNotEmpty) {
      ElectricityPriceTable data = ElectricityPriceTable();

      loadingTime = DateTime.now();

      electricity.data.slotPrices.clear();
      // todo: stockData.prices can be empty => how to avoid range error
      electricity.data.startingTime =
          electricity.data.crop(stockData.prices[0].startDate);

      for (int i = 0; i < stockData.prices.length; i++) {
        electricity.data.slotPrices.add(
            tariff.price(stockData.prices[i].price) +
                distributionPrice.price(data.startingTime.hour + i));
      }

      electricity.poke();

      log.info(
          'Pörssisähkön hintatiedot päivitetty (${connectedDevices[0].name})');
    }
    else {
      log.error('Error in stockData - empty prices');
    }
  }
/*
  ElectricityPriceTable initData() {

    ElectricityPriceTable data = ElectricityPriceTable();

    loadingTime = DateTime.now();

    data.startingTime = electricity.data.crop(stockPriceListener.data.prices[0].startDate);
    electricity.data.slotPrices.clear();

    for (int i=0; i<stockPriceListener.data.prices.length; i++) {
      data.slotPrices.add(
          tariff.price(stockPriceListener.data.prices[i].price)+
              distributionPrice.price(data.startingTime.hour+i));
    }

    return data;
  }


 */
  @override
  Future <void> init() async {
    if (connectedDevices.isEmpty) {
      log.error('ElectricityPrice connectedDevices is missing Porssisahko');
    }
    else {
      Porssisahko stockElectricity = (connectedDevices[0] as Porssisahko);
      stockPriceListener.start(
          stockElectricity.myBroadcaster(), updateStockData);
      initOperationModes();
    }
  }

  void initOperationModes() {

    operationModes.initModeStructure(
        estate: myEstates.estateFromId(connectedDevices[0].myEstateId),
        parameterSettingFunctionName: '',
        deviceId: connectedDevices[0].id,
        deviceAttributes: [],
        setFunction: (){},
        getFunction: (){}
    );
  }


  ElectricityPriceTable get([DateTime? startingTimeParameter]) {

    // either use user given starting time or starting time of the whole data
    DateTime startingTime = startingTimeParameter ?? electricity.data.startingTime;
    ElectricityPriceTable e = ElectricityPriceTable();
    int startingIndex = electricity.data.findIndex(startingTime);

    e.startingTime = electricity.data.crop(startingTime);

    if (startingIndex < 0) {
      return e;
    }

    for (int i=startingIndex;i<electricity.data.slotPrices.length; i++) {
      e.slotPrices.add(electricity.data.slotPrices[i]);
    }
    return e;
  }

  double currentPrice() {
    return electricity.data.currentPrice();
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: functionalityName,
        textLines: [
          'tunnus: $id',
          'latausaika: ${dumpTimeString(loadingTime)}',
          'sähkösopimus: ${tariff.name}',
          'jakelusopimus: ${distributionPrice.name}',
        ],
        widgets: [
          dumpDataMyDevices(formatterWidget: formatterWidget)
        ]
    );
  }
/*
  @override
  FunctionalityView myView() {
    return ElectricityGridBlock(id);
  }


 */

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['electricityTariff'] = tariff.toJson();
    json['distributionTariff'] = distributionPrice.toJson();
    return json;
  }

  @override
  ElectricityPrice.fromJson(Map<String, dynamic> json)  : super.fromJson(json) {
    myView = ElectricityGridBlock();
    myView.setFunctionality(this);
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

class SlotAndPrice{
  int day = -1;
  int hour = -1;
  int minute = -1;
  double slotPrice = -99.9;
}



