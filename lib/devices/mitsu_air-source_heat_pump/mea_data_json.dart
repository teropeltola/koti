class MeaData {
  final int? iD;
  final String? name;
  final String? addressLine1;
  final dynamic addressLine2;
  final String? city;
  final String? postcode;
  final double? latitude;
  final double? longitude;
  final dynamic district;
  final bool? fPDefined;
  final bool? fPEnabled;
  final int? fPMinTemperature;
  final int? fPMaxTemperature;
  final bool? hMDefined;
  final bool? hMEnabled;
  final dynamic hMStartDate;
  final dynamic hMEndDate;
  final int? buildingType;
  final int? propertyType;
  final String? dateBuilt;
  final bool? hasGasSupply;
  final String? locationLookupDate;
  final int? country;
  final int? timeZoneContinent;
  final int? timeZoneCity;
  final int? timeZone;
  final int? location;
  final bool? coolingDisabled;
  final bool? linkToMELCloudHome;
  final bool? expanded;
  final MeaStructure? structure;
  final int? accessLevel;
  final bool? directAccess;
  final int? minTemperature;
  final int? maxTemperature;
  final dynamic owner;
  final String? endDate;
  final dynamic iDateBuilt;
  final QuantizedCoordinates? quantizedCoordinates;

  MeaData({
    this.iD,
    this.name,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.postcode,
    this.latitude,
    this.longitude,
    this.district,
    this.fPDefined,
    this.fPEnabled,
    this.fPMinTemperature,
    this.fPMaxTemperature,
    this.hMDefined,
    this.hMEnabled,
    this.hMStartDate,
    this.hMEndDate,
    this.buildingType,
    this.propertyType,
    this.dateBuilt,
    this.hasGasSupply,
    this.locationLookupDate,
    this.country,
    this.timeZoneContinent,
    this.timeZoneCity,
    this.timeZone,
    this.location,
    this.coolingDisabled,
    this.linkToMELCloudHome,
    this.expanded,
    this.structure,
    this.accessLevel,
    this.directAccess,
    this.minTemperature,
    this.maxTemperature,
    this.owner,
    this.endDate,
    this.iDateBuilt,
    this.quantizedCoordinates,
  });

  MeaData.fromJson(Map<String, dynamic> json)
      : iD = json['ID'] as int?,
        name = json['Name'] as String?,
        addressLine1 = json['AddressLine1'] as String?,
        addressLine2 = json['AddressLine2'],
        city = json['City'] as String?,
        postcode = json['Postcode'] as String?,
        latitude = json['Latitude'] as double?,
        longitude = json['Longitude'] as double?,
        district = json['District'],
        fPDefined = json['FPDefined'] as bool?,
        fPEnabled = json['FPEnabled'] as bool?,
        fPMinTemperature = json['FPMinTemperature'] as int?,
        fPMaxTemperature = json['FPMaxTemperature'] as int?,
        hMDefined = json['HMDefined'] as bool?,
        hMEnabled = json['HMEnabled'] as bool?,
        hMStartDate = json['HMStartDate'],
        hMEndDate = json['HMEndDate'],
        buildingType = json['BuildingType'] as int?,
        propertyType = json['PropertyType'] as int?,
        dateBuilt = json['DateBuilt'] as String?,
        hasGasSupply = json['HasGasSupply'] as bool?,
        locationLookupDate = json['LocationLookupDate'] as String?,
        country = json['Country'] as int?,
        timeZoneContinent = json['TimeZoneContinent'] as int?,
        timeZoneCity = json['TimeZoneCity'] as int?,
        timeZone = json['TimeZone'] as int?,
        location = json['Location'] as int?,
        coolingDisabled = json['CoolingDisabled'] as bool?,
        linkToMELCloudHome = json['LinkToMELCloudHome'] as bool?,
        expanded = json['Expanded'] as bool?,
        structure = (json['Structure'] as Map<String,dynamic>?) != null ? MeaStructure.fromJson(json['Structure'] as Map<String,dynamic>) : null,
        accessLevel = json['AccessLevel'] as int?,
        directAccess = json['DirectAccess'] as bool?,
        minTemperature = json['MinTemperature'] as int?,
        maxTemperature = json['MaxTemperature'] as int?,
        owner = json['Owner'],
        endDate = json['EndDate'] as String?,
        iDateBuilt = json['iDateBuilt'],
        quantizedCoordinates = (json['QuantizedCoordinates'] as Map<String,dynamic>?) != null ? QuantizedCoordinates.fromJson(json['QuantizedCoordinates'] as Map<String,dynamic>) : null;

  Map<String, dynamic> toJson() => {
    'ID' : iD,
    'Name' : name,
    'AddressLine1' : addressLine1,
    'AddressLine2' : addressLine2,
    'City' : city,
    'Postcode' : postcode,
    'Latitude' : latitude,
    'Longitude' : longitude,
    'District' : district,
    'FPDefined' : fPDefined,
    'FPEnabled' : fPEnabled,
    'FPMinTemperature' : fPMinTemperature,
    'FPMaxTemperature' : fPMaxTemperature,
    'HMDefined' : hMDefined,
    'HMEnabled' : hMEnabled,
    'HMStartDate' : hMStartDate,
    'HMEndDate' : hMEndDate,
    'BuildingType' : buildingType,
    'PropertyType' : propertyType,
    'DateBuilt' : dateBuilt,
    'HasGasSupply' : hasGasSupply,
    'LocationLookupDate' : locationLookupDate,
    'Country' : country,
    'TimeZoneContinent' : timeZoneContinent,
    'TimeZoneCity' : timeZoneCity,
    'TimeZone' : timeZone,
    'Location' : location,
    'CoolingDisabled' : coolingDisabled,
    'LinkToMELCloudHome' : linkToMELCloudHome,
    'Expanded' : expanded,
    'Structure' : structure?.toJson(),
    'AccessLevel' : accessLevel,
    'DirectAccess' : directAccess,
    'MinTemperature' : minTemperature,
    'MaxTemperature' : maxTemperature,
    'Owner' : owner,
    'EndDate' : endDate,
    'iDateBuilt' : iDateBuilt,
    'QuantizedCoordinates' : quantizedCoordinates?.toJson()
  };
}

