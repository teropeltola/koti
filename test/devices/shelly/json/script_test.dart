import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/shelly/json/script.dart';

void main() {
  group('ShellyScriptConfig', () {
    test('fromJson and toJson', () {
      final original = ShellyScriptConfig(id: 1, name: 'Test', enable: true);
      final json = original.toJson();
      final fromJson = ShellyScriptConfig.fromJson(json);

      expect(fromJson.id, original.id);
      expect(fromJson.name, original.name);
      expect(fromJson.enable, original.enable);
    });

    test('isEmpty', () {
      final emptyConfig = ShellyScriptConfig.empty();
      expect(emptyConfig.isEmpty(), true);

      final nonEmptyConfig = ShellyScriptConfig(id: 1, name: 'Test', enable: true);
      expect(nonEmptyConfig.isEmpty(), false);
    });
  });

  group('ShellyScriptStatus', () {
    test('fromJson and toJson', () {
      final original = ShellyScriptStatus(id: 1, running: true);
      final json = original.toJson();
      final fromJson = ShellyScriptStatus.fromJson(json);

      expect(fromJson.id, original.id);
      expect(fromJson.running, original.running);
    });
  });

  group('ShellyScriptId', () {
    test('fromJson and toJson', () {
      final original = ShellyScriptId(id: 1);
      final json = original.toJson();
      final fromJson = ShellyScriptId.fromJson(json);

      expect(fromJson.id, original.id);
    });
  });

  group('ShellyScriptLength', () {
    test('fromJson and toJson', () {
      final original = ShellyScriptLength(len: 10);
      final json = original.toJson();
      final fromJson = ShellyScriptLength.fromJson(json);

      expect(fromJson.len, original.len);
    });
  });

  group('ShellyScriptRunning', () {
    test('fromJson and toJson', () {
      final original = ShellyScriptRunning(wasRunning: true);
      final json = original.toJson();
      final fromJson = ShellyScriptRunning.fromJson(json);

      expect(fromJson.wasRunning, original.wasRunning);
    });
  });

  group('ShellyScriptList', () {
    test('fromJson and toJson', () {
      final original = ShellyScriptList(
        scripts: [
          Scripts(id: 1, name: 'Test', enable: true, running: false),
          Scripts(id: 2, name: 'Test2', enable: false, running: true),
        ],
      );

      final json = original.toJson();
      final fromJson = ShellyScriptList.fromJson(json);

      expect(fromJson.scripts.length, original.scripts.length);

      for (var i = 0; i < original.scripts.length; i++) {
        expect(fromJson.scripts[i].id, original.scripts[i].id);
        expect(fromJson.scripts[i].name, original.scripts[i].name);
        expect(fromJson.scripts[i].enable, original.scripts[i].enable);
        expect(fromJson.scripts[i].running, original.scripts[i].running);
      }
    });

    test('empty constructor', () {
      final emptyList = ShellyScriptList.empty();
      expect(emptyList.scripts.isEmpty, true);
    });
  });

  group('Scripts', () {
    test('fromJson and toJson', () {
      final original = Scripts(id: 1, name: 'Test', enable: true, running: false);
      final json = original.toJson();
      final fromJson = Scripts.fromJson(json);

      expect(fromJson.id, original.id);
      expect(fromJson.name, original.name);
      expect(fromJson.enable, original.enable);
      expect(fromJson.running, original.running);
    });
  });
}
