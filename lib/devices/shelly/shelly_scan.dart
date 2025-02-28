
import 'package:bonsoir/bonsoir.dart';
import 'package:koti/devices/wlan/bonsoir_discovery.dart';


const String shellyBonsoirService = '_shelly._tcp';

const Map<String, String> _knownShellyDevices = {
  'shellyplusplugs' : 'ShellyTimerSwitch',
  'shellypro2' : 'ShellyPro2',
  'shellyblugwg3' : 'ShellyBluGw'
};

String findShellyTypeName(String s) {
  String typePrefix = _findTypePrefix(s);
  String knownType = _knownShellyDevices[typePrefix] ?? unknownShelly;
  return knownType;
}

const String unknownShelly = 'ShellyDevice';

String _findTypePrefix(String s) {
  List<String> strings = s.split('-');
  if (strings.isEmpty) {
    return '';
  }
  else {
    return strings[0];
  }
}
/*
class ShellyScanItem {
  String shellyType = '';
  String shellyId = '';

  ShellyScanItem(this.shellyType, this.shellyId);
}

 */
Iterable<BonsoirService> testShellyDiscovery() {
  Iterable<BonsoirService> x = [
    BonsoirService(name:'shellyplusplugs-123456', type: 'type1', port: 1),
    BonsoirService(name:'shellypro2-7123456', type: 'type2', port: 2),
    BonsoirService(name:'shellyNotFound-75123456', type: 'type2', port: 2),
  ];
  return x;
}
class ShellyScan {
  List <List<String>> response = [];
  BonsoirDiscoveryModel bonsoirDiscoveryModel = BonsoirDiscoveryModel();

  bool _testing = false;

  void setTesting(bool newValue) {
    _testing = newValue;
  }

  Future<void> init() async {
    bonsoirDiscoveryModel.init(shellyBonsoirService);
    await bonsoirDiscoveryModel.start();
  }

  List<String> listPossibleServices() {
    Iterable<BonsoirService> currentServices = bonsoirDiscoveryModel.services;

    List<String> serviceNames = [];

    for (var e in currentServices) {
      serviceNames.add(e.name);
    }

    return serviceNames;
  }
  
  ResolvedBonsoirService resolveServiceData(String serviceName) {
    BonsoirService dyn = _getServiceData(serviceName);
    if (dyn.runtimeType != ResolvedBonsoirService) {
      dyn =  ResolvedBonsoirService(name:'#not found#',type: '', host: '', port: 0,  attributes: {});
    }
    return dyn as ResolvedBonsoirService;
  }

  BonsoirService _getServiceData(serviceName) {
    BonsoirService? bs = bonsoirDiscoveryModel.getServiceData(serviceName);
    if (bs == null) {
      return  ResolvedBonsoirService(name:'#not found#',type: '', host: '', port: 0,  attributes: {});
    }
    return bs;
  }

  bool isActive(String name) {
    return true;
  }
}

ShellyScan shellyScan = ShellyScan();