class MeaStructure {
  final List<dynamic>? floors;
  final List<dynamic>? areas;
  final List<MeaDevices>? devices;
  final List<dynamic>? clients;

  MeaStructure({
    this.floors,
    this.areas,
    this.devices,
    this.clients,
  });

  MeaStructure.fromJson(Map<String, dynamic> json)
      : floors = json['Floors'] as List?,
        areas = json['Areas'] as List?,
        devices = (json['Devices'] as List?)?.map((dynamic e) => MeaDevices.fromJson(e as Map<String,dynamic>)).toList(),
        clients = json['Clients'] as List?;

  Map<String, dynamic> toJson() => {
    'Floors' : floors,
    'Areas' : areas,
    'Devices' : devices?.map((e) => e.toJson()).toList(),
    'Clients' : clients
  };
}

class MeaDevices {
  final int? deviceID;
  final String? deviceName;
  final int? buildingID;
  final dynamic buildingName;
  final dynamic floorID;
  final dynamic floorName;
  final dynamic areaID;
  final dynamic areaName;
  final int? imageID;
  final String? installationDate;
  final String? lastServiceDate;
  final List<dynamic>? presets;
  final int? ownerID;
  final dynamic ownerName;
  final dynamic ownerEmail;
  final int? accessLevel;
  final bool? directAccess;
  final String? endDate;
  final dynamic zone1Name;
  final dynamic zone2Name;
  final int? minTemperature;
  final int? maxTemperature;
  final bool? hideVaneControls;
  final bool? hideDryModeControl;
  final bool? hideRoomTemperature;
  final bool? hideSupplyTemperature;
  final bool? hideOutdoorTemperature;
  final bool? estimateAtaEnergyProductionOptIn;
  final bool? estimateAtaEnergyProduction;
  final dynamic buildingCountry;
  final dynamic ownerCountry;
  final int? adaptorType;
  final dynamic linkedDevice;
  final int? type;
  final String? macAddress;
  final String? serialNumber;
  final MeaDevice? device;
  final int? diagnosticMode;
  final dynamic diagnosticEndDate;
  final int? location;
  final dynamic detectedCountry;
  final int? registrations;
  final dynamic localIPAddress;
  final int? timeZone;
  final String? registReason;
  final int? expectedCommand;
  final int? registRetry;
  final String? dateCreated;
  final dynamic firmwareDeployment;
  final bool? firmwareUpdateAborted;
  final Permissions? permissions;

  MeaDevices({
    this.deviceID,
    this.deviceName,
    this.buildingID,
    this.buildingName,
    this.floorID,
    this.floorName,
    this.areaID,
    this.areaName,
    this.imageID,
    this.installationDate,
    this.lastServiceDate,
    this.presets,
    this.ownerID,
    this.ownerName,
    this.ownerEmail,
    this.accessLevel,
    this.directAccess,
    this.endDate,
    this.zone1Name,
    this.zone2Name,
    this.minTemperature,
    this.maxTemperature,
    this.hideVaneControls,
    this.hideDryModeControl,
    this.hideRoomTemperature,
    this.hideSupplyTemperature,
    this.hideOutdoorTemperature,
    this.estimateAtaEnergyProductionOptIn,
    this.estimateAtaEnergyProduction,
    this.buildingCountry,
    this.ownerCountry,
    this.adaptorType,
    this.linkedDevice,
    this.type,
    this.macAddress,
    this.serialNumber,
    this.device,
    this.diagnosticMode,
    this.diagnosticEndDate,
    this.location,
    this.detectedCountry,
    this.registrations,
    this.localIPAddress,
    this.timeZone,
    this.registReason,
    this.expectedCommand,
    this.registRetry,
    this.dateCreated,
    this.firmwareDeployment,
    this.firmwareUpdateAborted,
    this.permissions,
  });

  MeaDevices.fromJson(Map<String, dynamic> json)
      : deviceID = json['DeviceID'] as int?,
        deviceName = json['DeviceName'] as String?,
        buildingID = json['BuildingID'] as int?,
        buildingName = json['BuildingName'],
        floorID = json['FloorID'],
        floorName = json['FloorName'],
        areaID = json['AreaID'],
        areaName = json['AreaName'],
        imageID = json['ImageID'] as int?,
        installationDate = json['InstallationDate'] as String?,
        lastServiceDate = json['LastServiceDate'] as String?,
        presets = json['Presets'] as List?,
        ownerID = json['OwnerID'] as int?,
        ownerName = json['OwnerName'],
        ownerEmail = json['OwnerEmail'],
        accessLevel = json['AccessLevel'] as int?,
        directAccess = json['DirectAccess'] as bool?,
        endDate = json['EndDate'] as String?,
        zone1Name = json['Zone1Name'],
        zone2Name = json['Zone2Name'],
        minTemperature = json['MinTemperature'] as int?,
        maxTemperature = json['MaxTemperature'] as int?,
        hideVaneControls = json['HideVaneControls'] as bool?,
        hideDryModeControl = json['HideDryModeControl'] as bool?,
        hideRoomTemperature = json['HideRoomTemperature'] as bool?,
        hideSupplyTemperature = json['HideSupplyTemperature'] as bool?,
        hideOutdoorTemperature = json['HideOutdoorTemperature'] as bool?,
        estimateAtaEnergyProductionOptIn = json['EstimateAtaEnergyProductionOptIn'] as bool?,
        estimateAtaEnergyProduction = json['EstimateAtaEnergyProduction'] as bool?,
        buildingCountry = json['BuildingCountry'],
        ownerCountry = json['OwnerCountry'],
        adaptorType = json['AdaptorType'] as int?,
        linkedDevice = json['LinkedDevice'],
        type = json['Type'] as int?,
        macAddress = json['MacAddress'] as String?,
        serialNumber = json['SerialNumber'] as String?,
        device = (json['Device'] as Map<String,dynamic>?) != null ? MeaDevice.fromJson(json['Device'] as Map<String,dynamic>) : null,
        diagnosticMode = json['DiagnosticMode'] as int?,
        diagnosticEndDate = json['DiagnosticEndDate'],
        location = json['Location'] as int?,
        detectedCountry = json['DetectedCountry'],
        registrations = json['Registrations'] as int?,
        localIPAddress = json['LocalIPAddress'],
        timeZone = json['TimeZone'] as int?,
        registReason = json['RegistReason'] as String?,
        expectedCommand = json['ExpectedCommand'] as int?,
        registRetry = json['RegistRetry'] as int?,
        dateCreated = json['DateCreated'] as String?,
        firmwareDeployment = json['FirmwareDeployment'],
        firmwareUpdateAborted = json['FirmwareUpdateAborted'] as bool?,
        permissions = (json['Permissions'] as Map<String,dynamic>?) != null ? Permissions.fromJson(json['Permissions'] as Map<String,dynamic>) : null;

