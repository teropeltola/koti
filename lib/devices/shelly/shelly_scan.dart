
import 'package:bonsoir/bonsoir.dart';
import 'package:koti/devices/wlan/bonsoir_discovery.dart';

const String shellyBonsoirService = '_shelly._tcp';

class ShellyScan {
  List <List<String>> response = [];
  BonsoirDiscoveryModel bonsoirDiscoveryModel = BonsoirDiscoveryModel();

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
      dyn = const ResolvedBonsoirService(name:'#not found#',type: '', port: 0, ip: '', attributes: {});
    }
    return dyn as ResolvedBonsoirService;
  }

  BonsoirService _getServiceData(serviceName) {
    BonsoirService? bs = bonsoirDiscoveryModel.getServiceData(serviceName);
    if (bs == null) {
      return const ResolvedBonsoirService(name:'#not found#',type: '', port: 0, ip: '', attributes: {});
    }
    return bs;
  }

  bool isActive(String name) {
    return true;
  }
}

ShellyScan shellyScan = ShellyScan();



