
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:koti/devices/mitsu_air-source_heat_pump/view/edit_mitsu_view.dart';

import 'dart:convert' show jsonDecode, utf8;

import '../../estate/estate.dart';
import '../../functionalities/functionality/functionality.dart';
import '../../logic/observation.dart';
import '../../logic/services.dart';
import '../../logic/unique_id.dart';
import '../../service_catalog.dart';
import '../device/device.dart';
import '../../look_and_feel.dart';
import '../device_with_login/device_with_login.dart';
import 'mea_data_json.dart';

const _meaCloudUrl = 'https://app.melcloud.com/Mitsubishi.Wifi.Client';
const _meaId = 'Mitsu';
const _meaLoginUrlExtension = '/Login/ClientLogin';
const _meaGetDevicesUrlExtension = '/User/ListDevices';
const _meaLogoutUrlExtension = '/logout?';

enum LoginResult {notDefined, success, temporaryError, permanentError}

/*
body = {
"Email": email,
"Password": password,
"Language": 0,
"AppVersion": "1.19.1.1",
"Persist": True,
"CaptchaResponse": None,
}

async with _session.post(
f"{BASE_URL}/Login/ClientLogin", json=body, raise_for_status=True
) as resp:
return await resp.json()


 */
const _mitsuFetchingIntervalInMinutes = 3;


const double noValue = -99.9;

class MitsuHeatPumpDevice extends DeviceWithLogin {

  //String urlString = _meaCloudUrl;

  late Timer _timer;

  Map <String, String> requestResult = {};

  String _meaContextKey = '';
  bool _isConnected = false;

  List<MeaData> _meaDataList = [];
  MeaDevice _meaDevice = MeaDevice();

  DateTime _latestDataFetched = DateTime(0);
  int _fetchCounter = 0;



  void _initOfferedServices() {
    services = Services([
      RODeviceService<double>(
          serviceName: outsideTemperatureDeviceService,
          notWorkingValue: ()=> noValue,
          getFunction: outsideTemperature),
      RWDeviceService<bool>(serviceName: powerOnOffService, setFunction: setPower, getFunction: getPower),
      AttributeDeviceService(attributeName: airHeatPumpService),
      AttributeDeviceService(attributeName: deviceWithManualCreation)
    ]);
  }

  MitsuHeatPumpDevice() {
    _setUniqueId();
    webLoginCredentials.url = _meaCloudUrl;
    _initOfferedServices();
  }

  @override
  _setUniqueId() {
    id = UniqueId(_meaId).get();
   }

  @override
  setOk() {
    _setUniqueId();
  }


  MitsuHeatPumpDevice.failed() {
    setFailed();
  }

  bool noData() {
    return _latestDataFetched.year == 0;
  }


  @override
  Future<void> init() async {
    webLoginCredentials.url = _meaCloudUrl;
    await fetchAndAnalyzeData();
  }

  Future<bool> fetchAndAnalyzeData() async {
    LoginResult loginResult = LoginResult.success;

    if (! _isConnected) {
      _fetchCounter = 0;
      loginResult = await login();
      log.info('$name: Internet-yhteys luotu');
    }

    if (loginResult == LoginResult.success) {
      bool success = await getDevices();
      if (success) {
        analyseRequest();
        _fetchCounter ++;
        setNormalObservation();
      }
      else {
        observationMonitor.add(ObservationLogItem(DateTime.now(), ObservationLevel.informatic));
      }
      _setupTimer();
      return success;
    }
    else if (loginResult == LoginResult.temporaryError) {
      _setupTimer();
      return false;
    }
    else {
      // error permanent and thus needs contribution from the user
      observationMonitor.add(ObservationLogItem(DateTime.now(), ObservationLevel.alarm));
      return false;
    }
  }

  void _setupTimer() {
    Duration delay = const Duration(
      minutes: _mitsuFetchingIntervalInMinutes,
    );

    // Schedule the daily task at given time
    _timer = Timer(delay, () async {
      await fetchAndAnalyzeData();
    });
  }

  String parameterValue(String paramName) {
    return requestResult[paramName] ?? '';
  }

  double outsideTemperature() {
    return _meaDevice.outdoorTemperature ?? noValue;
  }

  double measuredTemperature() {
    return _meaDevice.roomTemperature ?? noValue;
  }

  double setTemperature() {
    return _meaDevice.setTemperature ?? noValue;
  }

  int fanSpeed() {
    return _meaDevice.fanSpeed ?? -1;
  }

  DateTime fetchingTime() {
    return _latestDataFetched;
  }

  double getValue(String key) {
    String result = requestResult[key] ?? '-99.9';
    return double.parse(result);
  }

  void analyseRequest() {
    if ((_meaDataList != null) &&
        (_meaDataList.isNotEmpty) &&
        (_meaDataList[0].structure != null) &&
        (_meaDataList[0].structure!.devices != null) &&
        (_meaDataList[0].structure!.devices!.isNotEmpty) &&
        (_meaDataList[0].structure!.devices![0].device != null)){
      _meaDevice = _meaDataList[0].structure!.devices![0].device!;
    }
    else {
      _meaDevice = MeaDevice();
    }
    _latestDataFetched = DateTime.now();
  }

  bool _useObservations = false;
  double _observationAlarmTempDiff = 5.0;
  double _observationWarningTempDiff = 2.5;

  double tempDiff() => setTemperature() - measuredTemperature();

