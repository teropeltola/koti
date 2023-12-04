
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;

import 'dart:convert' show utf8;

import '../device/device.dart';
import '../../look_and_feel.dart';

const oumanUrl = 'http://192.168.72.99';
const oumanUsername = 'pannusAAT0';
const oumanPassword = 'sX4c1WpZ';

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

  String _userName = oumanUsername;
  String _password = oumanPassword;

  String ipAddress = oumanUrl;
  String urlString = oumanUrl;

  late Timer _timer;

  Map <String, String> requestResult = {};

  double _outsideTemperature = noValue;
  double _measuredWaterTemperature = noValue;
  double _requestedWaterTemperature = noValue;
  double _valve = noValue;
  double _heaterEstimatedTemperature = noValue;


  Future<void> fetchInformation() async {
    if (myEstate.iAmActive) {
      await login();
      await getData();
      await logout();
    }
    _setupTimer();
  }

  void _setupTimer() {
    Duration delay = Duration(
      minutes: _oumanFetchingIntervalInMinutes,
    );

    // Schedule the daily task at given time
    _timer = Timer(delay, () async {
      await fetchInformation();
    });
  }

  String parameterValue(String paramName) {
    return requestResult[oumanCodes[paramName] ?? ''] ?? '';
  }

  String oumanDataCodes() {
    return 'S_227_85;S_135_85;S_1000_0;S_259_85;S_275_85;S_134_85;S_272_85;S_26_85;S_89_85;S_90_85;S_54_85;S_55_85;S_61_85;S_63_85;S_65_85;S_260_85;S_258_85;S_286_85;S_92_85;S_59_85;S_1004_85;S_330_85;';
    String codes = '';
    oumanCodes.values.forEach((v) => codes += "$v;");
    return codes;
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
  }

  Future<bool> login() async {
    String myLoginRequest = '$urlString/login?uid=$oumanUsername;pwd=$oumanPassword;';
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
  void dispose() {
    //super.dispose();
    _timer.cancel();
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
    map['uid'] = oumanUsername;
    map['pwd'] = oumanPassword;
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
        'uid': oumanUsername,
        'pwd': oumanPassword,
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
  String myLoginRequest = '$urlString/login?uid=$oumanUsername;pwd=$oumanPassword;';
  final url = Uri.parse(myLoginRequest);  // Replace with your server's URL.
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return true;
  } else {
    log.error('Ouman kirjautuminen epäonnistui. Virhekoodi: ${response.statusCode}');
    return false;
  }
}


/*
    var loginPage = await http.get('https://mypage.com/login');
    var document = parse(loginPage.body);
    var username = document.querySelector('#username') as InputElement;
    var password = document.querySelector('#password') as InputElement;
    username.value = 'USERNAME';
    password.value = 'PASSWORD';
    var submit = document.querySelector('.btn-submit') as ButtonElement;
    submit.click();

  TOINEN VAIHTOEHTO:

    final uri = 'https://na57.salesforce.com/services/oauth2/token';
var map = new Map<String, dynamic>();
map['grant_type'] = 'password';
map['client_id'] = '3MVG9dZJodJWITSviqdj3EnW.LrZ81MbuGBqgIxxxdD6u7Mru2NOEs8bHFoFyNw_nVKPhlF2EzDbNYI0rphQL';
map['client_secret'] = '42E131F37E4E05313646E1ED1D3788D76192EBECA7486D15BDDB8408B9726B42';
map['username'] = 'example@mail.com.us';
map['password'] = 'ABC1234563Af88jesKxPLVirJRW8wXvj3D';

http.Response response = await http.post(
    uri,
    body: map,
);
 */


