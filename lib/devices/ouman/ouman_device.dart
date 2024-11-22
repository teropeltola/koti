import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:koti/devices/ouman/view/edit_ouman_view.dart';
import 'package:koti/service_catalog.dart';

import 'dart:convert' show utf8;

import '../../estate/estate.dart';
import '../../logic/observation.dart';
import '../../logic/services.dart';
import '../../logic/state_broker.dart';
import '../../logic/unique_id.dart';
import '../../look_and_feel.dart';
import '../device_with_login/device_with_login.dart';

const String _oumanName = 'Ouman';

const _oumanFetchingIntervalInMinutes = 2;

const Map <String, String> oumanCodes = {
  'OutsideTemperature': 'S_227_85',
  'L1MeasuredWaterTemperature': 'S_259_85',
  'L1RequestedWaterTemperature': 'S_275_85',
  'L1Valve': 'S_272_85',
  'TrendSampleInterval' : 'S_26_85',
  'L1TempDrop' : 'S_89_85',
  'L1BigTempDrop' : 'S_90_85',
  'L1minTemperature' : 'S_54_85',
  'L1maxTemperature' : 'S_55_85',
  'L1Curve-20' :   'S_61_85',
  'L1Curve0' :   'S_63_85',
  'L1Curve+20' :   'S_65_85',

};

class OumanDevice extends DeviceWithLogin {

  String _ipAddress = '';

  String get ipAddress => _ipAddress;
  set ipAddress(String newIp) { _ipAddress = newIp; webLoginCredentials.url = _oumanUrl(); }

  String _oumanUrl() {
    return 'http://$ipAddress';
  }

  late Timer _timer;

  Map <String, String> requestResult = {};

  StateDoubleNotifier _outsideTemperature = StateDoubleNotifier(noValueDouble);
  StateDoubleNotifier _measuredWaterTemperature = StateDoubleNotifier(noValueDouble);
  StateDoubleNotifier _requestedWaterTemperature = StateDoubleNotifier(noValueDouble);
  StateDoubleNotifier _valve = StateDoubleNotifier(noValueDouble);
  double _heaterEstimatedTemperature = noValueDouble;
  DateTime _latestDataFetched = DateTime(0);