  Map<String, dynamic> toJson() => {
    'DeviceID' : deviceID,
    'DeviceName' : deviceName,
    'BuildingID' : buildingID,
    'BuildingName' : buildingName,
    'FloorID' : floorID,
    'FloorName' : floorName,
    'AreaID' : areaID,
    'AreaName' : areaName,
    'ImageID' : imageID,
    'InstallationDate' : installationDate,
    'LastServiceDate' : lastServiceDate,
    'Presets' : presets,
    'OwnerID' : ownerID,
    'OwnerName' : ownerName,
    'OwnerEmail' : ownerEmail,
    'AccessLevel' : accessLevel,
    'DirectAccess' : directAccess,
    'EndDate' : endDate,
    'Zone1Name' : zone1Name,
    'Zone2Name' : zone2Name,
    'MinTemperature' : minTemperature,
    'MaxTemperature' : maxTemperature,
    'HideVaneControls' : hideVaneControls,
    'HideDryModeControl' : hideDryModeControl,
    'HideRoomTemperature' : hideRoomTemperature,
    'HideSupplyTemperature' : hideSupplyTemperature,
    'HideOutdoorTemperature' : hideOutdoorTemperature,
    'EstimateAtaEnergyProductionOptIn' : estimateAtaEnergyProductionOptIn,
    'EstimateAtaEnergyProduction' : estimateAtaEnergyProduction,
    'BuildingCountry' : buildingCountry,
    'OwnerCountry' : ownerCountry,
    'AdaptorType' : adaptorType,
    'LinkedDevice' : linkedDevice,
    'Type' : type,
    'MacAddress' : macAddress,
    'SerialNumber' : serialNumber,
    'Device' : device?.toJson(),
    'DiagnosticMode' : diagnosticMode,
    'DiagnosticEndDate' : diagnosticEndDate,
    'Location' : location,
    'DetectedCountry' : detectedCountry,
    'Registrations' : registrations,
    'LocalIPAddress' : localIPAddress,
    'TimeZone' : timeZone,
    'RegistReason' : registReason,
    'ExpectedCommand' : expectedCommand,
    'RegistRetry' : registRetry,
    'DateCreated' : dateCreated,
    'FirmwareDeployment' : firmwareDeployment,
    'FirmwareUpdateAborted' : firmwareUpdateAborted,
    'Permissions' : permissions?.toJson()
  };
}

