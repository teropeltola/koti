import 'dart:async';
import 'package:flutter/material.dart';

import '../devices/device/device.dart';
import '../devices/wlan/active_wifi_name.dart';
import '../functionalities/functionality/functionality.dart';
import '../functionalities/functionality/view/functionality_view.dart';
import '../look_and_feel.dart';

class Estate extends ChangeNotifier {
  String name = '';
  String id = '';
  String myWifi = '';
  List <Device> devices = [];
  List <Functionality> features = [];

  List <FunctionalityView> views = [];

  bool iAmActive = false;

  late StreamSubscription<String> _wifiActivitySubscription;
  late ActiveWifiBroadcaster _myWifiBroadcaster;

  void init(String initName, String initId, String initMyWifi, ActiveWifiBroadcaster wifiBroadcaster) {
    name = initName;
    id = initId;
    myWifi = initMyWifi;
    _myWifiBroadcaster = wifiBroadcaster;
    _wifiActivitySubscription = wifiBroadcaster.setListener(listenWifiName);
    iAmActive = isMyWifi(wifiBroadcaster.wifiName());
  }

  bool isMyWifi(String currentWifiName) {
    return  (currentWifiName != '') && (myWifi == currentWifiName);
  }

  void changeWifiName(String newWifiName) {
    myWifi = newWifiName;
    bool oldStatus = iAmActive;

    iAmActive = isMyWifi(_myWifiBroadcaster.wifiName());

    if (oldStatus != iAmActive) {
      notifyListeners();
      //broadcast
    }
  }

  void listenWifiName(String currentWifiName) {
    bool oldStatus = iAmActive;

    iAmActive = isMyWifi(currentWifiName);

    if (oldStatus != iAmActive) {
      log.info('$name: ${iAmActive ? 'wifi-yhteys päälle' : 'wifi yhteys katkesi'}');
      notifyListeners();
      //broadcast
    }
  }

  void addDevice(Device newDevice) {
    newDevice.myEstate = this;
    devices.add(newDevice);
  }

  bool deviceExists(String deviceId) {
    for (int i=0; i<devices.length; i++) {
      if (devices[i].id == deviceId) {
        return true;
      }
    }
    return false;
  }

  void addFunctionality(Functionality newFunctionality) {
    features.add(newFunctionality);
  }

  void removeDevice(String deviceId) {
    devices.removeWhere((e) => e.id == deviceId);
  }

  void addView(FunctionalityView newFunctionality) {
    views.add(newFunctionality);
  }

  void setViews() {
    views.clear();
    // views.add()
  }

  @override
  void dispose() {
    super.dispose();
    _wifiActivitySubscription.cancel();
  }
}

Estate noEstates = Estate();

class Estates {
  List <Estate> estates = [];
  List <Estate> currentStack = [Estate()];

  Estate currentEstate () => (nbrOfEstates() > 0)
                                ? currentStack.last
                                : noEstates;

  int nbrOfEstates() => estates.length;

  void addEstate(Estate newLocation) {
    estates.add(newLocation);
  }

  void removeEstate(String estateId) {
    int index = estates.indexWhere((e) => e.id == estateId);
    if (index >= 0) {
      estates[index].dispose();
      estates.removeWhere((e) => e.id == estateId);
    }

    currentStack.removeWhere((e) => e.id == estateId);
  }

  void pushCurrent(Estate newCurrent) {
    currentStack.add(newCurrent);
  }

  void popCurrent() {
    if (currentStack.length > 1) {
      currentStack.removeLast();
    }
  }

  bool validEstateName(String newName) {
    return (newName.isNotEmpty);
  }

  bool estateNameExists(String newName) {
   for (int i=0; i<estates.length; i++) {
      if (newName == estates[i].name) {
        return true;
      }
    }
    return false;
  }

  bool validWifiName(String newName) {
    return (newName.isNotEmpty);
  }

  bool wifiNameExists(String newName) {
    for (int i=0; i<estates.length; i++) {
      if (newName == estates[i].myWifi) {
        return true;
      }
    }
    return false;
  }
}

