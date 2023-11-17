
import 'package:bonsoir/bonsoir.dart';
import 'package:koti/devices/wlan/bonsoir_discovery.dart';

const String shellyBonsoirService = '_shelly._tcp';

class ShellyScan {
  List <List<String>> response = [];
  BonsoirDiscoveryModel bonsoirDiscoveryModel = BonsoirDiscoveryModel();

  void init() async {
    bonsoirDiscoveryModel.init(shellyBonsoirService);
    bonsoirDiscoveryModel.start();
  }

  List<String> listPossibleServices() {
    Iterable<BonsoirService> currentServices = bonsoirDiscoveryModel.services;

    List<String> serviceNames = [];

    for (var e in currentServices) {
      serviceNames.add(e.name);
    }

    return serviceNames;
  }
  
  BonsoirService resolveService(String serviceName) {
    BonsoirService? bs = bonsoirDiscoveryModel.getServiceData(serviceName);
    if (bs == null) {
      return const BonsoirService(name:'',type: '', port: 0, attributes: {});
    }
    return bs;
  }

  bool isActive(String name) {
    return true;
  }
}