class MeaDevice {
  final int? pCycleActual;
  final String? errorMessages;
  final int? deviceType;
  final bool? canCool;
  final bool? canHeat;
  final bool? canDry;
  final bool? canAuto;
  final bool? hasAutomaticFanSpeed;
  final bool? airDirectionFunction;
  final bool? swingFunction;
  final int? numberOfFanSpeeds;
  final bool? useTemperatureA;
  final int? temperatureIncrementOverride;
  final double? temperatureIncrement;
  final double? minTempCoolDry;
  final double? maxTempCoolDry;
  final double? minTempHeat;
  final double? maxTempHeat;
  final double? minTempAutomatic;
  final double? maxTempAutomatic;
  final bool? legacyDevice;
  final bool? unitSupportsStandbyMode;
  final bool? isSplitSystem;
  final bool? hasHalfDegreeIncrements;
  final bool? hasOutdoorTemperature;
  final bool? modelIsAirCurtain;
  final bool? modelSupportsFanSpeed;
  final bool? modelSupportsAuto;
  final bool? modelSupportsHeat;
  final bool? modelSupportsDry;
  final bool? modelSupportsVaneVertical;
  final bool? modelSupportsVaneHorizontal;
  final bool? modelSupportsWideVane;
  final bool? modelDisableEnergyReport;
  final bool? modelSupportsStandbyMode;
  final bool? modelSupportsEnergyReporting;
  final bool? prohibitSetTemperature;
  final bool? prohibitOperationMode;
  final bool? prohibitPower;
  final bool? power;
  final double? roomTemperature;
  final double? outdoorTemperature;
  final double? setTemperature;
  final int? actualFanSpeed;
  final int? fanSpeed;
  final bool? automaticFanSpeed;
  final int? vaneVerticalDirection;
  final bool? vaneVerticalSwing;
  final int? vaneHorizontalDirection;
  final bool? vaneHorizontalSwing;
  final int? operationMode;
  final int? effectiveFlags;
  final int? lastEffectiveFlags;
  final bool? inStandbyMode;
  final int? demandPercentage;
  final dynamic configuredDemandPercentage;
  final bool? hasDemandSideControl;
  final double? defaultCoolingSetTemperature;
  final double? defaultHeatingSetTemperature;
  final int? roomTemperatureLabel;
  final int? heatingEnergyConsumedRate1;
  final int? heatingEnergyConsumedRate2;
  final int? coolingEnergyConsumedRate1;
  final int? coolingEnergyConsumedRate2;
  final int? autoEnergyConsumedRate1;
  final int? autoEnergyConsumedRate2;
  final int? dryEnergyConsumedRate1;
  final int? dryEnergyConsumedRate2;
  final int? fanEnergyConsumedRate1;
  final int? fanEnergyConsumedRate2;
  final int? otherEnergyConsumedRate1;
  final int? otherEnergyConsumedRate2;
  final bool? estimateAtaEnergyProduction;
  final bool? estimateAtaEnergyProductionOptIn;
  final dynamic estimateAtaEnergyProductionOptInTimestamp;
  final List<dynamic>? weatherForecast;
  final bool? hasEnergyConsumedMeter;
  final int? currentEnergyConsumed;
  final int? currentEnergyMode;
  final bool? coolingDisabled;
  final int? energyCorrectionModel;
  final bool? energyCorrectionActive;
  final int? minPcycle;
  final int? maxPcycle;
  final int? effectivePCycle;
  final int? maxOutdoorUnits;
  final int? maxIndoorUnits;
  final int? maxTemperatureControlUnits;
  final String? modelCode;
  final int? deviceID;
  final String? macAddress;
  final String? serialNumber;
  final int? timeZoneID;
  final int? diagnosticMode;
  final dynamic diagnosticEndDate;
  final int? expectedCommand;
  final int? owner;
  final dynamic detectedCountry;
  final int? adaptorType;
  final dynamic firmwareDeployment;
  final bool? firmwareUpdateAborted;
  final dynamic linkedDevice;
  final int? wifiSignalStrength;
  final String? wifiAdapterStatus;
  final String? position;
  final int? pCycle;
  final dynamic pCycleConfigured;
  final int? recordNumMax;
  final String? lastTimeStamp;
  final int? errorCode;
  final bool? hasError;
  final String? lastReset;
  final int? flashWrites;
  final dynamic scene;
  final String? sSLExpirationDate;
  final int? sPTimeout;
  final dynamic passcode;
  final bool? serverCommunicationDisabled;
  final int? consecutiveUploadErrors;
  final dynamic doNotRespondAfter;
  final int? ownerRoleAccessLevel;
  final int? ownerCountry;
  final bool? hideEnergyReport;
  final dynamic exceptionHash;
  final dynamic exceptionDate;
  final dynamic exceptionCount;
  final dynamic rate1StartTime;
  final dynamic rate2StartTime;
  final int? protocolVersion;
  final int? unitVersion;
  final int? firmwareAppVersion;
  final int? firmwareWebVersion;
  final int? firmwareWlanVersion;
  final bool? linkToMELCloudHome;
  final String? linkedByUserFromMELCloudHome;
  final int? mqttFlags;
  final bool? hasErrorMessages;
  final bool? hasZone2;
  final bool? offline;
  final bool? supportsHourlyEnergyReport;
  final List<Units>? units;

  MeaDevice({
    this.pCycleActual,
    this.errorMessages,
    this.deviceType,
    this.canCool,
    this.canHeat,
    this.canDry,
    this.canAuto,
    this.hasAutomaticFanSpeed,
    this.airDirectionFunction,
    this.swingFunction,
    this.numberOfFanSpeeds,
    this.useTemperatureA,
    this.temperatureIncrementOverride,
    this.temperatureIncrement,
    this.minTempCoolDry,
    this.maxTempCoolDry,
    this.minTempHeat,
    this.maxTempHeat,
    this.minTempAutomatic,
    this.maxTempAutomatic,
    this.legacyDevice,
    this.unitSupportsStandbyMode,
    this.isSplitSystem,
    this.hasHalfDegreeIncrements,
    this.hasOutdoorTemperature,
    this.modelIsAirCurtain,
    this.modelSupportsFanSpeed,
    this.modelSupportsAuto,
    this.modelSupportsHeat,
    this.modelSupportsDry,
    this.modelSupportsVaneVertical,
    this.modelSupportsVaneHorizontal,
    this.modelSupportsWideVane,
    this.modelDisableEnergyReport,
    this.modelSupportsStandbyMode,
    this.modelSupportsEnergyReporting,
    this.prohibitSetTemperature,
    this.prohibitOperationMode,
    this.prohibitPower,
    this.power,
    this.roomTemperature,
    this.outdoorTemperature,
    this.setTemperature,
    this.actualFanSpeed,
    this.fanSpeed,
    this.automaticFanSpeed,
    this.vaneVerticalDirection,
    this.vaneVerticalSwing,
    this.vaneHorizontalDirection,
    this.vaneHorizontalSwing,
    this.operationMode,
    this.effectiveFlags,
    this.lastEffectiveFlags,
    this.inStandbyMode,
    this.demandPercentage,
    this.configuredDemandPercentage,
    this.hasDemandSideControl,
    this.defaultCoolingSetTemperature,
    this.defaultHeatingSetTemperature,
    this.roomTemperatureLabel,
    this.heatingEnergyConsumedRate1,
    this.heatingEnergyConsumedRate2,
    this.coolingEnergyConsumedRate1,
    this.coolingEnergyConsumedRate2,
    this.autoEnergyConsumedRate1,
    this.autoEnergyConsumedRate2,
    this.dryEnergyConsumedRate1,
    this.dryEnergyConsumedRate2,
    this.fanEnergyConsumedRate1,
    this.fanEnergyConsumedRate2,
    this.otherEnergyConsumedRate1,
    this.otherEnergyConsumedRate2,
    this.estimateAtaEnergyProduction,
    this.estimateAtaEnergyProductionOptIn,
    this.estimateAtaEnergyProductionOptInTimestamp,
    this.weatherForecast,
    this.hasEnergyConsumedMeter,
    this.currentEnergyConsumed,
    this.currentEnergyMode,
    this.coolingDisabled,
    this.energyCorrectionModel,
    this.energyCorrectionActive,
    this.minPcycle,
    this.maxPcycle,
    this.effectivePCycle,
    this.maxOutdoorUnits,
    this.maxIndoorUnits,
    this.maxTemperatureControlUnits,
    this.modelCode,
    this.deviceID,
    this.macAddress,
    this.serialNumber,
    this.timeZoneID,
    this.diagnosticMode,
    this.diagnosticEndDate,
    this.expectedCommand,
    this.owner,
    this.detectedCountry,
    this.adaptorType,
    this.firmwareDeployment,
    this.firmwareUpdateAborted,
    this.linkedDevice,
    this.wifiSignalStrength,
    this.wifiAdapterStatus,
    this.position,
    this.pCycle,
    this.pCycleConfigured,
    this.recordNumMax,
    this.lastTimeStamp,
    this.errorCode,
    this.hasError,
    this.lastReset,
    this.flashWrites,
    this.scene,
    this.sSLExpirationDate,
    this.sPTimeout,
    this.passcode,
    this.serverCommunicationDisabled,
    this.consecutiveUploadErrors,
    this.doNotRespondAfter,
    this.ownerRoleAccessLevel,
    this.ownerCountry,
    this.hideEnergyReport,
    this.exceptionHash,
    this.exceptionDate,
    this.exceptionCount,
    this.rate1StartTime,
    this.rate2StartTime,
    this.protocolVersion,
    this.unitVersion,
    this.firmwareAppVersion,
    this.firmwareWebVersion,
    this.firmwareWlanVersion,
    this.linkToMELCloudHome,
    this.linkedByUserFromMELCloudHome,
    this.mqttFlags,
    this.hasErrorMessages,
    this.hasZone2,
    this.offline,
    this.supportsHourlyEnergyReport,
    this.units,
  });

