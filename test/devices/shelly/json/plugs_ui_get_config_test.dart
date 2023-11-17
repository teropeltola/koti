import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/shelly/json/plugs_ui_get_config.dart';


void main() {
  group('PlugsUiGetConfig', () {
    test('fromJson should correctly parse JSON', () {
      final Map<String, dynamic> json = {
        'leds': {
          'mode': 'testMode',
          'colors': {
            'switch:0': {
              'on': {
                'rgb': [255.0, 0.0, 0.0],
                'brightness': 100.0,
              },
              'off': {
                'rgb': [0.0, 255.0, 0.0],
                'brightness': 50.0,
              },
            },
            'power': {
              'brightness': 75.0,
            },
          },
          'night_mode': {
            'enable': true,
            'brightness': 80.0,
            'active_between': ['10:00 PM', '6:00 AM'],
          },
        },
        'controls': {
          'switch:0': {
            'on': {
              'rgb': [255.0, 0.0, 0.0],
              'brightness': 100.0,
            },
            'off': {
              'rgb': [0.0, 255.0, 0.0],
              'brightness': 50.0,
            },
          },
        },
      };

      final config = PlugsUiGetConfig.fromJson(json);

      expect(config.leds.mode, equals('testMode'));
      expect(config.leds.colors.switchh.on.rgb, equals([255.0, 0.0, 0.0]));
      expect(config.leds.colors.power.brightness, equals(75.0));
      expect(config.leds.nightMode.activeBetween, contains('10:00 PM'));
      expect(config.controls.switchh.on.brightness, equals(100.0));
    });

    test('toJson should correctly convert to JSON', () {
      final config = PlugsUiGetConfig(
        leds: Leds(
          mode: 'testMode',
          colors: Colors(
            switchh: Switch(
              on: On(
                rgb: [255.0, 0.0, 0.0],
                brightness: 100.0,
              ),
              off: Off(
                rgb: [0.0, 255.0, 0.0],
                brightness: 50.0,
              ),
            ),
            power: Power(
              brightness: 75.0,
            ),
          ),
          nightMode: NightMode(
            enable: true,
            brightness: 80.0,
            activeBetween: ['10:00 PM', '6:00 AM'],
          ),
        ),
        controls: Controls(
          switchh: Switch(
            on: On(
              rgb: [255.0, 0.0, 0.0],
              brightness: 100.0,
            ),
            off: Off(
              rgb: [0.0, 255.0, 0.0],
              brightness: 50.0,
            ),
          ),
        ),
      );

      final json = config.toJson();

      expect(json['leds']['mode'], equals('testMode'));
      expect(json['leds']['colors']['switch:0']['on']['rgb'],
          equals([255.0, 0.0, 0.0]));
      expect(json['leds']['colors']['power']['brightness'], equals(75.0));
      expect(
          json['leds']['night_mode']['active_between'], contains('10:00 PM'));
      expect(json['controls']['switch:0']['on']['brightness'], equals(100.0));
    });
  });

  group('PlugsUiGetConfig group 2', () {
    test('fromJson should handle missing or null values gracefully', () {
      // Test case with missing 'leds' and 'controls' fields
      final Map<String, dynamic> json = {};

      final config = PlugsUiGetConfig.fromJson(json);

      // Check that default values are applied
      expect(config.leds.mode, equals(''));
      expect(config.leds.colors.switchh.on.rgb, equals([]));
      expect(config.controls.switchh.on.rgb, equals([]));
    });

    test(
        'fromJson should handle missing or null sub-class fields gracefully', () {
      // Test case with missing 'mode' and 'brightness' fields
      final Map<String, dynamic> json = {
        'leds': {
          'colors': {
            'switch:0': {
              'on': {
                'rgb': [255.0, 0.0, 0.0],
              },
              'off': {
                'rgb': [0.0, 255.0, 0.0],
              },
            },
            'power': {},
          },
          'night_mode': {
            'active_between': ['10:00 PM', '6:00 AM'],
          },
        },
        'controls': {
          'switch:0': {
            'off': {
              'brightness': 50.0,
            },
          },
        },
      };

      final config = PlugsUiGetConfig.fromJson(json);

      // Check that default values are applied
      expect(config.leds.mode, equals(''));
      expect(config.leds.colors.power.brightness, equals(0.0));
      expect(config.controls.switchh.on.brightness, equals(0.0));
    });

    test('toJson should correctly convert to JSON with default values', () {
      final config = PlugsUiGetConfig(
        leds: Leds(
          colors: Colors(
            switchh: Switch(
              on: On(
                rgb: [],
                brightness: 0.0,
              ),
              off: Off(
                rgb: [],
                brightness: 0.0,
              ),
            ),
            power: Power(
              brightness: 0.0,
            ),
          ),
          nightMode: NightMode(
            enable: false,
            brightness: 0.0,
            activeBetween: [],
          ), mode: '',
        ),
        controls: Controls(
          switchh: Switch(
            on: On(
              rgb: [],
              brightness: 0.0,
            ),
            off: Off(
              rgb: [],
              brightness: 0.0,
            ),
          ),
        ),
      );

      final json = config.toJson();

      // Check that the resulting JSON contains default values
      expect(json['leds']['mode'], equals(''));
      expect(json['leds']['colors']['power']['brightness'], equals(0.0));
      expect(json['controls']['switch:0']['on']['brightness'], equals(0.0));
    });
  });
}
