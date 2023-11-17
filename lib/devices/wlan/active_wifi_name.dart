

import 'dart:async';

import 'package:flutter/cupertino.dart';

class ActiveWifiName extends ChangeNotifier{

  var _activeWifiName= '';
  final _controller = StreamController<String>();


  ActiveWifiName() {
    _controller.sink.add('');
  }

  void changeWifiName(String newName) {
    _activeWifiName = newName;
    notifyListeners();
    _controller.sink.add(newName);
  }

  bool iAmActive(String myWifiName) {
    return myWifiName == _activeWifiName;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  String get activeWifiName => _activeWifiName;

  //Stream<String> get stream => _controller.stream;
  Stream<String> get stream => _controller.stream.asBroadcastStream();
}

// todo: should we use this kind of additional class of the following variables
class ActiveWifiBroadcaster {
  ActiveWifiBroadcaster(ActiveWifiName activeWifi) {
    activeWifiName = activeWifi;
    activeWifiNameBroadcastStream = activeWifiName.stream.asBroadcastStream();
  }
  late ActiveWifiName activeWifiName;
  late Stream <String> activeWifiNameBroadcastStream;

  StreamSubscription<String> setListener(Function(String) listeningFunction) {
    return activeWifiNameBroadcastStream.listen(listeningFunction);
  }

  String wifiName() => activeWifiName.activeWifiName;

  void dispose() => activeWifiName.dispose();
}

final activeWifiName = ActiveWifiName();
final ActiveWifiBroadcaster activeWifiBroadcaster = ActiveWifiBroadcaster(activeWifiName);
final activeWifiNameBroadcastStream = activeWifiName.stream.asBroadcastStream();