  MeaDevice.fromJson(Map<String, dynamic> json)
      : pCycleActual = json['PCycleActual'] as int?,
        errorMessages = json['ErrorMessages'] as String?,
        deviceType = json['DeviceType'] as int?,
        canCool = json['CanCool'] as bool?,
        canHeat = json['CanHeat'] as bool?,
        canDry = json['CanDry'] as bool?,
        canAuto = json['CanAuto'] as bool?,
        hasAutomaticFanSpeed = json['HasAutomaticFanSpeed'] as bool?,
        airDirectionFunction = json['AirDirectionFunction'] as bool?,
        swingFunction = json['SwingFunction'] as bool?,
        numberOfFanSpeeds = json['NumberOfFanSpeeds'] as int?,
        useTemperatureA = json['UseTemperatureA'] as bool?,
        temperatureIncrementOverride = json['TemperatureIncrementOverride'] as int?,
        temperatureIncrement = json['TemperatureIncrement'] as double?,
        minTempCoolDry = json['MinTempCoolDry'] as double?,
        maxTempCoolDry = json['MaxTempCoolDry'] as double?,
        minTempHeat = json['MinTempHeat'] as double?,
        maxTempHeat = json['MaxTempHeat'] as double?,
        minTempAutomatic = json['MinTempAutomatic'] as double?,
        maxTempAutomatic = json['MaxTempAutomatic'] as double?,
        legacyDevice = json['LegacyDevice'] as bool?,
        unitSupportsStandbyMode = json['UnitSupportsStandbyMode'] as bool?,
        isSplitSystem = json['IsSplitSystem'] as bool?,
        hasHalfDegreeIncrements = json['HasHalfDegreeIncrements'] as bool?,
        hasOutdoorTemperature = json['HasOutdoorTemperature'] as bool?,
        modelIsAirCurtain = json['ModelIsAirCurtain'] as bool?,
        modelSupportsFanSpeed = json['ModelSupportsFanSpeed'] as bool?,
        modelSupportsAuto = json['ModelSupportsAuto'] as bool?,
        modelSupportsHeat = json['ModelSupportsHeat'] as bool?,
        modelSupportsDry = json['ModelSupportsDry'] as bool?,
        modelSupportsVaneVertical = json['ModelSupportsVaneVertical'] as bool?,
        modelSupportsVaneHorizontal = json['ModelSupportsVaneHorizontal'] as bool?,
        modelSupportsWideVane = json['ModelSupportsWideVane'] as bool?,
        modelDisableEnergyReport = json['ModelDisableEnergyReport'] as bool?,
        modelSupportsStandbyMode = json['ModelSupportsStandbyMode'] as bool?,
        modelSupportsEnergyReporting = json['ModelSupportsEnergyReporting'] as bool?,
        prohibitSetTemperature = json['ProhibitSetTemperature'] as bool?,
        prohibitOperationMode = json['ProhibitOperationMode'] as bool?,
        prohibitPower = json['ProhibitPower'] as bool?,
        power = json['Power'] as bool?,
        roomTemperature = json['RoomTemperature'] as double?,
        outdoorTemperature = json['OutdoorTemperature'] as double?,
        setTemperature = json['SetTemperature'] as double?,
        actualFanSpeed = json['ActualFanSpeed'] as int?,
        fanSpeed = json['FanSpeed'] as int?,
        automaticFanSpeed = json['AutomaticFanSpeed'] as bool?,
        vaneVerticalDirection = json['VaneVerticalDirection'] as int?,
        vaneVerticalSwing = json['VaneVerticalSwing'] as bool?,
        vaneHorizontalDirection = json['VaneHorizontalDirection'] as int?,
        vaneHorizontalSwing = json['VaneHorizontalSwing'] as bool?,
        operationMode = json['OperationMode'] as int?,
        effectiveFlags = json['EffectiveFlags'] as int?,
        lastEffectiveFlags = json['LastEffectiveFlags'] as int?,
        inStandbyMode = json['InStandbyMode'] as bool?,
        demandPercentage = json['DemandPercentage'] as int?,
        configuredDemandPercentage = json['ConfiguredDemandPercentage'],
        hasDemandSideControl = json['HasDemandSideControl'] as bool?,
        defaultCoolingSetTemperature = json['DefaultCoolingSetTemperature'] as double?,
        defaultHeatingSetTemperature = json['DefaultHeatingSetTemperature'] as double?,
        roomTemperatureLabel = json['RoomTemperatureLabel'] as int?,
        heatingEnergyConsumedRate1 = json['HeatingEnergyConsumedRate1'] as int?,
        heatingEnergyConsumedRate2 = json['HeatingEnergyConsumedRate2'] as int?,
        coolingEnergyConsumedRate1 = json['CoolingEnergyConsumedRate1'] as int?,
        coolingEnergyConsumedRate2 = json['CoolingEnergyConsumedRate2'] as int?,
        autoEnergyConsumedRate1 = json['AutoEnergyConsumedRate1'] as int?,
        autoEnergyConsumedRate2 = json['AutoEnergyConsumedRate2'] as int?,
        dryEnergyConsumedRate1 = json['DryEnergyConsumedRate1'] as int?,
        dryEnergyConsumedRate2 = json['DryEnergyConsumedRate2'] as int?,
        fanEnergyConsumedRate1 = json['FanEnergyConsumedRate1'] as int?,
        fanEnergyConsumedRate2 = json['FanEnergyConsumedRate2'] as int?,
        otherEnergyConsumedRate1 = json['OtherEnergyConsumedRate1'] as int?,
        otherEnergyConsumedRate2 = json['OtherEnergyConsumedRate2'] as int?,
        estimateAtaEnergyProduction = json['EstimateAtaEnergyProduction'] as bool?,
        estimateAtaEnergyProductionOptIn = json['EstimateAtaEnergyProductionOptIn'] as bool?,
        estimateAtaEnergyProductionOptInTimestamp = json['EstimateAtaEnergyProductionOptInTimestamp'],
        weatherForecast = json['WeatherForecast'] as List?,
        hasEnergyConsumedMeter = json['HasEnergyConsumedMeter'] as bool?,
        currentEnergyConsumed = json['CurrentEnergyConsumed'] as int?,
        currentEnergyMode = json['CurrentEnergyMode'] as int?,
        coolingDisabled = json['CoolingDisabled'] as bool?,
        energyCorrectionModel = json['EnergyCorrectionModel'] as int?,
        energyCorrectionActive = json['EnergyCorrectionActive'] as bool?,
        minPcycle = json['MinPcycle'] as int?,
        maxPcycle = json['MaxPcycle'] as int?,
        effectivePCycle = json['EffectivePCycle'] as int?,
        maxOutdoorUnits = json['MaxOutdoorUnits'] as int?,
        maxIndoorUnits = json['MaxIndoorUnits'] as int?,
        maxTemperatureControlUnits = json['MaxTemperatureControlUnits'] as int?,
        modelCode = json['ModelCode'] as String?,
        deviceID = json['DeviceID'] as int?,
        macAddress = json['MacAddress'] as String?,
        serialNumber = json['SerialNumber'] as String?,
        timeZoneID = json['TimeZoneID'] as int?,
        diagnosticMode = json['DiagnosticMode'] as int?,
        diagnosticEndDate = json['DiagnosticEndDate'],
        expectedCommand = json['ExpectedCommand'] as int?,
        owner = json['Owner'] as int?,
        detectedCountry = json['DetectedCountry'],
        adaptorType = json['AdaptorType'] as int?,
        firmwareDeployment = json['FirmwareDeployment'],
        firmwareUpdateAborted = json['FirmwareUpdateAborted'] as bool?,
        linkedDevice = json['LinkedDevice'],
        wifiSignalStrength = json['WifiSignalStrength'] as int?,
        wifiAdapterStatus = json['WifiAdapterStatus'] as String?,
        position = json['Position'] as String?,
        pCycle = json['PCycle'] as int?,
        pCycleConfigured = json['PCycleConfigured'],
        recordNumMax = json['RecordNumMax'] as int?,
        lastTimeStamp = json['LastTimeStamp'] as String?,
        errorCode = json['ErrorCode'] as int?,
        hasError = json['HasError'] as bool?,
        lastReset = json['LastReset'] as String?,
        flashWrites = json['FlashWrites'] as int?,
        scene = json['Scene'],
        sSLExpirationDate = json['SSLExpirationDate'] as String?,
        sPTimeout = json['SPTimeout'] as int?,
        passcode = json['Passcode'],
        serverCommunicationDisabled = json['ServerCommunicationDisabled'] as bool?,
        consecutiveUploadErrors = json['ConsecutiveUploadErrors'] as int?,
        doNotRespondAfter = json['DoNotRespondAfter'],
        ownerRoleAccessLevel = json['OwnerRoleAccessLevel'] as int?,
        ownerCountry = json['OwnerCountry'] as int?,
        hideEnergyReport = json['HideEnergyReport'] as bool?,
        exceptionHash = json['ExceptionHash'],
        exceptionDate = json['ExceptionDate'],
        exceptionCount = json['ExceptionCount'],
        rate1StartTime = json['Rate1StartTime'],
        rate2StartTime = json['Rate2StartTime'],
        protocolVersion = json['ProtocolVersion'] as int?,
        unitVersion = json['UnitVersion'] as int?,
        firmwareAppVersion = json['FirmwareAppVersion'] as int?,
        firmwareWebVersion = json['FirmwareWebVersion'] as int?,
        firmwareWlanVersion = json['FirmwareWlanVersion'] as int?,
        linkToMELCloudHome = json['LinkToMELCloudHome'] as bool?,
        linkedByUserFromMELCloudHome = json['LinkedByUserFromMELCloudHome'] as String?,
        mqttFlags = json['MqttFlags'] as int?,
        hasErrorMessages = json['HasErrorMessages'] as bool?,
        hasZone2 = json['HasZone2'] as bool?,
        offline = json['Offline'] as bool?,
        supportsHourlyEnergyReport = json['SupportsHourlyEnergyReport'] as bool?,
        units = (json['Units'] as List?)?.map((dynamic e) => Units.fromJson(e as Map<String,dynamic>)).toList();

