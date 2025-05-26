import'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koti/devices/device/device_state.dart';

import '../../../look_and_feel.dart';

import '../../estate/estate.dart';
import '../../functionalities/electricity_price/view/edit_electricity_view.dart';
import '../../logic/my_change_notifier.dart';
import '../../logic/unique_id.dart';
import '../network_device/network_device.dart';
import 'json/porssisahko_data.dart';

const String _latestPricesCommand = 'https://api.porssisahko.net/v1/latest-prices.json';


class Porssisahko extends NetworkDevice {

  final int fetchingStartHour = 14;
  final int fetchingStartMinutes = 5;
  final int fetchingIntervalInMinutes = 15;

  Porssisahko() {
    id = UniqueId('E').get();
  }

  @override
  Future<void> init() async {
    internetPage = _latestPricesCommand;
    state.defineDependency(stateDependantOnIP, name);
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


  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: name,
        textLines: [
          'tunnus: $id',
          'tila: ${state.stateText()}',
          'verkko-osoite: $internetPage',
          'hakuaika: ${fetchingStartHour.toString().padLeft(2, '0')}:${fetchingStartMinutes.toString().padLeft(2, '0')}',
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
/*
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

 */
}




