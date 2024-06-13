import'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koti/functionalities/functionality/functionality.dart';

import '../../../look_and_feel.dart';


import '../../estate/estate.dart';
import '../../functionalities/electricity_price/view/edit_electricity_view.dart';
import '../device/device.dart';
import '../network_device/network_device.dart';
import 'json/porssisahko_data.dart';

const String _latestPricesCommand = 'https://api.porssisahko.net/v1/latest-prices.json';

const int _fetchingStartHour = 14;
const int _fetchingStartMinutes = 15;
const int _retryInterval = 15;

class Porssisahko extends NetworkDevice {

  PorssisahkoData data = PorssisahkoData(prices: []);

  late Timer _dailyTimer;
  late Timer _retryTimer;

  Porssisahko();

  @override
  Future<void> init() async {
    internetPage = _latestPricesCommand;
    await _fetchData();
  }

  Future<void> _fetchData() async {
    PorssisahkoData newData = await readParameters();
    if (newData.isEmpty() || newData.startingTime().isAtSameMomentAs(data.startingTime())) {

      _setupRetryTimer();
    }
    else {
      data = newData;
      _setupDailyTimer();
    }
  }

  void _setupDailyTimer() {
    DateTime now = DateTime.now();

    int hours = 0;

    // Calculate the time until the next 14:00
    if ((now.hour > _fetchingStartHour) ||
        ((now.hour == _fetchingStartHour) && (now.minute >= _fetchingStartMinutes))) {
      hours = 24-now.hour + _fetchingStartHour;
    }
    else {
      hours = _fetchingStartHour - now.hour;
    }
    Duration dailyDelay = Duration(
      hours: hours,
      minutes: _fetchingStartMinutes-now.minute,
      seconds: -now.second,
    );

    // Schedule the daily task at given time
    _dailyTimer = Timer(dailyDelay, () async {
      await _fetchData();
    });
  }

  void _setupRetryTimer() {
    // Retry every set interval
    _retryTimer = Timer(Duration(minutes: _retryInterval), () async {
      await _fetchData();
    });
  }

  @override
  Future<void> editWidget(BuildContext context, Estate estate, Functionality functionality, Device device) async {
    await Navigator.push(
        context, MaterialPageRoute(
      builder: (context) {
        return EditElectricityView(
            estate: estate,
            functionality: functionality,
            device: device);
      },
    ));
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  Porssisahko.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }

  Future <PorssisahkoData> readParameters() async {
    try {
      final response = await http.get(Uri.parse(internetPage));
      if (response.statusCode == 200) {
        String responseString = response.body.toString();
        PorssisahkoData prices = PorssisahkoData.fromJson(
            json.decode(responseString));

        return prices;
      }
      log.log('error ${response.statusCode} in Pörssisähkö parameter reading ($internetPage)');
      return PorssisahkoData(prices: []);
    }
    catch (e, st) {
      log.handle(e, st, 'exception in Pörssisähkö parameter reading ($internetPage)');
      return PorssisahkoData(prices: []);
    }
  }
}




