
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;

import 'dart:convert' show utf8;

import '../../logic/observation.dart';
import '../device/device.dart';
import '../../look_and_feel.dart';

const _oumanIP = '192.168.72.99';
const _oumanUrl = 'http://$_oumanIP';
const _oumanUsername = 'pannusAAT0';
const _oumanPassword = 'sX4c1WpZ';

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

const double noValue = -99.9;

class OumanDevice extends Device {

  String _userName = _oumanUsername;
  String _password = _oumanPassword;

  String ipAddress = _oumanUrl;
  String urlString = _oumanUrl;

  late Timer _timer;

  Map <String, String> requestResult = {};

  double _outsideTemperature = noValue;
  double _measuredWaterTemperature = noValue;
  double _requestedWaterTemperature = noValue;
  double _valve = noValue;
  double _heaterEstimatedTemperature = noValue;
  DateTime _latestDataFetched = DateTime(0);

  OumanDevice() {
    id = 'Ouman$_oumanIP';
    name = 'Ouman';
  }

  bool noData() {
    return _latestDataFetched.year == 0;
  }

  @override
  Future<void> init() async {
    if (myEstate.myWifiIsActive) {
      await login();
      await getData();
      await logout();
    }
    _setupTimer();
  }

  Future<bool> fetchAndAnalyzeData() async {
    bool success = true;

    if (myEstate.myWifiIsActive) {
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
    Duration delay = Duration(
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
    return _outsideTemperature;
  }

  double measuredWaterTemperature() {
    return _measuredWaterTemperature;
  }

  double requestedWaterTemperature() {
    return _requestedWaterTemperature;
  }

  double valve() {
    return _valve;
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
    _outsideTemperature = getValue('OutsideTemperature');
    _measuredWaterTemperature = getValue('L1MeasuredWaterTemperature');
    _requestedWaterTemperature = getValue('L1RequestedWaterTemperature');
    _valve = getValue('L1Valve');
    _heaterEstimatedTemperature = _measuredWaterTemperature * 100 / _valve;
    _latestDataFetched = DateTime.now();
  }

  bool _useObservations = false;
  double _observationAlarmValveLimit = 99.0;
  double _observationAlarmTempDiff = 0.5;
  double _observationWarningValveLimit = 95.0;
  double _observationWarningTempDiff = 0.0;
  double _observationInfoValveLimit = 90.0;

  double waterTempDiff() => _requestedWaterTemperature - _measuredWaterTemperature;

  ObservationLevel observationLevel() {
    if ((_valve > _observationAlarmValveLimit) &&
        (waterTempDiff() > _observationAlarmTempDiff)) {
      return ObservationLevel.alarm;
    }
    else if ((_valve > _observationWarningValveLimit) &&
        (waterTempDiff() > _observationWarningTempDiff)) {
      return ObservationLevel.warning;
    }
    else if (_valve > _observationInfoValveLimit) {
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
    String myLoginRequest = '$urlString/login?uid=$_oumanUsername;pwd=$_oumanPassword;';
    final url = Uri.parse(myLoginRequest);  // Replace with your server's URL.
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      log.error('Ouman kirjautuminen epäonnistui. Virhekoodi: ${response.statusCode}');
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

  Future<bool> getData() async {
    final htmlResponse = await http.get(Uri.parse('$urlString/eh800.html'));
    if (htmlResponse.statusCode != 200) {
      log.error('Ouman datan haku epäonnistui. Virhekoodi: ${htmlResponse.statusCode}');
      return false;
    }
    var mainPage = utf8.decode(htmlResponse.bodyBytes);

    final jsResponse = await http.get(Uri.parse('$urlString/eh800.js'));
    if (jsResponse.statusCode != 200) {
      log.error('Ouman javaScriptin haku epäonnistui. Virhekoodi: ${jsResponse.statusCode}');
      return false;
    }

    String request = oumanDataCodes();
    final dataResponse =
      await http.get( Uri.parse( '$urlString/request?$request'));
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
    ipAddress = json['ipAddress'] ?? '';
  }

}

Map<String, String> parseDeviceData(String deviceData) {
  Map<String, String> result = {};

  // Check if the string has the expected format
  if (!deviceData.startsWith('request?')) {
    // Handle invalid format
    print('Invalid data format');
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
      print('Invalid parameter format: $param');
    }
  }

  return result;
}

/*
Future<String?> scrapeHtmlContent(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final document = htmlParser.parse(response.body);
    final elements = document.querySelectorAll('.your-html-element-class'); // Replace with your HTML element class or ID
    if (elements.isNotEmpty) {
      return elements[0].text; // Extract text content from the HTML element
    }
  }
  return null;
}


Future<String?> loginOuman2(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {


    var map = <String, String>{};
    map['uid'] = _oumanUsername;
    map['pwd'] = _oumanPassword;
    final response2 = await http.post(
      Uri.parse('$url/eh800.html'),
      body: map,
    );
    if (response2.statusCode == 200) {
      final response3 = await http.get(Uri.parse(url));
      final document = htmlParser.parse(response3.body);
    }
  }
  return null;
}

Future<String?> loginOuman3(String urlString) async {
    final url = Uri.parse('$urlString');  // Replace with your server's URL.
    final response = await http.post(
      url,
      body: {
        'uid': _oumanUsername,
        'pwd': _oumanPassword,
      },
    );

    if (response.statusCode == 200) {
      final response3 = await http.get(url);
      final document = htmlParser.parse(response3.body);
    } else {
      // Handle login errors.
    }
    return '1';
}

Future<bool> loginOuman(String urlString) async {
  String myLoginRequest = '$urlString/login?uid=$_oumanUsername;pwd=$_oumanPassword;';
  final url = Uri.parse(myLoginRequest);  // Replace with your server's URL.
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return true;
  } else {
    log.error('Ouman kirjautuminen epäonnistui. Virhekoodi: ${response.statusCode}');
    return false;
  }
}


 */