  void _initOfferedServices() {
    services = Services([
      RODeviceService<double>(
          serviceName: outsideTemperatureDeviceService,
          notWorkingValue: ()=> noValueDouble,
          getFunction: outsideTemperature),
      AttributeDeviceService(attributeName: deviceWithManualCreation)
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

  Future<bool> initSuccessInCreation(Estate estate) async {
    bool success = false;
    try {
      if (estate.myWifiIsActive) {
        success = await login();
        if (success) {
          success = await getData();
          if (success) {
            success = await logout();
          }
        }
      }
    }
    catch (e, st) {
      log.error('OumanDevice init exception', e, st);
      success = false;
    }
    _setupTimer();
    return success;
  }

  @override
  Future<void> init() async {
    Estate myEstate = myEstates.estateFromId(myEstateId);
    await initSuccessInCreation(myEstate);
    webLoginCredentials.url = _oumanUrl();

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

  Future<bool> fetchAndAnalyzeData() async {
    bool success = true;

    if (myEstates.estateFromId(myEstateId).myWifiIsActive) {
      if ((await login()) && (await getData()) && (await logout())) {
        setNormalObservation();
      }
      else {
        observationMonitor.add(ObservationLogItem(DateTime.now(), ObservationLevel.informatic));
        success = false;
      }
    }
    else {
      success = true;
    }
    _setupTimer();
    return success;
  }

  void _setupTimer() {
    const Duration delay =  Duration(
      minutes: _oumanFetchingIntervalInMinutes,
    );

    // Schedule the daily task at given time
    _timer = Timer(delay, () async {
      await init();
    });
  }

  String parameterValue(String paramName) {
    return requestResult[oumanCodes[paramName] ?? ''] ?? '';
  }

  String oumanDataCodes() {
    return 'S_227_85;S_135_85;S_1000_0;S_259_85;S_275_85;S_134_85;S_272_85;S_26_85;S_89_85;S_90_85;S_54_85;S_55_85;S_61_85;S_63_85;S_65_85;S_260_85;S_258_85;S_286_85;S_92_85;S_59_85;S_1004_85;S_330_85;';
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

  double getValue(String key) {
    String result = requestResult[oumanCodes[key] ?? ''] ?? '-99.9';
    return double.parse(result);
  }

  void analyseRequest() {
    _outsideTemperature.data = getValue('OutsideTemperature');
    _measuredWaterTemperature.data = getValue('L1MeasuredWaterTemperature');
    _requestedWaterTemperature.data = getValue('L1RequestedWaterTemperature');
    _valve.data = getValue('L1Valve');
    _heaterEstimatedTemperature = _measuredWaterTemperature.data * 100 / _valve.data;
    _latestDataFetched = DateTime.now();
  }

  bool _useObservations = false;
  double _observationAlarmValveLimit = 99.0;
  double _observationAlarmTempDiff = 0.5;
  double _observationWarningValveLimit = 95.0;
  double _observationWarningTempDiff = 0.0;
  double _observationInfoValveLimit = 90.0;

  double waterTempDiff() => _requestedWaterTemperature.data - _measuredWaterTemperature.data;

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

  Future<bool> login() async {
    String username = await webLoginCredentials.username();
    String password = await webLoginCredentials.password();

    String myLoginRequest = '${webLoginCredentials.url}/login?uid=$username;pwd=$password;';
    try {
      final url = Uri.parse(myLoginRequest); // Replace with your server's URL.
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        log.error('Ouman kirjautuminen epäonnistui. Virhekoodi: ${response
            .statusCode}');
        return false;
      }
    }
    catch(e,st) {
      log.error('OumanDevice login exception: "$myLoginRequest" failed',e,st);
      return false;
    }
  }

  Future<bool> logout() async {
    String myLoginRequest = '${webLoginCredentials.url}/logout?';
    final url = Uri.parse(myLoginRequest);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      log.error('Ouman uloskirjautuminen epäonnistui. Virhekoodi: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> getData() async {
    final htmlResponse = await http.get(Uri.parse('${webLoginCredentials.url}/eh800.html'));
    if (htmlResponse.statusCode != 200) {
      log.error('Ouman datan haku epäonnistui. Virhekoodi: ${htmlResponse.statusCode}');
      return false;
    }
    var mainPage = utf8.decode(htmlResponse.bodyBytes);

    final jsResponse = await http.get(Uri.parse('${webLoginCredentials.url}/eh800.js'));
    if (jsResponse.statusCode != 200) {
      log.error('Ouman javaScriptin haku epäonnistui. Virhekoodi: ${jsResponse.statusCode}');
      return false;
    }

    String request = oumanDataCodes();
    final dataResponse =
      await http.get( Uri.parse( '${webLoginCredentials.url}/request?$request'));
    if (dataResponse.statusCode != 200) {
      log.error('Ouman datan haku epäonnistui. Virhekoodi: ${dataResponse.statusCode}');
      return false;
    }
    String mainPageData = utf8.decode(dataResponse.bodyBytes);
    requestResult = parseDeviceData(mainPageData);
    analyseRequest();

    return true;
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
          _timer.isActive ? 'Ajastin aktiivinen' : 'Ajastin pois päältä',
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
    _timer.cancel();
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

Map<String, String> parseDeviceData(String deviceData) {
  Map<String, String> result = {};

  // Check if the string has the expected format
  if (!deviceData.startsWith('request?')) {
    // Handle invalid format
    log.error('Ouman ParseDeviceData - Invalid data format : "${deviceData.substring(0,min(20,deviceData.length))}"');
    return result;
  }

  // Extract the parameters part of the string
  String paramsString = deviceData.substring('request?'.length);

  // Split the parameters by semicolon
  List<String> params = paramsString.split(';');

  // Iterate over each parameter and extract key-value pairs
  for (String param in params) {
    // Split each parameter by equals sign
    List<String> keyValue = param.trim().split('=');

    // Ensure there are two parts (key and value)
    if (keyValue.length == 2) {
      String key = keyValue[0].trim();
      String value = keyValue[1].trim();
      result[key] = value;
    }
    /*
    else {
      // Handle invalid parameter format
      log.error('Ouman ParseDeviceData - Invalid parameter: $param');
    }

     */
  }

  return result;
}
