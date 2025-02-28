
import 'dart:async';
import 'package:koti/logic/my_change_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/my_device_info.dart';

import 'package:koti/functionalities/functionality/functionality.dart';

class BoolNotifier extends MyChangeNotifier<bool> {
  BoolNotifier(super.initData);
}

class TestFunc extends Functionality {
  late Timer _timer;
  final BoolNotifier _broadcastBool = BoolNotifier(false);

  TestFunc();

  BoolNotifier myBroadcaster() {
    return _broadcastBool;
  }

  bool get data => _broadcastBool.data;
  set data(bool newData) => _broadcastBool.changeData(newData);

  void update(bool newStatus) {
    _broadcastBool.changeData(newStatus);
  }

  dynamic setListener(Function(bool) listeningFunction) {
    return _broadcastBool.setListener(listeningFunction) as dynamic;
  }

  void cancelListening(dynamic key) {
    _broadcastBool.cancelListening(key);
  }

  void dispose() => _broadcastBool.dispose();

}
class Listener extends BroadcastDataListener<bool>{
}

class Listener2 extends BroadcastListener<bool>{
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  group('broadcaster service', () {
    test('Simple test', () async {
      TestFunc t = TestFunc();
      Listener l1 = Listener();
      l1.init(t.myBroadcaster());
      Listener l2 = Listener();
      l2.init(t.myBroadcaster());
      Listener l3 = Listener();
      l3.init(t.myBroadcaster());
      Listener2 l4 = Listener2();
      int l4counter = 0;
      bool l4bool = false;
      l4.start(t.myBroadcaster(),(val){
        l4counter++;
        l4bool = val;
      });
      expect(t.data, false);
      expect(l1.data, false);
      expect(l4counter, 0);
      expect(l4bool, false);
      await Future.delayed(const Duration(milliseconds: 5));
      expect(l4counter, 1);
      expect(l4bool, false);
      t.update(true);
      expect(t.data, true);
      expect(l1.data, false);
      expect(l4counter, 1);
      expect(l4bool, false);
      await Future.delayed(const Duration(seconds: 2));
      expect(l1.data, true);
      expect(l2.data, true);
      expect(l3.data, true);
      expect(l4counter, 2);
      expect(l4bool, true);
      t.data = false;
      await Future.delayed(const Duration(seconds: 2));
      expect(l1.data, false);
      expect(l2.data, false);
      expect(l3.data, false);
      expect(l4counter, 3);
      expect(l4bool, false);
      l2.cancel();
      t.data = true;
      await Future.delayed(const Duration(seconds: 2));
      expect(l1.data, true);
      expect(l2.data, false);
      expect(l3.data, true);
      expect(l4counter, 4);
      expect(l4bool, true);


    });
  });
}