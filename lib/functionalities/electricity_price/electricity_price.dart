
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:koti/app_configurator.dart';
import 'package:koti/foreground_configurator.dart';

import 'package:koti/functionalities/electricity_price/trend_electricity.dart';
import 'package:koti/functionalities/electricity_price/view/electricity_price_view.dart';
import 'package:koti/interfaces/foreground_interface.dart';
import 'package:path_provider/path_provider.dart';
import '../../devices/porssisahko/porssisahko.dart';
import '../../estate/estate.dart';
import '../../functionalities/functionality/functionality.dart';
import '../../logic/electricity_price_data.dart';
import '../../logic/my_change_notifier.dart';
import '../../look_and_feel.dart';

int constantSlotSize = 60; // constant parameter that can be patched
                           // eg. testing 1 or in future 15
/*
class XElectricityPriceTable {
  DateTime startingTime = DateTime(0);
  int slotSizeInMinutes = constantSlotSize;
  List <double> slotPrices = [];

  XElectricityPriceTable();

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
      if (slotPrices[i] < e.minPrice.price) {
        e.minPrice.price = slotPrices[i];
        e.minPrice.time = DateTime(startingTime.year, startingTime.month, startingTime.day, startingTime.hour+i);
      }
      if (slotPrices[i] > e.maxPrice.price) {
        e.maxPrice.price = slotPrices[i];
        e.maxPrice.time = DateTime(startingTime.year, startingTime.month, startingTime.day, startingTime.hour+i);
      }
    }
    e.min2hourPeriod = min
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

 */

class ElectricityPriceDataNotifier extends MyChangeNotifier<ElectricityPriceData> {
  ElectricityPriceDataNotifier(super.initData);
}

class ElectricityPriceListener extends BroadcastListener<ElectricityPriceData>{
}

class ElectricityPrice extends Functionality {

  static const String functionalityName = 'sähkön hinta';

  DateTime loadingTime = DateTime(0);

  //StockPriceListener stockPriceListener = StockPriceListener();

  ElectricityPriceDataNotifier electricity = ElectricityPriceDataNotifier(ElectricityPriceData());

  ElectricityPrice() {
    myView = ElectricityGridBlock();
    myView.setFunctionality(this);
  }

  bool isInitialized() {
    return loadingTime.year != 0;
  }

  Future<void> updateElectricity() async {
    List <TrendElectricity> trendElectricityData = await getAllTrendData();
    electricity.data.storeElectricityPrice(trendElectricityData);
    electricity.poke();
  }

  Future <String> _trendDirectoryPath() async {
    var directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  Future <void> init() async {
    if (connectedDevices.isEmpty) {
      log.error('ElectricityPrice connectedDevices is missing Porssisahko');
    }
    else {
      String estateId = connectedDevices[0].myEstateId;
      Porssisahko stockElectricity = (connectedDevices[0] as Porssisahko);
      Map<String, dynamic> parameters = {internetPageKey : stockElectricity.internetPage,
        boxPathKey : await _trendDirectoryPath()};

      parameters[estateIdKey] = estateId;
      parameters[electricityTariffKey] = electricity.data.tariff.toJson();
      parameters[distributionTariffKey] = electricity.data.distributionPrice.toJson();

      await foregroundInterface.defineDailyRecurringService(
          electricityPriceForegroundService,
          TimeOfDay(hour: stockElectricity.fetchingStartHour, minute: stockElectricity.fetchingStartMinutes),
          parameters);

      initOperationModes();

      await updateElectricity();
    }
  }

  void initOperationModes() {

    operationModes.initModeStructure(
        environment: myEstates.estateFromId(connectedDevices[0].myEstateId),
        parameterSettingFunctionName: '',
        deviceId: connectedDevices[0].id,
        deviceAttributes: [],
        setFunction: (){},
        getFunction: (){}
    );
  }


  TrendElectricity _noTrendData() {
    return TrendElectricity(0, noValueDouble);
  }

  Future <List<TrendElectricity>> trendDataSince(DateTime since) async  {
    List<TrendElectricity> fullList = await getAllTrendData();
    int sinceTimestamp = since.millisecondsSinceEpoch;

    for (int i=fullList.length-1; i>0; i--) {
      if (fullList[i].timestamp > sinceTimestamp) {
        return fullList.sublist(i);
      }
    }
    return fullList;
  }

  Future <List<TrendElectricity>> getAllTrendData() async {
    var box = await Hive.openBox<TrendElectricity>(hiveTrendElectricityPriceName,
        path: await _trendDirectoryPath()
    );

    // print('box.length: ${box.length}, path: ${box.path}');

    List<TrendElectricity> list = box.values.toList();

    await box.close();

    return list;
  }

  ElectricityPriceData  getElectricityData ([DateTime? startingTimeParameter])  {

    return electricity.data.getData(startingTimeParameter);

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
          'sähkösopimus: ${electricity.data.tariff.name}',
          'jakelusopimus: ${electricity.data.distributionPrice.name}',
        ],
        widgets: [
          dumpDataMyDevices(formatterWidget: formatterWidget)
        ]
    );
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['electricityTariff'] = electricity.data.tariff.toJson();
    json['distributionTariff'] = electricity.data.distributionPrice.toJson();
    return json;
  }

  @override
  ElectricityPrice.fromJson(Map<String, dynamic> json)  : super.fromJson(json) {
    myView = ElectricityGridBlock();
    myView.setFunctionality(this);
    electricity.data.tariff = ElectricityTariff.fromJson(json['electricityTariff']);
    electricity.data.distributionPrice = ElectricityDistributionPrice.fromJson(json['distributionTariff']);
  }
}

const double notAvailablePrice = 999999.0;


class ElectricityChartData {
  PriceAndTime minPrice = PriceAndTime();
  PriceAndTime min2hourPeriod = PriceAndTime();
  PriceAndTime min3hourPeriod = PriceAndTime();
  PriceAndTime maxPrice = PriceAndTime();

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



