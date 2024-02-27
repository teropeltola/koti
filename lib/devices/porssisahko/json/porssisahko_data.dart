
import 'dart:convert';

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

  PorssisahkoData copyWith({
    List<Price>? prices,
  }) =>
      PorssisahkoData(
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

