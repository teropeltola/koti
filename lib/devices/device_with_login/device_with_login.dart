
import 'package:koti/logic/web_login_data.dart';

import '../device/device.dart';


class DeviceWithLogin extends Device {

  DeviceWithLogin(): super();

  WebLoginData webLoginCredentials = WebLoginData();

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['webLogin'] = webLoginCredentials.toJson();
    return json;
  }

  @override
  DeviceWithLogin.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    webLoginCredentials = json['webLogin'] ?? WebLoginData();
  }

}
