import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:async';

import 'package:koti/devices/ouman/trend_ouman.dart';
import 'package:koti/devices/ouman/view/edit_ouman_view.dart';
import 'package:koti/foreground_configurator.dart';
import 'package:koti/interfaces/foreground_interface.dart';
import 'package:koti/service_catalog.dart';

import '../../app_configurator.dart';
import '../../estate/estate.dart';
import '../../logic/observation.dart';
import '../../logic/services.dart';
import '../../logic/state_broker.dart';
import '../../logic/unique_id.dart';
import '../../look_and_feel.dart';
import '../device_with_login/device_with_login.dart';
import 'ouman_foreground.dart';

const String _oumanName = 'Ouman';

const _oumanFetchingIntervalInMinutes = 15;
const _initialWaitingTimeInSeconds = 15;

class OumanDevice extends DeviceWithLogin {

  String _ipAddress = '';

  String get ipAddress => _ipAddress;
  set ipAddress(String newIp) { _ipAddress = newIp; webLoginCredentials.url = _oumanUrl(); }

  String _oumanUrl() {
    return 'http://$ipAddress';
  }

  final StateDoubleNotifier _outsideTemperature = StateDoubleNotifier(noValueDouble);
  final StateDoubleNotifier _measuredWaterTemperature = StateDoubleNotifier(noValueDouble);
  final StateDoubleNotifier _requestedWaterTemperature = StateDoubleNotifier(noValueDouble);
  final StateDoubleNotifier _valve = StateDoubleNotifier(noValueDouble);
  double _heaterEstimatedTemperature = noValueDouble;
  DateTime _latestDataFetched = DateTime(0);

  void _initOfferedServices() {
    services = Services([
      RODeviceService<double>(
          serviceName: outsideTemperatureDeviceService,
          notWorkingValue: ()=> noValueDouble,
          getFunction: outsideTemperature),
      AttributeDeviceService(attributeName: deviceWithManualCreation),
      AttributeDeviceService(attributeName: waterTemperatureService)
    ]);
  }

  OumanDevice() {
    id = UniqueId(_oumanName).get();
    _initOfferedServices();
  }

  OumanDevice.failed() {
    setFailed();
    _initOfferedServices();

  }

  @override
  setOk() {
    id = UniqueId(_oumanName).get();
  }

  bool noData() {
    return _latestDataFetched.year == 0;
  }

  @override
  Future<void> init() async {
    Estate myEstate = myEstates.estateFromId(myEstateId);

    webLoginCredentials.url = _oumanUrl();

    foregroundInterface.defineRecurringService(
      oumanForegroundService,
      _oumanFetchingIntervalInMinutes,
      OumanForeground(
          estateId: myEstateId,
          deviceId: id,
          username: await webLoginCredentials.username(),
          password: await webLoginCredentials.password(),
          url: webLoginCredentials.url,
          wifiName: myEstate.myWifi).toJson(),
    );

    await readData();

    myEstate.stateBroker.initNotifyingDoubleStateInformer(
        device: this,
        serviceName: currentRadiatorWaterTemperatureService,
        stateDoubleNotifier: _measuredWaterTemperature,
        dataReadingFunction: measuredWaterTemperature);

    myEstate.stateBroker.initNotifyingDoubleStateInformer(
        device: this,
        serviceName: outsideTemperatureService,
        stateDoubleNotifier: _outsideTemperature,
        dataReadingFunction: outsideTemperature);

    myEstate.stateBroker.initNotifyingDoubleStateInformer(
        device: this,
        serviceName: radiatorValvePositionService,
        stateDoubleNotifier: _valve,
        dataReadingFunction: valve);

    myEstate.stateBroker.initNotifyingDoubleStateInformer(
        device: this,
        serviceName: requestedRadiatorWaterTemperatureService,
        stateDoubleNotifier: _requestedWaterTemperature,
        dataReadingFunction: requestedWaterTemperature);

  }

