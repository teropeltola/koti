import'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../look_and_feel.dart';

const String _latestPricesCommand = 'https://api.porssisahko.net/v1/latest-prices.json';

class PorssisahkoFi {

  late List<Price> prices = [];

  PorssisahkoFi({
    required this.prices,
  });

  PorssisahkoFi.fromJson(Map<String, dynamic> json){
    prices = List.from(json['prices']).map((e)=>Price.fromJson(e)).toList();
    prices.sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['prices'] = prices.map((e)=>e.toJson()).toList();
    return data;
  }

  bool isEmpty() {
    return prices.isEmpty;
  }

  PorssisahkoFi copyWith({
    List<Price>? prices,
  }) =>
      PorssisahkoFi(
        prices: prices ?? this.prices,
      );
}

class Price {
  late double price;
  late DateTime startDate;
  late DateTime endDate;

  Price({
    required this.price,
    required this.startDate,
    required this.endDate,
  });

  Price.fromJson(Map<String, dynamic> json){
    var x = json['price'];
    if (x is double) {
      price = x;
    }
    else if (x is int) {
      price = x.toDouble();
    }

    //startDate = DateTime.parse(json['startDate']).toLocal();
    // todo: clean this
    DateTime t1 = DateTime.parse(json['startDate']);
    var name = t1.timeZoneName;
    var offset = t1.timeZoneOffset.inHours;
    startDate = t1.toLocal();
    var name2 = startDate.timeZoneName;
    var offset2 = startDate.timeZoneOffset.inHours;
    endDate = DateTime.parse(json['endDate']).toLocal();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['price'] = price;
    data['startDate'] = jsonEncode(startDate.toIso8601String());
    data['endDate'] = jsonEncode(endDate.toIso8601String());
    return data;
  }

  Price copyWith({
    double? price,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      Price(
        price: price ?? this.price,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );

}

Future <PorssisahkoFi> readPorssisahkoParameters() async {
  try {
    final response = await http.get(Uri.parse(_latestPricesCommand));
    if (response.statusCode == 200) {
      String responseString = response.body.toString();
      PorssisahkoFi prices = PorssisahkoFi.fromJson(
          json.decode(responseString));

      return prices;
    }
    log.log('error ${response.statusCode} in Pörssisähkö parameter reading');
    return PorssisahkoFi(prices: []);
  }
  catch (e, st) {
    log.handle(e, st, 'exception in Pörssisähkö parameter reading');
    return PorssisahkoFi(prices: []);
  }
}
