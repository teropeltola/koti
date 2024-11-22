import'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koti/functionalities/functionality/functionality.dart';

import '../../../look_and_feel.dart';


import '../../estate/estate.dart';
import '../../functionalities/electricity_price/view/edit_electricity_view.dart';
import '../../logic/my_change_notifier.dart';
import '../../logic/unique_id.dart';
import '../network_device/network_device.dart';
import 'json/porssisahko_data.dart';

const String _latestPricesCommand = 'https://api.porssisahko.net/v1/latest-prices.json';

const int _fetchingStartHour = 14;
const int _fetchingStartMinutes = 15;
const int _retryInterval = 15;

class StockPriceDataNotifier extends MyChangeNotifier<PorssisahkoData> {
  StockPriceDataNotifier(super.initData);
}

class StockPriceListener extends BroadcastListener<PorssisahkoData>{
}



class Porssisahko extends NetworkDevice {

  StockPriceDataNotifier _stock = StockPriceDataNotifier( PorssisahkoData(prices: []));

  DateTime _latestDataFetched = DateTime(0);

  late Timer _dailyTimer;
  late Timer _retryTimer;

  Porssisahko(){
    id = UniqueId('E').get();
  }

  @override
  Future<void> init() async {
    internetPage = _latestPricesCommand;
    await _fetchData();
  }

  Future<void> _fetchData() async {
    PorssisahkoData newData = await readParameters();
    if (newData.isEmpty() || newData.startingTime().isAtSameMomentAs(_stock.data.startingTime())) {

      _setupRetryTimer();
    }
    else {
      _stock.data = newData;
      _latestDataFetched = DateTime.now();
      _setupDailyTimer();
    }
  }

  bool noData() {
    return _latestDataFetched.year == 0;
  }

  DateTime fetchingTime() {
    return _latestDataFetched;
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
  Future<bool> editWidget(BuildContext context, Estate estate) async {
    return await Navigator.push(
        context, MaterialPageRoute(
      builder: (context) {
        return EditElectricityView(
            estate: estate,
            functionality: estate.myDefaultElectricityPrice(),
            device: this);
      },
    ));
  }

  StockPriceDataNotifier myBroadcaster() {
    return _stock;
  }

  PorssisahkoData get data => _stock.data;
  void set data(PorssisahkoData newData) => _stock.changeData(newData);

  void update(PorssisahkoData newStatus) {
    _stock.changeData(newStatus);
  }

  dynamic setListener(Function(PorssisahkoData) listeningFunction) {
    return _stock.setListener(listeningFunction) as dynamic;
  }

  void cancelListening(dynamic key) {
    _stock.cancelListening(key);
  }

  @override
  void dispose() {
    _stock.dispose();
    _dailyTimer.cancel();
    _retryTimer.cancel();
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
      headline: name,
      textLines: [
          'tunnus: $id',
          'tiedon lataus suoritettu: ${noData() ? '-' : dumpTimeString(fetchingTime())}',
          _dailyTimer.isActive ? 'Ajastin aktiivinen' : 'Ajastin pois päältä',
          'verkko-osoite: $internetPage',
        ],
        widgets: [
          dumpDataMyFunctionalities(formatterWidget: formatterWidget),
        ]
    );
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




