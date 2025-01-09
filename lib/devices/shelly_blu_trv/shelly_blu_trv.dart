import 'package:flutter/material.dart';
import 'package:koti/devices/shelly_blu_trv/view/edit_shelly_blu_trv_view.dart';
import 'package:koti/logic/observation.dart';
import '../../estate/estate.dart';
import '../../logic/events.dart';
import '../../logic/overload_guard.dart';
import '../../logic/services.dart';
import '../../look_and_feel.dart';
import '../../service_catalog.dart';
import '../device/device.dart';
import '../shelly/json/blu_trv.dart';
import '../shelly_blu_gw/shelly_blu_gw.dart';

const _fetchTimeValidityWindow = 5; // minutes

class ShellyBluTrv extends Device {
  String myGwDeviceId = ''; //device Id of the connected gateway
  int idNumber = -1; // id number used inside the gateway

  late ThermostatControlService thermostatControlService;
  late ShellyBluGw myGw;
  late BluConfigAndStatus myInfo;

  BluTrvRemoteStatus latestStatus = BluTrvRemoteStatus.empty();
  DateTime statusFetched = DateTime(0);

  ShellyBluTrv(String initId, this.myGwDeviceId, this.idNumber) {
    id = initId;
  }

  ShellyBluTrv.empty() {
  }

  void _initOfferedServices() {
    services = Services([
      DeviceServiceClass<ThermostatControlService>(serviceName: thermostatService, services: thermostatControlService)
    ]);
  }

  @override
  Future<void> init() async {
    myGw = allDevices.findDevice(myGwDeviceId) as ShellyBluGw;
    myInfo = await myGw.bluInfo(idNumber);

    thermostatControlService = ThermostatControlService(
        _temperatureFunction, _targetTemperature, _setTargetTemperature,
        _peekTemperature, _batteryLevel, _showMessage, this);

    _initOfferedServices();
  }

  Future<void> updateData() async {
    latestStatus = await myGw.bluTrvGetRemoteStatus(idNumber);
    statusFetched = DateTime.now();
  }

  Future <void> ensureDataValidity() async {
    if (DateTime.now().difference(statusFetched).inMinutes > _fetchTimeValidityWindow) {
      await updateData();
    }
  }

  Future <double> _temperatureFunction() async {
    await ensureDataValidity();
    return (latestStatus.status.trv0.currentC);
  }

  Future <double> _targetTemperature() async {
    await ensureDataValidity();
    return (latestStatus.status.trv0.targetC.toDouble());
  }

  // sets the TRV target temperature

  OverloadGuard<int> _overloadGuard = OverloadGuard(-100, Duration(seconds:10));

  Future <void> _setTargetTemperature(int newTarget, String caller) async {

    if (_overloadGuard.updateIsAllowed(newTarget)) {
      events.write(myEstateId, this.id, ObservationLevel.ok,
          'patterin lämpötilaksi asetettu $newTarget$celsius ($caller)');
      await myGw.bluTrvCall(
          idNumber, 'TRV.SetTarget', '{"id":0,"target_C":$newTarget}');
    }
  }

  Future <void> _showMessage(String message) async {
    // max 10 letter messages allowed
    String shortMessage = message.length > 10 ? message.substring(0,9) : message;
    await myGw.bluTrvCall(idNumber,'TRV.ShowMessage', '{"id":0,"message":"$shortMessage"}');
  }

  int _batteryLevel()  {
    // TODO: myInfo needs to be updated every now and then ... myInfo = myGw.bluInfo(idNumber);
    return (myInfo.status.battery);
  }

  double _peekTemperature() {
    return (latestStatus.status.trv0.currentC);
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: name,
        textLines: [
          'tunnus: $id',
          'Gw Id: $myGwDeviceId',
          'tunnus gw:ssä: $idNumber',
        ],
        widgets: [
          dumpDataMyFunctionalities(formatterWidget: formatterWidget),
        ]
    );
  }

  @override
  IconData icon() {
    return Icons.thermostat;
  }

  @override
  String shortTypeName() {
    return 'shelly blu trv';
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['gwId'] = myGwDeviceId;
    json['idNumber'] = idNumber;
    return json;
  }

  @override
  ShellyBluTrv.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    myGwDeviceId = json['gwId'] ?? '';
    idNumber = json['idNumber'] ?? 0;
  }

  @override
  Future<bool> editWidget(BuildContext context, Estate estate) async {
    return await Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return EditShellyBluTrvView(
              estate: estate,
              shellyBluTrv: this,
              callback: () {}
          );
        }));
  }
}

class ThermostatControlService {

  late final Future <double> Function() _temperature;
  late final Future <double> Function() _targetTemperature;
  late final Future <void> Function(int, String) _setTargetTemperature;
  late final double Function() _peekTemperature;
  late final int Function() _batteryLevel;
  late final Future <void> Function(String) _showMessage;
  late final Device device;

  ThermostatControlService(
      this._temperature, this._targetTemperature, this._setTargetTemperature,
      this._peekTemperature, this._batteryLevel,
      this._showMessage,
      this.device);

  Future <double> temperature() async {
    return await _temperature();
  }

  Future <double> targetTemperature() async {
    return await _targetTemperature();
  }

  Future <void> setTargetTemperature(int newTarget, String caller) async {
    await _setTargetTemperature(newTarget, caller);
  }

  Future <void> showMessage(String message) async {
    await _showMessage(message);
  }

  int batteryLevel() {
    return _batteryLevel();
  }

  double peekTemperature() {
    return _peekTemperature();
  }
}