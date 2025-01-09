// general device services

const String deviceWithManualCreation = 'Device with manual creation';
const String powerOnOffService = 'powerOnOffService';
const String powerOnOffWaitingService = 'powerOnOffWaitingService';
const String outsideTemperatureDeviceService = 'outsideTemperature';
const String airHeatPumpService = 'airHeatPumpService';
const String waterTemperatureService = 'waterTemperatureService';

// general services introduced to estate specific stateBroker
const String powerOnOffStatusService = 'powerOnOffStatusService';
const String outsideTemperatureService = 'Ulkolämpötila';
const String currentRadiatorWaterTemperatureService = 'Patteriveden lämpötila';
const String requestedRadiatorWaterTemperatureService = 'Haluttu patteriveden lämpötila';
const String radiatorValvePositionService = 'Patteriventtiilin asento';
const String thermostatService = 'thermostatService';

const String currentElectricityPrice = 'Sähkön hinta';

const Map<String, String> initServiceDescription = {
  outsideTemperatureService: 'Ulkolämpötila on asunnon ulkolämpötila celsiuksina',
  currentRadiatorWaterTemperatureService: 'Patterikierron veden lämpötila celsiuksina',
  requestedRadiatorWaterTemperatureService: 'fff',
  radiatorValvePositionService: 'Määrittelee, miten paljon venttiili on auki',
  currentElectricityPrice: 'Sähkönhinta mukaanlukien verot ja siirto'
};

class ServiceCatalog {
  Map<String, String> serviceDescriptions = initServiceDescription;

  void addServices(Map<String, String> newServices) {
    serviceDescriptions.addAll(newServices);
  }

  String description(String serviceName) {
    return serviceDescriptions[serviceName] ?? '';
  }
}