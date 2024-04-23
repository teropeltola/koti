
import 'dart:async';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;

import 'dart:convert' show jsonDecode, utf8;

import '../../logic/observation.dart';
import '../device/device.dart';
import '../../look_and_feel.dart';
import 'mea_data_json.dart';

const _meaCloudUrl = 'https://';
const _meaCloudUsername = 'tero.peltola@mosahybrid.com';
const _meaCloudPassword = 'G1bs0n###@Vihtis';

const _meaLoginUrl = 'https://app.melcloud.com/Mitsubishi.Wifi.Client/Login/ClientLogin';
var _meaLoginData =
{"Email":"tero.peltola@mosahybrid.com","Password":"G1bs0n###@Vihtis","Language":17,"AppVersion":"1.32.1.0","Persist":false,"CaptchaResponse":null};

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

class MitsuHeatPumpDevice extends Device {

  String _userName = _meaCloudUsername;
  String _password = _meaCloudPassword;

  String ipAddress = _meaCloudUrl;
  String urlString = _meaCloudUrl;

  late Timer _timer;

  Map <String, String> requestResult = {};

  String _meaContextKey = '';
  bool _isConnected = false;

  List<MeaData> _meaDataList = [];
  MeaDevice _meaDevice = MeaDevice();

  DateTime _latestDataFetched = DateTime(0);
  int _fetchCounter = 0;

  MitsuHeatPumpDevice() {
    id = 'Mitsu/2247619164';
    name = 'Ilpo';
  }

  bool noData() {
    return _latestDataFetched.year == 0;
  }

  @override
  Future<void> init() async {
    await fetchAndAnalyzeData();
  }

  Future<bool> fetchAndAnalyzeData() async {
    bool success = true;

    if (! _isConnected) {
      _fetchCounter = 0;
      success = await login();
      log.info('MeaCloud yhteys luotu');
    }

    if (success) {
      success = await getDevices();
      analyseRequest();
      _fetchCounter ++;
    }

    if (success) {
      setNormalObservation();
    }
    else {
      observationMonitor.add(ObservationLogItem(DateTime.now(), ObservationLevel.informatic));
      success = false;
    }

    _setupTimer();
    return success;
  }

  void _setupTimer() {
    Duration delay = Duration(
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

  Future<bool> login() async {
    _isConnected = false;
    String myLoginRequest = '$_meaLoginUrl';
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
                "Email":_meaCloudUsername,
                "Password": _meaCloudPassword,
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
        } else if (errorCode == 6) {
          // too many failed attempts
          log.error('melCloud login error: too many failed attempts');
        }
        return false;
      }
      else {
        _meaContextKey = loginData['ContextKey'] ?? 0;
        _isConnected = true;
      }
      return true;
    } else {
      log.error('Mitsu kirjautuminen epäonnistui. Virhekoodi: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> logout() async {
    String myLoginRequest = '$urlString/logout?';
    final url = Uri.parse(myLoginRequest);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      log.error('Ouman uloskirjautuminen epäonnistui. Virhekoodi: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> getDevices() async {
    String getDevicesUrl = 'https://app.melcloud.com/Mitsubishi.Wifi.Client/User/ListDevices';

    final htmlResponse = await http.get(Uri.parse(getDevicesUrl),
        headers: {
          "Host": "app.melcloud.com",
          "X-MitsContextKey": _meaContextKey
        });

    if (htmlResponse == null) {
      log.error('Mitsu getDevices datan haku epäonnistui.');
      return false;
    } else if (htmlResponse.statusCode != 200) {
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

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['ipAddress'] = ipAddress;
    return json;
  }

  @override
  MitsuHeatPumpDevice.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    ipAddress = json['ipAddress'] ?? '';
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
    List<String> keyValue = param.split('=');

    // Ensure there are two parts (key and value)
    if (keyValue.length == 2) {
      String key = keyValue[0].trim();
      String value = keyValue[1].trim();
      result[key] = value;
    } else {
      // Handle invalid parameter format
      log.error('Ouman ParseDeviceData - Invalid parameter: $param');
    }
  }

  return result;
}
