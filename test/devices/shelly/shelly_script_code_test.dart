import 'dart:convert' show utf8;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/shelly/shelly_script_code.dart';

void main() {
  group('ShellyScriptCode tests', () {
    test('setCode should update originalCode and reset modifiedCode', () {
      final shellyScriptCode = ShellyScriptCode();
      shellyScriptCode.setCode('test code');

      expect(shellyScriptCode.originalCode, 'test code');
      expect(shellyScriptCode.modifiedCode, '');
    });

    test('checkErrors should return an empty list for valid code', () {
      final shellyScriptCode = ShellyScriptCode();
      shellyScriptCode.setCode('valid code');

      final errors = shellyScriptCode.checkErrors();

      expect(errors, isEmpty);
    });

    test('modify should replace double quotes with single quotes', () {
      final shellyScriptCode = ShellyScriptCode();
      shellyScriptCode.setCode('some "code" with "quotes"');

      shellyScriptCode.modify();

      expect(shellyScriptCode.modifiedCode, "some 'code' with 'quotes'");

      List<String> s = shellyScriptCode.codeChunks();

      expect(shellyScriptCode, s[0]);
    });

    test('code chunks', () {
      final shellyScriptCode = ShellyScriptCode();
      String longText = '12345129312039dsm,asdksadlaskdlasndm23op32jdl23l3mdasdasdad'
        'sadsadas123451293120"39dsm,asdksadlaskdlasndm23op32jdl23l3mdasdasdadASDASDSAASDAS';
      for (int i=0; i<5; i++) {
        longText += longText;
      }
      shellyScriptCode.setCode(longText);

      shellyScriptCode.modify();

      List<String> s = shellyScriptCode.codeChunks();

      String s2 = s[0];
      for (int i = 1; i<s.length; i++) {
        s2 += s[i];
      }

      expect(s2, shellyScriptCode.modifiedCode);
    });

    test('comments', () {
      final shellyScriptCode = ShellyScriptCode();
      shellyScriptCode.setCode('');
      shellyScriptCode.modify();
      expect(shellyScriptCode.modifiedCode,'');

      shellyScriptCode.setCode('//');
      shellyScriptCode.modify();
      expect(shellyScriptCode.modifiedCode,'');

      shellyScriptCode.setCode('/**/');
      shellyScriptCode.modify();
      expect(shellyScriptCode.modifiedCode,'');

      shellyScriptCode.setCode('/*////////*/');
      shellyScriptCode.modify();
      expect(shellyScriptCode.modifiedCode,'');

      shellyScriptCode.setCode('//\n');
      shellyScriptCode.modify();
      expect(shellyScriptCode.modifiedCode,'\n');

    });

    test('utf8', () {
      check("let greeting='Terve\n'; print(greeting);");
      check('if (OnlyNightHours == false) { urlToCall = "https://api.spot-hinta.fi/JustNowRank/" + CheapestHours + "/" + PriceAlwaysAllowed + "?region=" + Region; print("Url to be used: " + urlToCall); }');
    });

    });
}

check(String cCode) {
  String code = cCode;
  ShellyScriptCode ssc = ShellyScriptCode();
  ssc.setCode(code);
  ssc.modify();
  String putCodeString = 'Script.PutCode?id=1&code="${ssc.modifiedCode}"&append=false';
  String command = _cmd(putCodeString);
  var uri = Uri.parse(command);
  int i= 8;

}

const String _http = 'http://';
const String _rpc = '/rpc/';

String _cmd(String commandName) {
  return '$_http 11.22.33.44_rpc$commandName';
}

