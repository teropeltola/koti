import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/device/device.dart';

import 'dart:convert';
import 'dart:io';

import 'package:koti/estate/estate.dart';



void _compress(String json) {
  int size1 = json.length;
  final enCodedJson = utf8.encode(json);
  final gZipJson = gzip.encode(enCodedJson);
  final base64Json = base64.encode(gZipJson);

  final decodeBase64Json = base64.decode(base64Json);
  final decodegZipJson = gzip.decode(decodeBase64Json);
  final originalJson = utf8.decode(decodegZipJson);
  int size2 = base64Json.length;
  int size3 = originalJson.length;
  int i=3;
}

void main() {
  group('Estate Tests 1', () {
    setUp(() {});

    test('Add Device to Estate', () {
      /*
      Estate location = Estate();
      location.init('pitkä nimi','locationName');

      _compress(jsonEncode(location));


       */

    });
  });
}