
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

import '../app_configurator.dart';
import 'package:koti/look_and_feel.dart';

part 'trend.g.dart';

Trend trend = Trend();

class Trend {

  List<BoxInformation> boxes = [];

  Future<void> initBox<T>(String boxName) async {
    int index = boxes.indexWhere((e)=>e.name  == boxName);

    if (index < 0) {
      // create a new box
      boxes.add(BoxInformation(boxName, 'kkk'));
      await Hive.openBox<T>(boxName);
    }
  }

  Future<void> initHive() async {
    await Hive.initFlutter(); // (appDocumentDirectory.path);
  }

  int nbrOfBoxes() {
    return boxes.length;
  }

  Future<void> init() async {
/* already initialized
      await initHive();
      await _registerBoxes();

 */
  }

  TrendBox<T> open<T>(String boxName) {

    int index = boxes.indexWhere((e)=>e.name  == boxName);
    if (index < 0) {
      // create a new box
      log.error('Trend box "$boxName" missing from initialization');
    }

    Box<T> myBox = Hive.box<T>(boxName);
    return TrendBox(index, myBox);
  }

  void delete(String logName) {

  }

}

@HiveType(typeId: 0)
class BoxInformation {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String typeName;
  BoxInformation(this.name, this.typeName);
}

class TrendHelper<T> {

  List <T> getAll(Box<T> myBox) {
    return myBox.values.toList(); // list;
  }

  TrendData asTrendData(T item) {
    return item as TrendData;
  }

  List <T> getBetween(Box<T> myBox, DateTime startingTime, DateTime endingTime) {
    List <T> all = getAll(myBox);
    List <T> list = [];
    int startTimeInMSSinceEpoch = startingTime.millisecondsSinceEpoch;
    int endingTimeInMSSinceEpoch = endingTime.millisecondsSinceEpoch;
    int index = 0;
    // todo: this algorithm is not efficient for this purpose...
    while (index < all.length) {
      if (asTrendData(all[index]).timestamp >= startTimeInMSSinceEpoch) {
        if (asTrendData(all[index]).timestamp <= endingTimeInMSSinceEpoch) {
          list.add(all[index]);
        }
        else {
          return list;
        }
      }
      index++;
    }
    return list;
  }

  List <T> getSublist(Box<T> myBox, int startIndex, int lastIndex) {
    List <T> list = [];
    for (int index = startIndex; index<= lastIndex; index++) {
      T? item = myBox.getAt(index);
      if (item != null) {
        list.add(item);
      }
    }
    return list;
  }

  int boxSize (Box<T> myBox) {
    return myBox.length;
  }

  List <T> getLastItems(Box<T> myBox, int itemCount) {
    return getSublist(myBox, max(0, boxSize(myBox)-itemCount), boxSize(myBox)-1);
  }

}
class TrendBox<T> {
  late int index;
  late Box<T> myBox;
  TrendBox(this.index, this.myBox);

  void add(T item) {
    myBox.add(item);
  }

  List <T> getAll() {
    return myBox.values.toList(); // list;
  }

  TrendData asTrendData(T item) {
    return item as TrendData;
  }

  List <T> getBetween(DateTime startingTime, DateTime endingTime) {
    List <T> all = getAll();
    List <T> list = [];
    int startTimeInMSSinceEpoch = startingTime.millisecondsSinceEpoch;
    int endingTimeInMSSinceEpoch = endingTime.millisecondsSinceEpoch;
    int index = 0;
    // todo: this algorithm is not efficient for this purpose...
    while (index < all.length) {
      if (asTrendData(all[index]).timestamp >= startTimeInMSSinceEpoch) {
        if (asTrendData(all[index]).timestamp <= endingTimeInMSSinceEpoch) {
          list.add(all[index]);
        }
        else {
          return list;
        }
      }
      index++;
    }
    return list;
  }

  List <T> getSublist(int startIndex, int lastIndex) {
    List <T> list = [];
    for (int index = startIndex; index<= lastIndex; index++) {
      T? item = myBox.getAt(index);
      if (item != null) {
        list.add(item);
      }
    }
    return list;
  }

  int boxSize () {
    return myBox.length;
  }

  List <T> getLastItems(int itemCount) {
    return getSublist(max(0, boxSize()-itemCount), boxSize()-1);
  }

  Future<void> clearForTesting() async {
    await myBox.clear();
  }
}

@HiveType(typeId: hiveTypeTrendData)
class TrendData {
  @HiveField(0)
  int timestamp = 0;
  @HiveField(1)
  String environmentId = '';
  @HiveField(2)
  String deviceId = '';

  TrendData(this.timestamp, this.environmentId, this.deviceId);

/*
  TrendData(DateTime dateTime, this.estateId, this.deviceId) {
    timestamp = dateTime.millisecondsSinceEpoch;
  }

 */

  String hiveName() {
    return 'trendData';
  }

  Widget showTitle() {
    return const Text('title not implemented', style: TextStyle(color:Colors.red));
  }
  Widget showInLine() {
    return const Text('not implemented', style: TextStyle(color:Colors.red));
  }
}
