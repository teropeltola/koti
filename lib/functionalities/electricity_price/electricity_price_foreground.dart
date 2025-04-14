// !!! note: this is foreground function and global objects or variables can't
// be used !!!

import 'dart:convert';
import 'dart:core';

import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:koti/functionalities/electricity_price/trend_electricity.dart';

import '../../app_configurator.dart';
import '../../devices/porssisahko/json/porssisahko_data.dart';
import '../../foreground_configurator.dart';
import '../../logic/task_handler_controller.dart';
import '../../look_and_feel.dart';

class ElectricityPriceForeground {
  String internetPage = '';
  String directoryPath = '';

  ElectricityPriceForeground({
    required this.internetPage,
    required this.directoryPath,
  });

  factory ElectricityPriceForeground.fromJson(Map<String, dynamic> json) =>
      ElectricityPriceForeground(
        internetPage: json[internetPageKey] ?? '',
        directoryPath: json[boxPathKey] ?? '',
      );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json[internetPageKey] = internetPage;
    json[boxPathKey] = directoryPath;
    return json;
  }

  Map <String, String> requestResult = {};

  //ForegroundTrendEventBox event = ForegroundTrendEventBox();

  late Box<TrendElectricity> electricityBox;

  void _logError(String errorText) {
    print(errorText);
  }

  Future<void> init() async {
    //await initHiveForForeground();
    //await event.init();

    await Hive.openBox<TrendElectricity>(hiveTrendElectricityPriceName, path: directoryPath);
    electricityBox = Hive.box<TrendElectricity>(hiveTrendElectricityPriceName);
    if (electricityBox.isEmpty) {
      print('ElectricityPriceForeground empty box');
      electricityBox.add(TrendElectricity( 0,  noValueDouble));
    }
  }

  Future<bool> fetchDataFromNetwork() async {
    try {
      final response = await http.get(Uri.parse(internetPage));
      print('ElectricityPriceForeground fetch response.statusCode ${response.statusCode}');
      if (response.statusCode == 200) {
        String responseString = response.body.toString();
        PorssisahkoData prices = PorssisahkoData.fromJson(
            json.decode(responseString));

        List<TrendElectricity> trendElectricity = prices.convert();
        storePrices(trendElectricity);
        priceCollection.updateEstateData("",trendElectricity);
        // TODO: estateID is not real

        return true;
      }
      print('ElectricityPriceForeground error ${response
          .statusCode} in Pörssisähkö parameter reading ($internetPage)');
      return false;
    }
    catch (e, st) {
      print('ElectricityPriceForeground exception ($e) in Pörssisähkö parameter reading ($internetPage)');
      return false;
    }
  }

  void storePrices(List<TrendElectricity> prices) {
    print('storePrices called: ${prices.length}');
    if (prices.isNotEmpty) {
      int lastTrendIndex = electricityBox.length - 1;
      int latestTrendTimestamp = electricityBox.getAt(lastTrendIndex)!
          .timestamp;
      int newPricesIndex = 0;

      while (newPricesIndex < prices.length) {
        if (prices[newPricesIndex].timestamp >= latestTrendTimestamp) {
          break;
        }
        newPricesIndex++;
      }
      if (newPricesIndex == prices.length) {
        // new stored timeslots are already in the trend file
        return;
      }
      if (prices[newPricesIndex].timestamp == latestTrendTimestamp) {
        //update the last trend item to the new value
        electricityBox.putAt(lastTrendIndex, prices[newPricesIndex]);
        newPricesIndex++;
      }
      for (int index = newPricesIndex; index < prices.length; index++) {
        electricityBox.add(prices[index]);
      }
    }
    print('storePrices finished with ${electricityBox.length} items');
  }

  void close() {
    electricityBox.close();
  }
}

Future<bool> electricityPriceInitFunction(Map<String, dynamic> inputData) async {

  priceCollection.createPriceAgent(inputData[estateIdKey], inputData[electricityTariffKey], inputData[distributionTariffKey]);
  return await electricityPriceExecutionFunction(inputData);
}

Future<bool> electricityPriceExecutionFunction(Map<String, dynamic> inputData) async {
  ElectricityPriceForeground electricityPriceForeground = ElectricityPriceForeground.fromJson(inputData);
  await electricityPriceForeground.init();
  bool status = await electricityPriceForeground.fetchDataFromNetwork();
  electricityPriceForeground.close();
  return status;
}

