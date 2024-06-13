/*
class ServiceCaller {
  final services = <String, Function>{};

  void registerService(String serviceName, Function serviceFunction) {
    services[serviceName] = serviceFunction;
  }

  Future <void> callAllServices() async {
    services.forEach((key, value) async {
      await value();
    });
  }

}

class ServiceCallerRegisterInConstructor {
  ServiceCallerRegisterInConstructor( ServiceCaller serviceCaller, String serviceName, Function serviceFunction) {
    serviceCaller.registerService(serviceName, serviceFunction);
  }
}

ServiceCaller s = ServiceCaller();
ServiceCallerRegisterInConstructor _u = ServiceCallerRegisterInConstructor(s, 'serviceName', (){});

*/