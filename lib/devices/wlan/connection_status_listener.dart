import 'dart:async';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'active_wifi_name.dart';
import 'package:koti/look_and_feel.dart';

class ConnectionStatusListener {

  ConnectionStatusListener(ActiveWifiName initWifiName) {
    activeWifiName = initWifiName;
//    activeWifiNameBroadcastStream = initWifiName.stream.asBroadcastStream();
  }
  //This tracks the current connection status
  bool hasWifiConnection = false;

  final Connectivity _connectivity = Connectivity();

  late ActiveWifiName activeWifiName;
//  late Stream activeWifiNameBroadcastStream;

  //The test to actually see if there is a connection
  Future<bool> checkConnection(List <ConnectivityResult> connectivityResult) async {
    String wifiName = '';

    try {

      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        // I am connected to a wifi network.
        hasWifiConnection = true;

        final info = NetworkInfo();
        String resultWithQuotationMarks = await info.getWifiName() ?? '';
        wifiName = resultWithQuotationMarks.replaceAll('"','');

      } else {
        hasWifiConnection = false;
      }

    } catch  (e, st)  {
      log.handle(e, st, 'exception in checkConnection listener');
      hasWifiConnection = false;
      wifiName = '';
    }

    activeWifiName.changeWifiName(wifiName);
    return hasWifiConnection;
  }

  //flutter_connectivity's listener
  void _connectionChange(List<ConnectivityResult> connectivityResult) async {
    await checkConnection(connectivityResult);
  }

  //Hook into connectivity_plus's Stream to listen for changes
  Future<void> initialize() async {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
  }

}