  double outsideTemperature() {
    return _outsideTemperature.data;
  }

  double measuredWaterTemperature() {
    return _measuredWaterTemperature.data;
  }

  double requestedWaterTemperature() {
    return _requestedWaterTemperature.data;
  }

  double valve() {
    return _valve.data;
  }

  double heaterEstimatedTemperature() {
    return _heaterEstimatedTemperature;
  }

  DateTime fetchingTime() {
    return _latestDataFetched;
  }


  TrendOuman _noTrendData() {
    return TrendOuman(
        DateTime.now().millisecondsSinceEpoch,
        myEstateId,
        id,
        noValueDouble, noValueDouble, noValueDouble,noValueDouble);
  }

  Future<TrendOuman> latestData() async {
    var box = await Hive.openBox<TrendOuman>(hiveTrendOumanName);

    TrendOuman trendOuman = box.length == 0 ? _noTrendData() : box.getAt(box.length-1) ?? _noTrendData();

    await box.close();

    return trendOuman;
  }

  Future <List<TrendOuman>> getHistoryData() async {
    var box = await Hive.openBox<TrendOuman>(hiveTrendOumanName);

    List<TrendOuman> list = box.values.toList();

    await box.close();

    return list;
  }


  Future<void> readData() async {

    TrendOuman data = await latestData();

    _outsideTemperature.data = data.outsideTemperature;
    _measuredWaterTemperature.data = data.measuredWaterTemperature;
    _requestedWaterTemperature.data = data.requestedWaterTemperature;
    _valve.data = data.valve;
    _heaterEstimatedTemperature = _measuredWaterTemperature.data * 100 / _valve.data;
    _latestDataFetched = DateTime.fromMillisecondsSinceEpoch(data.timestamp);
  }

  final bool _useObservations = false;
  final double _observationAlarmValveLimit = 99.0;
  final double _observationAlarmTempDiff = 0.5;
  final double _observationWarningValveLimit = 95.0;
  final double _observationWarningTempDiff = 0.0;
  final double _observationInfoValveLimit = 90.0;

  double waterTempDiff() => _requestedWaterTemperature.data - _measuredWaterTemperature.data;

  @override
  ObservationLevel observationLevel() {
    if ((_valve.data > _observationAlarmValveLimit) &&
        (waterTempDiff() > _observationAlarmTempDiff)) {
      return ObservationLevel.alarm;
    }
    else if ((_valve.data > _observationWarningValveLimit) &&
        (waterTempDiff() > _observationWarningTempDiff)) {
      return ObservationLevel.warning;
    }
    else if (_valve.data > _observationInfoValveLimit) {
      return ObservationLevel.informatic;
    }
    else {
      return ObservationLevel.ok;
    }
  }

  void setNormalObservation() {
    observationMonitor.add(ObservationLogItem(DateTime.now(),observationLevel()));
  }



  @override
  double temperatureFunction() {
    return outsideTemperature();
  }

  @override
  IconData icon() {
    return Icons.water_drop;
  }

  @override
  String shortTypeName() {
    return 'ouman';
  }


  @override
  Future<bool> editWidget(BuildContext context, Estate estate ) async {
    return await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return EditOumanView(
          estate: estate,
        );
      },
    ));
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: name,
        textLines: [
          'tunnus: $id',
          'datan hakuaika: ${dumpTimeString(fetchingTime())}',
          'IP-osoite: $_ipAddress',
        ],
        widgets: [
          dumpDataMyFunctionalities(formatterWidget: formatterWidget),
        ]
    );
  }
  
  @override
  void dispose() {
    //super.dispose();
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['ipAddress'] = ipAddress;
    return json;
  }

  @override
  OumanDevice.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    _initOfferedServices();
    ipAddress = json['ipAddress'] ?? '';
  }

  @override
  OumanDevice clone() {
    return OumanDevice.fromJson(toJson());
  }
}