  ObservationLevel observationLevel() {
    if (tempDiff() > _observationAlarmTempDiff) {
      return ObservationLevel.alarm;
    }
    else if (tempDiff() > _observationWarningTempDiff) {
      return ObservationLevel.warning;
    }
    else {
      return ObservationLevel.ok;
    }
  }

  void setNormalObservation() {
    observationMonitor.add(ObservationLogItem(DateTime.now(),observationLevel()));
  }

  Future<LoginResult> login() async {
    _isConnected = false;
    String myLoginRequest = '${webLoginCredentials.url}$_meaLoginUrlExtension';
    final url = Uri.parse(myLoginRequest);  // Replace with your server's URL.
    final response = await http.post(url,
            headers: {
        "Authority": "app.melcloud.com",
        "Accept": "application/json, text/javascript, */*; q=0.01",
        "Accept-Language": "de-DE,de;q=0.9,en-DE;q=0.8,en;q=0.7,en-US;q=0.6,la;q=0.5",
        "Origin": "https://app.melcloud.com/",
        "Referer": "https://app.melcloud.com/",
        "Sec-Fetch-Mode": "cors",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
        "X-Requested-With": "XMLHttpRequest"
            },
            body: {
                "Email": await webLoginCredentials.username(),
                "Password": await webLoginCredentials.password(),
                "Language":"0", // was 17
                "AppVersion":"1.32.1.0",
                "Persist":"true",
                "CaptchaResponse":""
            });

    if (response.statusCode == 200) {
      var responseBodyMap = jsonDecode(response.body);
      var loginData = responseBodyMap['LoginData'];
      if (loginData == null) {
        var errorCode = responseBodyMap["ErrorId"] ?? 0;
        if (errorCode == 1) {
          // incorrect username and/or password
          log.error('melCloud login error: invalid username/password');
          return LoginResult.permanentError;
        } else if (errorCode == 6) {
          // too many failed attempts
          log.error('melCloud login error: too many failed attempts');
          return LoginResult.permanentError;
        }
        return LoginResult.temporaryError;
      }
      else {
        _meaContextKey = loginData['ContextKey'] ?? 0;
        _isConnected = true;
        return LoginResult.success;
      }
    } else {
      log.error('Mitsu kirjautuminen epäonnistui. Virhekoodi: ${response.statusCode}');
      return LoginResult.temporaryError;
    }
  }

  Future<bool> logout() async {
    String myLoginRequest = '${webLoginCredentials.url}$_meaLogoutUrlExtension';
    final url = Uri.parse(myLoginRequest);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      log.error('Mitsu uloskirjautuminen epäonnistui. Virhekoodi: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> getDevices() async {
    String getDevicesUrl = '${webLoginCredentials.url}$_meaGetDevicesUrlExtension';

    final htmlResponse = await http.get(Uri.parse(getDevicesUrl),
        headers: {
          "Host": "app.melcloud.com",
          "X-MitsContextKey": _meaContextKey
        });

    if (htmlResponse.statusCode != 200) {
      log.error('Mitsu getDevices datan haku epäonnistui. Virhekoodi: ${htmlResponse.statusCode}');
      return false;
    }

    var responseData = htmlResponse.body;
    var json = jsonDecode(responseData);
    _meaDataList = List.from(json).map((e)=>MeaData.fromJson(e as Map<String,dynamic>)).toList();
    return true;
  }

  @override
  double temperatureFunction() {
    return outsideTemperature();
  }

  @override
  void dispose() {
    //super.dispose();
    _timer.cancel();
  }

  void setPower(bool value) {
    // TODO: how to switch Mitsu on?
  }

  bool getPower()  {
    //TODO: how to read the value from Mitsu
    return false;
  }


  @override
  Future<bool> editWidget(BuildContext context, Estate estate) async {
    return await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return EditMitsuView(
          estate: estate,
          initMitsu: this,
          callback: () {}
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
          'osoite: ${webLoginCredentials.url}',
        ],
        widgets: [
          dumpDataMyFunctionalities(formatterWidget: formatterWidget),
        ]
    );
  }

  @override
  bool isReusableForFunctionalities() {
    return true;
  }

  @override
  IconData icon() {
    return Icons.heat_pump;
  }

  @override
  String shortTypeName() {
    return 'ilmalämpö-pumppu';
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  MitsuHeatPumpDevice.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    _initOfferedServices();
    webLoginCredentials.url = _meaCloudUrl;
  }

  @override
  MitsuHeatPumpDevice clone() {
    return MitsuHeatPumpDevice.fromJson(toJson());
  }

}

Map<String, String> parseDeviceData(String deviceData) {
  Map<String, String> result = {};

  // Check if the string has the expected format
  if (!deviceData.startsWith('request?')) {
    // Handle invalid format
    log.error('Mitsu ParseDeviceData - Invalid data format : "${deviceData.substring(0,min(20,deviceData.length))}"');
    return result;
  }

  // Extract the parameters part of the string
  String paramsString = deviceData.substring('request?'.length);

  // Split the parameters by semicolon
  List<String> params = paramsString.split(';');

  // Iterate over each parameter and extract key-value pairs
  for (String param in params) {
    // Split each parameter by equals sign
    List<String> keyValue = param.split('=');

    // Ensure there are two parts (key and value)
    if (keyValue.length == 2) {
      String key = keyValue[0].trim();
      String value = keyValue[1].trim();
      result[key] = value;
    } else {
      // Handle invalid parameter format
      log.error('Mitsu ParseDeviceData - Invalid parameter: $param');
    }
  }

  return result;
}
