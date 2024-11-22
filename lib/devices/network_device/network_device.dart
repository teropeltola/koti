import 'package:flutter/material.dart';
import '../device/device.dart';

class NetworkDevice extends Device {
  String internetPage = '';

  NetworkDevice();


  @override
  IconData icon() {
    return Icons.web;
  }

  @override
  String shortTypeName() {
    return 'verkko';
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['internetPage'] = internetPage;
    return json;
  }

  @override
  void fromJson(Map<String, dynamic> json){
    super.fromJson(json);
    internetPage = json['internetPage'] ?? '';
  }

  @override
  NetworkDevice.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

}