
import '../device/device.dart';

class NetworkDevice extends Device {
  String internetPage = '';

  NetworkDevice();

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['internetPage'] = internetPage;
    return json;
  }

  @override
  NetworkDevice.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    internetPage = json['internetPage'] ?? '';
  }

}