  Map<String, dynamic> toJson() => {
    'PCycleActual' : pCycleActual,
    'ErrorMessages' : errorMessages,
    'DeviceType' : deviceType,
    'CanCool' : canCool,
    'CanHeat' : canHeat,
    'CanDry' : canDry,
    'CanAuto' : canAuto,
    'HasAutomaticFanSpeed' : hasAutomaticFanSpeed,
    'AirDirectionFunction' : airDirectionFunction,
    'SwingFunction' : swingFunction,
    'NumberOfFanSpeeds' : numberOfFanSpeeds,
    'UseTemperatureA' : useTemperatureA,
    'TemperatureIncrementOverride' : temperatureIncrementOverride,
    'TemperatureIncrement' : temperatureIncrement,
    'MinTempCoolDry' : minTempCoolDry,
    'MaxTempCoolDry' : maxTempCoolDry,
    'MinTempHeat' : minTempHeat,
    'MaxTempHeat' : maxTempHeat,
    'MinTempAutomatic' : minTempAutomatic,
    'MaxTempAutomatic' : maxTempAutomatic,
    'LegacyDevice' : legacyDevice,
    'UnitSupportsStandbyMode' : unitSupportsStandbyMode,
    'IsSplitSystem' : isSplitSystem,
    'HasHalfDegreeIncrements' : hasHalfDegreeIncrements,
    'HasOutdoorTemperature' : hasOutdoorTemperature,
    'ModelIsAirCurtain' : modelIsAirCurtain,
    'ModelSupportsFanSpeed' : modelSupportsFanSpeed,
    'ModelSupportsAuto' : modelSupportsAuto,
    'ModelSupportsHeat' : modelSupportsHeat,
    'ModelSupportsDry' : modelSupportsDry,
    'ModelSupportsVaneVertical' : modelSupportsVaneVertical,
    'ModelSupportsVaneHorizontal' : modelSupportsVaneHorizontal,
    'ModelSupportsWideVane' : modelSupportsWideVane,
    'ModelDisableEnergyReport' : modelDisableEnergyReport,
    'ModelSupportsStandbyMode' : modelSupportsStandbyMode,
    'ModelSupportsEnergyReporting' : modelSupportsEnergyReporting,
    'ProhibitSetTemperature' : prohibitSetTemperature,
    'ProhibitOperationMode' : prohibitOperationMode,
    'ProhibitPower' : prohibitPower,
    'Power' : power,
    'RoomTemperature' : roomTemperature,
    'OutdoorTemperature' : outdoorTemperature,
    'SetTemperature' : setTemperature,
    'ActualFanSpeed' : actualFanSpeed,
    'FanSpeed' : fanSpeed,
    'AutomaticFanSpeed' : automaticFanSpeed,
    'VaneVerticalDirection' : vaneVerticalDirection,
    'VaneVerticalSwing' : vaneVerticalSwing,
    'VaneHorizontalDirection' : vaneHorizontalDirection,
    'VaneHorizontalSwing' : vaneHorizontalSwing,
    'OperationMode' : operationMode,
    'EffectiveFlags' : effectiveFlags,
    'LastEffectiveFlags' : lastEffectiveFlags,
    'InStandbyMode' : inStandbyMode,
    'DemandPercentage' : demandPercentage,
    'ConfiguredDemandPercentage' : configuredDemandPercentage,
    'HasDemandSideControl' : hasDemandSideControl,
    'DefaultCoolingSetTemperature' : defaultCoolingSetTemperature,
    'DefaultHeatingSetTemperature' : defaultHeatingSetTemperature,
    'RoomTemperatureLabel' : roomTemperatureLabel,
    'HeatingEnergyConsumedRate1' : heatingEnergyConsumedRate1,
    'HeatingEnergyConsumedRate2' : heatingEnergyConsumedRate2,
    'CoolingEnergyConsumedRate1' : coolingEnergyConsumedRate1,
    'CoolingEnergyConsumedRate2' : coolingEnergyConsumedRate2,
    'AutoEnergyConsumedRate1' : autoEnergyConsumedRate1,
    'AutoEnergyConsumedRate2' : autoEnergyConsumedRate2,
    'DryEnergyConsumedRate1' : dryEnergyConsumedRate1,
    'DryEnergyConsumedRate2' : dryEnergyConsumedRate2,
    'FanEnergyConsumedRate1' : fanEnergyConsumedRate1,
    'FanEnergyConsumedRate2' : fanEnergyConsumedRate2,
    'OtherEnergyConsumedRate1' : otherEnergyConsumedRate1,
    'OtherEnergyConsumedRate2' : otherEnergyConsumedRate2,
    'EstimateAtaEnergyProduction' : estimateAtaEnergyProduction,
    'EstimateAtaEnergyProductionOptIn' : estimateAtaEnergyProductionOptIn,
    'EstimateAtaEnergyProductionOptInTimestamp' : estimateAtaEnergyProductionOptInTimestamp,
    'WeatherForecast' : weatherForecast,
    'HasEnergyConsumedMeter' : hasEnergyConsumedMeter,
    'CurrentEnergyConsumed' : currentEnergyConsumed,
    'CurrentEnergyMode' : currentEnergyMode,
    'CoolingDisabled' : coolingDisabled,
    'EnergyCorrectionModel' : energyCorrectionModel,
    'EnergyCorrectionActive' : energyCorrectionActive,
    'MinPcycle' : minPcycle,
    'MaxPcycle' : maxPcycle,
    'EffectivePCycle' : effectivePCycle,
    'MaxOutdoorUnits' : maxOutdoorUnits,
    'MaxIndoorUnits' : maxIndoorUnits,
    'MaxTemperatureControlUnits' : maxTemperatureControlUnits,
    'ModelCode' : modelCode,
    'DeviceID' : deviceID,
    'MacAddress' : macAddress,
    'SerialNumber' : serialNumber,
    'TimeZoneID' : timeZoneID,
    'DiagnosticMode' : diagnosticMode,
    'DiagnosticEndDate' : diagnosticEndDate,
    'ExpectedCommand' : expectedCommand,
    'Owner' : owner,
    'DetectedCountry' : detectedCountry,
    'AdaptorType' : adaptorType,
    'FirmwareDeployment' : firmwareDeployment,
    'FirmwareUpdateAborted' : firmwareUpdateAborted,
    'LinkedDevice' : linkedDevice,
    'WifiSignalStrength' : wifiSignalStrength,
    'WifiAdapterStatus' : wifiAdapterStatus,
    'Position' : position,
    'PCycle' : pCycle,
    'PCycleConfigured' : pCycleConfigured,
    'RecordNumMax' : recordNumMax,
    'LastTimeStamp' : lastTimeStamp,
    'ErrorCode' : errorCode,
    'HasError' : hasError,
    'LastReset' : lastReset,
    'FlashWrites' : flashWrites,
    'Scene' : scene,
    'SSLExpirationDate' : sSLExpirationDate,
    'SPTimeout' : sPTimeout,
    'Passcode' : passcode,
    'ServerCommunicationDisabled' : serverCommunicationDisabled,
    'ConsecutiveUploadErrors' : consecutiveUploadErrors,
    'DoNotRespondAfter' : doNotRespondAfter,
    'OwnerRoleAccessLevel' : ownerRoleAccessLevel,
    'OwnerCountry' : ownerCountry,
    'HideEnergyReport' : hideEnergyReport,
    'ExceptionHash' : exceptionHash,
    'ExceptionDate' : exceptionDate,
    'ExceptionCount' : exceptionCount,
    'Rate1StartTime' : rate1StartTime,
    'Rate2StartTime' : rate2StartTime,
    'ProtocolVersion' : protocolVersion,
    'UnitVersion' : unitVersion,
    'FirmwareAppVersion' : firmwareAppVersion,
    'FirmwareWebVersion' : firmwareWebVersion,
    'FirmwareWlanVersion' : firmwareWlanVersion,
    'LinkToMELCloudHome' : linkToMELCloudHome,
    'LinkedByUserFromMELCloudHome' : linkedByUserFromMELCloudHome,
    'MqttFlags' : mqttFlags,
    'HasErrorMessages' : hasErrorMessages,
    'HasZone2' : hasZone2,
    'Offline' : offline,
    'SupportsHourlyEnergyReport' : supportsHourlyEnergyReport,
    'Units' : units?.map((e) => e.toJson()).toList()
  };
}

