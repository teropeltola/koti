import 'package:connectivity_plus/connectivity_plus.dart';

import 'dart:async';

import '../devices/device/device_state.dart';
import '../logic/my_change_notifier.dart'; // For StreamSubscription

late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;
MyChangeNotifier<StateModel> ipNetworkState = StateNotifier(StateModel.notInstalled);

Future <void> initNetworkConnectivityInfo() async {
  final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult.contains(ConnectivityResult.mobile) || // Mobile connection available.
      connectivityResult.contains(ConnectivityResult.wifi) ||  // Wi-fi is available.
        // Note for Android: When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
      connectivityResult.contains(ConnectivityResult.ethernet) ||  // Ethernet connection available.
      connectivityResult.contains(ConnectivityResult.vpn) || // Vpn connection active.
        // Note for iOS and macOS: There is no separate network interface type for [vpn].
        // It returns [other] on any device (also simulator)
      connectivityResult.contains(ConnectivityResult.other)) {
    ipNetworkState.data = StateModel.connected;
  }
  else {
    ipNetworkState.data = StateModel.notConnected;
  }
  // initialize updates
  _initNetworkConnectivityUpdates();
}

void _initNetworkConnectivityUpdates() {
  // This is called during the main is created.

  connectivitySubscription =
      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
        // This is the callback function that will be executed whenever the
        // network connectivity status of the device changes.
        // 'results' is a List of ConnectivityResult, representing all active
        // network interfaces.

        for (var result in results) {
          if (result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi ||
              result == ConnectivityResult.ethernet ||
              result == ConnectivityResult.vpn) {

            if (ipNetworkState.data != StateModel.connected) {
              ipNetworkState.data = StateModel.connected;
            }
            break; // Found an IP connection, so we can stop checking
          }
        }
        if (ipNetworkState.data == StateModel.notConnected) {
          ipNetworkState.data = StateModel.notConnected;
        }
      });
}

@override
void disposeNetworkConnectivity() {
  // This dispose() method is called when the StatefulWidget is removed from the widget tree.
  // It's crucial to clean up any resources that were created in initState() or
  // during the widget's lifecycle to prevent memory leaks.

  connectivitySubscription?.cancel(); // This line cancels the stream subscription.
  ipNetworkState.dispose();
}