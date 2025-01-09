// Class Services is used by Devices to offer the services they are capable to provide

import '../look_and_feel.dart';

class Services {
  List<DeviceService> _services = [];

  Services(List<DeviceService> initServices) {
    _services = initServices;
  }

  void setServices(List<DeviceService> newServices) {
    _services = newServices;
  }

  bool offerService(String requestedServiceName) {
    return _services.indexWhere((s) => s.serviceName == requestedServiceName) != -1;
  }

  DeviceService getService(String serviceName) {
    return _services.firstWhere((s) => s.serviceName == serviceName);
  }

  Services clone() {
    List<DeviceService> newServiceList = [];
    for (var s in _services) {
      newServiceList.add(s);
    }
    return Services(newServiceList);
  }

}

abstract class DeviceService {
  String serviceName = '';
}

class AttributeDeviceService extends DeviceService {
  AttributeDeviceService({required String attributeName}) {
    serviceName = attributeName;
  }
}

class DeviceServiceClass<T> extends DeviceService {
  late T services;

  DeviceServiceClass({required String serviceName, required T services}) {
    this.serviceName = serviceName;
    this.services = services;
  }
}

class RWAsyncDeviceServiceOldie<T> extends DeviceService {

  late Future<void> Function(T, String caller) _set;
  late Future<T> Function() _get;
  late T Function() _peek;

  RWAsyncDeviceService({required String serviceName,
                        required Future<void> Function (T, String) setFunction,
                        required Future<T> Function() getFunction,
                        required T Function() peekFunction})
  {
    this.serviceName = serviceName;
    _set = setFunction;
    _get = getFunction;
    _peek = peekFunction;
  }

  Future <void> set(T value, {String caller=''}) async {
    await _set(value, caller);
  }

  Future<T> get() async {
    return await _get();
  }

  T peek() {
    return _peek();
  }
}

class RWDeviceService<T> extends DeviceService {

  late void Function(T) _set;
  late T Function() _get;

  RWDeviceService({required String serviceName, required void Function (T) setFunction, required T Function() getFunction})
  {
    this.serviceName = serviceName;
    _set = setFunction;
    _get = getFunction;
  }

  void set(T value) {
    _set(value);
  }

  T get() {
    return _get();
  }
}

class RODeviceService<T> extends DeviceService {

  late T Function() _get;
  late T Function() _notWorkingValue;

  RODeviceService({required String serviceName,
    required T Function() getFunction,
    required T Function() notWorkingValue})
  {
    this.serviceName = serviceName;
    _get = getFunction;
  }

  T notWorkingValue() {
    return _notWorkingValue();
  }

  T get()  {
    return  _get();
  }
}


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