class Units {
  final int? iD;
  final int? device;
  final dynamic serialNumber;
  final int? modelNumber;
  final String? model;
  final int? unitType;
  final bool? isIndoor;

  Units({
    this.iD,
    this.device,
    this.serialNumber,
    this.modelNumber,
    this.model,
    this.unitType,
    this.isIndoor,
  });

  Units.fromJson(Map<String, dynamic> json)
      : iD = json['ID'] as int?,
        device = json['Device'] as int?,
        serialNumber = json['SerialNumber'],
        modelNumber = json['ModelNumber'] as int?,
        model = json['Model'] as String?,
        unitType = json['UnitType'] as int?,
        isIndoor = json['IsIndoor'] as bool?;

  Map<String, dynamic> toJson() => {
    'ID' : iD,
    'Device' : device,
    'SerialNumber' : serialNumber,
    'ModelNumber' : modelNumber,
    'Model' : model,
    'UnitType' : unitType,
    'IsIndoor' : isIndoor
  };
}

class Permissions {
  final bool? canSetOperationMode;
  final bool? canSetFanSpeed;
  final bool? canSetVaneDirection;
  final bool? canSetPower;
  final bool? canSetTemperatureIncrementOverride;
  final bool? canDisableLocalController;
  final bool? canSetDemandSideControl;

