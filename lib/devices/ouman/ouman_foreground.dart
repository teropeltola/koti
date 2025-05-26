// !!! note: this is workmanager function and global objects or variables can't
// be used !!!

import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:koti/devices/ouman/trend_ouman.dart';

import '../../app_configurator.dart';
import '../../foreground_configurator.dart';
import '../../logic/observation.dart';
import '../../logic/task_handler_controller.dart';
import '../../trend/trend_event.dart';

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

class OumanForeground {

  String estateId = '';
  String deviceId = '';
  String url = '';
  String username = '';
  String password = '';
  String wifiName = '';
  String directoryPath = '';

  OumanForeground({
    required this.estateId,
    required this.deviceId,
    required this.username,
    required this.password,
    required this.url,
    required this.wifiName,
    required this.directoryPath
  }
  );

  factory OumanForeground.fromJson(Map<String, dynamic> json) =>
      OumanForeground(
        estateId: json['estateId'] ?? '',
        deviceId: json['deviceId'] ?? '',
        username: json['username'] ?? '',
        password: json['password'] ?? '',
        url: json['url'] ?? '',
        wifiName: json['wifiName'] ?? '',
        directoryPath: json['directoryPath'] ?? '',
  );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['estateId'] = estateId;
    json['deviceId'] = deviceId;
    json['username'] = username;
    json['password'] = password;
    json['url'] = url;
    json['wifiName'] = wifiName;
    json['directoryPath'] = directoryPath;
    return json;
  }

  Map <String, String> requestResult = {};

  ForegroundTrendEventBox event = ForegroundTrendEventBox();

  late Box<TrendOuman> oumanBox;

  void _logError(String errorText) {
    event.box.add(TrendEvent(
      DateTime.now().millisecondsSinceEpoch,
      estateId,
      deviceId,
      ObservationLevel.alarm,
      errorText
    ));
  }

  Future<void> init() async {

    //await initHiveForForeground();
    await event.init();

    await Hive.openBox<TrendOuman>(hiveTrendOumanName, path: directoryPath);
    oumanBox = Hive.box<TrendOuman>(hiveTrendOumanName);

  }

  Future<bool> fetchDataFromOuman() async {
    bool success = false;
    try {
      if  (true) {// (estate.myWifiIsActive) {
        success = await login();
        if (success) {
          success = await getData();
          if (success) {
            success = await logout();
          }
        }
      }
    }
    catch (e) {
      _logError('OumanWorkmanager data fetching exception: $e');
      success = false;
    }
    return success;
  }

  Future<bool> login() async {

    String myLoginRequest = '$url/login?uid=$username;pwd=$password;';
    try {
      final uri = Uri.parse(myLoginRequest); // Replace with your server's URL.
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return true;
      } else {
        _logError('OumanWorkmanager logging failed. Error code: ${response
            .statusCode}');
        return false;
      }
    }
    catch(e) {
      _logError('OumanWorkmanager login exception: "$myLoginRequest": $e');
      return false;
    }
  }

  Future<bool> logout() async {
    String myLogout = '$url/logout?';
    final uri = Uri.parse(myLogout);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return true;
    } else {
      _logError('OumanWorkmanager logout failed. Error code: ${response.statusCode}');
      return false;
    }
  }

  String _oumanDataCodes() {
    return 'S_227_85;S_135_85;S_1000_0;S_259_85;S_275_85;S_134_85;S_272_85;S_26_85;S_89_85;S_90_85;S_54_85;S_55_85;S_61_85;S_63_85;S_65_85;S_260_85;S_258_85;S_286_85;S_92_85;S_59_85;S_1004_85;S_330_85;';
  }

  Future<bool> getData() async {
    final htmlResponse = await http.get(Uri.parse('$url/eh800.html'));
    if (htmlResponse.statusCode != 200) {
      _logError('OumanWorkmanager getting data failed. Error code: ${htmlResponse.statusCode}');
      return false;
    }
    var mainPage = utf8.decode(htmlResponse.bodyBytes);

    final jsResponse = await http.get(Uri.parse('$url/eh800.js'));
    if (jsResponse.statusCode != 200) {
      _logError('OumanWorkmanager javaScript fetch failed. Error code: ${jsResponse.statusCode}');
      return false;
    }

    String request = _oumanDataCodes();
    final dataResponse = await http.get( Uri.parse( '$url/request?$request'));
    if (dataResponse.statusCode != 200) {
      _logError('OumanWorkmanager data fetch failed. Error code: ${dataResponse.statusCode}');
      return false;
    }
    String mainPageData = utf8.decode(dataResponse.bodyBytes);

    requestResult = parseDeviceData(mainPageData);
    analyseRequest();

    return true;
  }

  double getValue(String key) {
    String result = requestResult[oumanCodes[key] ?? ''] ?? '-99.9';
    return double.parse(result);
  }

  void analyseRequest() {
    oumanBox.add(TrendOuman(
      DateTime.now().millisecondsSinceEpoch,
      estateId,
      deviceId,
      getValue('OutsideTemperature'),
      getValue('L1MeasuredWaterTemperature'),
      getValue('L1RequestedWaterTemperature'),
      getValue('L1Valve'),
    ));
  }

  Map<String, String> parseDeviceData(String deviceData) {
    Map<String, String> result = {};

    // Check if the string has the expected format
    if (!deviceData.startsWith('request?')) {
      // Handle invalid format
      _logError('Ouman ParseDeviceData - Invalid data format : "${deviceData.substring(0,min(20,deviceData.length))}"');
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
    }
    return result;
  }
}

Future<bool> oumanInitFunction(TaskHandlerController controller, Map<String, dynamic> inputData) async {
  OumanForeground oumanForeground = OumanForeground.fromJson(inputData);
  await oumanForeground.init();
  await oumanForeground.getData();
  return true;
}

Future<bool> oumanExecutionFunction(TaskHandlerController controller, Map<String, dynamic> inputData) async {
  OumanForeground oumanForeground = OumanForeground.fromJson(inputData);
  print('oumanExecutionFunction');
  await oumanForeground.init();
  await oumanForeground.getData();
  return true;
}

