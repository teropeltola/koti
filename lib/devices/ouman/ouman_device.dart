
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;

import '../device/device.dart';

const oumanUrl = 'http://192.168.72.99';
const oumanUsername = 'pannusAAT0';
const oumanPassword = 'sX4c1WpZ';

class OumanDevice extends Device {

  String ipAddress = oumanUrl;

  void initialize() {

  }

  void connect() {

  }
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

Future<String?> loginOuman(String urlString) async {
    final url = Uri.parse('$urlString/eh800.html');  // Replace with your server's URL.
    final response = await http.post(
      url,
      body: {
        'uid': oumanUsername,
        'pwd': oumanPassword,  // Replace with your actual password.
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


