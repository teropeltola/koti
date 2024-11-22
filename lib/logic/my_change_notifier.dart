
import 'dart:async';

import 'package:flutter/cupertino.dart';

abstract class MyChangeNotifier<T> extends ChangeNotifier{

  final _controller = StreamController<T>.broadcast();
  late T _data;

  MyChangeNotifier(T initData) {
    _data = initData;
    _controller.sink.add(_data);
  }

  void poke() {
    notifyListeners();
    _controller.sink.add(_data);
  }
  void changeData(T newData) {
    _data = newData;
    poke();
  }

  StreamSubscription<T> setListener(Function(T) listeningFunction) {
    var broadcastStreamSubscription = _controller.stream.asBroadcastStream().listen(listeningFunction);
    return broadcastStreamSubscription;
  }

  void cancelListening(dynamic key) {
    (key as StreamSubscription<T>).cancel();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  T get data => _data;

  void set data (T newData) => changeData(newData);

  Stream<T> get stream => _controller.stream.asBroadcastStream();
}

abstract class BroadcastDataListener<T> {
  late T _data;
  dynamic _key;
  late MyChangeNotifier<T> _changeNotifier;

  T get data => _data;

  void init(MyChangeNotifier<T> initChangeNotifier) {
   _changeNotifier = initChangeNotifier;
   _data = _changeNotifier.data;
    _key = _changeNotifier.setListener((val)=>_data=val);
  }
  void cancel() {
    _changeNotifier.cancelListening(_key);
  }
}

abstract class BroadcastListener<T> {
  dynamic _key;
  late MyChangeNotifier<T> _changeNotifier;

  T get data => _changeNotifier.data; // link to the original data

  void start(MyChangeNotifier<T> initChangeNotifier, Function(T) listenerFunction) {
    _changeNotifier = initChangeNotifier;
    _key = _changeNotifier.setListener(listenerFunction);
    _changeNotifier.poke();
  }

  void cancel() {
    _changeNotifier.cancelListening(_key);
  }
}
