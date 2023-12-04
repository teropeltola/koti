
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;


abstract class WebAuthService {
  final String authUrl;
  final String urlScheme;

  WebAuthService(this.authUrl, this.urlScheme);

  Future<String> authenticate();
}

class TeslaAuth extends WebAuthService
{
  TeslaAuth() : super("https://auth.tesla.com/oauth2/v3/authorize", "https");

  @override
  Future<String> authenticate() async {
    var request = TeslaAuthRequestHelper().asRequest();
    var response = await http.Client().get(request);
    if(response.statusCode == 200) {
      return response.body;
    } else {
      return "";
    }
  }
}

class TeslaAuthRequestHelper
{

  final clientId = "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384";
  final clientSecret = "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3";
  late final String codeVerifier;
  late final String codeChallenge;
  final codeChallengeMethod = "S256";
  final redirectUri = "https://auth.tesla.com/void/callback";
  final responseType = "code";
  final scope = "openid email offline_access";
  final state = utf8.fuse(base64Url).encode(getRandomString(20));

  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();

  static String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  TeslaAuthRequestHelper() {
    codeVerifier = getRandomString(87);
    //Creates a codec fused with a ut8f and then a base64url codec.
    //The encode on the resulting codec will first encode the string to utf-8
    //and then to base64Url
    codeChallenge = utf8.fuse(base64Url).encode(codeVerifier);
  }

  Uri asRequest() {
    return Uri.https('auth.tesla.com', 'oauth2/v3/authorize', {
      "client_id": "ownerapi",
      // "client_secret": clientSecret,
      "code_challenge": codeChallenge,
      "code_challenge_method": codeChallengeMethod,
      "redirect_uri": redirectUri,
      "response_type": responseType,
      "scope": scope,
      "state": state,
    });
  }
}