  Permissions({
    this.canSetOperationMode,
    this.canSetFanSpeed,
    this.canSetVaneDirection,
    this.canSetPower,
    this.canSetTemperatureIncrementOverride,
    this.canDisableLocalController,
    this.canSetDemandSideControl,
  });

  Permissions.fromJson(Map<String, dynamic> json)
      : canSetOperationMode = json['CanSetOperationMode'] as bool?,
        canSetFanSpeed = json['CanSetFanSpeed'] as bool?,
        canSetVaneDirection = json['CanSetVaneDirection'] as bool?,
        canSetPower = json['CanSetPower'] as bool?,
        canSetTemperatureIncrementOverride = json['CanSetTemperatureIncrementOverride'] as bool?,
        canDisableLocalController = json['CanDisableLocalController'] as bool?,
        canSetDemandSideControl = json['CanSetDemandSideControl'] as bool?;

  Map<String, dynamic> toJson() => {
    'CanSetOperationMode' : canSetOperationMode,
    'CanSetFanSpeed' : canSetFanSpeed,
    'CanSetVaneDirection' : canSetVaneDirection,
    'CanSetPower' : canSetPower,
    'CanSetTemperatureIncrementOverride' : canSetTemperatureIncrementOverride,
    'CanDisableLocalController' : canDisableLocalController,
    'CanSetDemandSideControl' : canSetDemandSideControl
  };
}

class QuantizedCoordinates {
  final double? latitude;
  final double? longitude;

  QuantizedCoordinates({
    this.latitude,
    this.longitude,
  });

  QuantizedCoordinates.fromJson(Map<String, dynamic> json)
      : latitude = json['Latitude'] as double?,
        longitude = json['Longitude'] as double?;

  Map<String, dynamic> toJson() => {
    'Latitude' : latitude,
    'Longitude' : longitude
  };
}