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
  Future<bool> checkConnection2(ConnectivityResult connectivityResult) async {
    String wifiName = '';

    try {

      if (connectivityResult == ConnectivityResult.wifi) {
        // I am connected to a wifi network.
        hasWifiConnection = true;

        final info = NetworkInfo();
        wifiName = await info.getWifiName() ?? '';

      } else {
        hasWifiConnection = false;
      }

      /*
      final wifiBSSID = await info.getWifiBSSID(); // 11:22:33:44:55:66
      final wifiIP = await info.getWifiIP(); // 192.168.1.43
      final wifiIPv6 = await info.getWifiIPv6(); // 2001:0db8:85a3:0000:0000:8a2e:0370:7334
      final wifiSubmask = await info.getWifiSubmask(); // 255.255.255.0
      final wifiBroadcast = await info.getWifiBroadcast(); // 192.168.1.255
      final wifiGateway = await info.getWifiGatewayIP(); // 192.168.1.1
*/
    } catch  (e, st)  {
      log.handle(e, st, 'exception in checkConnection listener');
      hasWifiConnection = false;
      wifiName = '';
    }

    activeWifiName.changeWifiName(wifiName);
    return hasWifiConnection;
  }


  //flutter_connectivity's listener
  void _connectionChange(ConnectivityResult connectivityResult) async {
    await checkConnection2(connectivityResult);
  }

  //Hook into connectivity_plus's Stream to listen for changes
  //And check the connection status out of the gate
  Future<void> initialize() async {
    log.info('Initialize connection status listener');
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    // await checkConnection();
  }

}