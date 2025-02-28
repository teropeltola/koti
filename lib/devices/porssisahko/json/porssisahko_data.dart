
import 'dart:convert';

import 'package:koti/look_and_feel.dart';

import '../../../functionalities/electricity_price/trend_electricity.dart';

class PorssisahkoData {

  late List<Price> prices = [];

  PorssisahkoData({
    required this.prices,
  });

  PorssisahkoData.fromJson(Map<String, dynamic> json){
    prices = List.from(json['prices']).map((e)=>Price.fromJson(e)).toList();
    prices.sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['prices'] = prices.map((e)=>e.toJson()).toList();
    return data;
  }

  // convert the current object to a List<TrendElectricity object
  List<TrendElectricity> convert()
  {
    if (prices.isEmpty) {
      return [TrendElectricity(0, noValueDouble)];
    }
    List<TrendElectricity> result = [];
    int earlierSlotEndingTimestamp = prices[0].startDate.millisecondsSinceEpoch;
    double earlierPrice = 0.0;

    for (Price price in prices) {
      if (earlierSlotEndingTimestamp < price.startDate.millisecondsSinceEpoch) {
        // gap between slots
        result.add(TrendElectricity(
          earlierSlotEndingTimestamp,
          noValueDouble,
        ));
        earlierSlotEndingTimestamp = price.startDate.millisecondsSinceEpoch;
        earlierPrice = noValueDouble;
      }
      if (earlierSlotEndingTimestamp == price.startDate.millisecondsSinceEpoch) {
        if (earlierPrice == price.price) {
          earlierSlotEndingTimestamp = price.endDate.millisecondsSinceEpoch;
        }
        else {
          result.add(TrendElectricity(
            price.startDate.millisecondsSinceEpoch,
            price.price,
          ));
          earlierSlotEndingTimestamp = price.endDate.millisecondsSinceEpoch;
          earlierPrice = price.price;
        }
      } else if (earlierSlotEndingTimestamp > price.startDate.millisecondsSinceEpoch) {
        print('Error in data in PorssisahkoData.convert');
      }
    }
    result.add(TrendElectricity(
      earlierSlotEndingTimestamp,
      noValueDouble,
    ));
    return result;
  }

  bool isEmpty() {
    return prices.isEmpty;
  }

  DateTime startingTime() {
    if (prices.isEmpty) {
      return DateTime(0);
    }
    else {
      return prices[0].startDate;
    }
  }
/*
  PorssisahkoData copyWith({
    List<Price>? prices,
  }) =>
      PorssisahkoData(
        prices: prices ?? this.prices,
      );

 */
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

    startDate = DateTime.parse(json['startDate']).toLocal();
    endDate = DateTime.parse(json['endDate']).toLocal();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['price'] = price;
    data['startDate'] = startDate.toIso8601String();
    data['endDate'] = endDate.toIso8601String();
    return data;
  }
/*
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

 */
}

