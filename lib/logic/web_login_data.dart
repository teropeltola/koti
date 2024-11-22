import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _usernameKey = 'username';
const String _passwordKey = 'password';

class WebLoginData {
  FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String _url = '';

  String get url => _url;
  set url(String newUrl) { _url = newUrl; }

  WebLoginData([FlutterSecureStorage? secureStorage])
      : _secureStorage = secureStorage ?? FlutterSecureStorage();

  void initMock(FlutterSecureStorage secureStorage) {
    _secureStorage = secureStorage;
  }

  Future<String> username() async {
    return await _secureRead('$url$_usernameKey');
  }

  Future<String> password() async {
    return await _secureRead('$url$_passwordKey');
  }

  Future<void> initUsernameAndPassword(String username, String password) async {
    await _secureWrite(_usernameKey, username);
    await _secureWrite(_passwordKey, password);
  }

  Future<void> deletePermanentData() async {
    await _permanentDelete(_usernameKey);
    await _permanentDelete(_passwordKey);
    url = '';
  }

  Future<String> _secureRead(String key) async {
    String value = await _secureStorage.read(key: key) ?? '';
    return value;
  }

  Future<void> _secureWrite(String key, String value) async {
    await _secureStorage.write(key: '$url$key', value: value);
  }

  Future<void> _permanentDelete(String key) async {
    await _secureStorage.delete(key: '$url$key');
  }


  WebLoginData.fromJson(Map<String, dynamic> json){
    _url = json['url'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['url'] = _url;

    return json;
  }
}

