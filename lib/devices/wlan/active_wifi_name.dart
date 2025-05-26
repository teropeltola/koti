import 'dart:async';
import 'package:flutter/material.dart';

import '../../look_and_feel.dart';

class ActiveWifiName extends ChangeNotifier{

  var _nameString = '';
  final _controller = StreamController<String>();

  late final Stream<String> broadcastStream;

  ActiveWifiName() {
    broadcastStream = _controller.stream.asBroadcastStream();
    _controller.sink.add('');
  }

  void changeWifiName(String newName) {
    log.debug('changeWifiName "$_nameString" -> "$newName"');
    _nameString = newName;
    if (newName.isEmpty) {
      log.info('Ei wifi-yhteyttä');
    }
    else {
      log.info('Aktiivinen wifi: "$_nameString"');
    }
    notifyListeners();
    _controller.sink.add(newName);
  }

  bool iAmActive(String myWifiName) {
    return myWifiName == _nameString;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  String get name => _nameString;

}

// todo: should we use this kind of additional class of the following variables
/*
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

  String wifiName() => activeWifiName.name;

  void dispose() => activeWifiName.dispose();
}


 */
final activeWifi = ActiveWifiName();
/*
final ActiveWifiBroadcaster activeWifiBroadcaster = ActiveWifiBroadcaster(activeWifi);
*/