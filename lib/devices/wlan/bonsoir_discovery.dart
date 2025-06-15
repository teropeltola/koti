import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';

import '../../look_and_feel.dart';

/*
/// The model provider.
final discoveryModelProvider = ChangeNotifierProvider<BonsoirDiscoveryModel>((ref) {
  BonsoirDiscoveryModel model = BonsoirDiscoveryModel();
  model.start();
  return model;
});
*/
/// Provider model that allows to handle Bonsoir discoveries.
class BonsoirDiscoveryModel extends ChangeNotifier {
  /// The current Bonsoir discovery object instance.
  BonsoirDiscovery? _bonsoirDiscovery;

  /// Contains all discovered services.
  final Map<String, BonsoirService> _services = {};

  /// Contains all functions that allows to resolve services.
  final Map<String, VoidCallback> _servicesResolver = {};

  /// The subscription object.
  StreamSubscription<BonsoirDiscoveryEvent>? _subscription;

  /// Returns all discovered (and resolved) services.
  Iterable<BonsoirService> get services => _services.values;

  String _myType = '';

  void init(String myType) {
    _myType = myType;
  }

  /// Starts the Bonsoir discovery.
  Future<void> start() async {
    if (_bonsoirDiscovery == null || _bonsoirDiscovery!.isStopped) {
      _bonsoirDiscovery = BonsoirDiscovery(type: _myType, printLogs: true);
      await _bonsoirDiscovery!.ready;
    }

    _subscription = _bonsoirDiscovery!.eventStream!.listen(_onEventOccurred);
    await _bonsoirDiscovery!.start();
  }

  /// Stops the Bonsoir discovery.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _bonsoirDiscovery?.stop();
  }

  /// Returns the service resolver function of the given service.
  VoidCallback? getServiceResolverFunction(BonsoirService service) => _servicesResolver[service.name];

  /// store services while ignoring IPv6 host updates
  bool _storeService(BonsoirService service) {
    if (service is ResolvedBonsoirService) {
      print('--- Resolved Service ---');
      print('Service Name: ${service.name}');
      print('Service Type: ${service.type}');
      print('Service Port: ${service.port}');
      print('Service Host (Primary): ${service.host}');
      print('Service Attributes: ${service.attributes}');
      if (service.host!.contains('wlan')) {
        log.info('bonsoir service storing (${service.name}) ignoring IPv6 host (${service.toJson()})');
        return false;
      }
    }
    _services[service.name] = service;
    log.info('Current bonsoir services: ${_services.toString()}');
    return true;
  }
  /// Triggered when a Bonsoir discovery event occurred.
  void _onEventOccurred(BonsoirDiscoveryEvent event) {

    if (event.service == null) {
      return;
    }

    BonsoirService service = event.service!;
    if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
      _servicesResolver[service.name] = () => _resolveService(service);
      log.info('bonsoir service (${service
          .name}) discoveryServiceFound (${service.toJson()})');
      _resolveService(service);
    } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
      if (_storeService(service)) {
        log.info('bonsoir service (${service
            .name}) discoveryServiceResolved (${service.toJson()})');
        _servicesResolver.remove(service.name);
      }
      else {
        // ignore IPv6 host updates
        //_resolveService(service);
      }
    } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolveFailed) {
      _servicesResolver[service.name] = () => _resolveService(service);
      log.info('bonsoir service (${service.name}) discoveryServiceResolveFailed (${service.toJson()})');
    } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
      log.info('bonsoir service (${service.name}) discoveryServiceLost (${service.toJson()})');
      _services.remove(service.name);
    }
    notifyListeners();
  }

  /// Resolves the given service.
  void _resolveService(BonsoirService service) {
    if (_bonsoirDiscovery != null) {
      service.resolve(_bonsoirDiscovery!.serviceResolver);
    }
  }

  BonsoirService? getServiceData(String serviceName) {

    return _services[serviceName];
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}