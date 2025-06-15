import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart'; // Required for Colors and IconData
import 'package:koti/logic/color_palette.dart'; // Adjust this import path if your file is elsewhere

void main() {
  group('ColorPaletteItem', () {
    test('Constructor initializes properties correctly', () {
      final item = ColorPaletteItem(Colors.blue, Colors.pink, Colors.orange, Icons.face);

      expect(item.backgroundColor, Colors.blue);
      expect(item.textColor, Colors.pink);
      expect(item.iconColor, Colors.orange);
      expect(item.icon, Icons.face);
    });

    test('modify method updates properties correctly', () {
      final item = ColorPaletteItem(Colors.blue, Colors.pink, Colors.orange, Icons.face);

      item.modify(
        newBackgroundColor: Colors.red,
        newTextColor: Colors.green,
        newIconColor: Colors.purple,
        newIcon: Icons.home,
      );

      expect(item.backgroundColor, Colors.red);
      expect(item.textColor, Colors.green);
      expect(item.iconColor, Colors.purple);
      expect(item.icon, Icons.home);
    });

    test('modify method handles null values correctly (does not change properties)', () {
      final item = ColorPaletteItem(Colors.blue, Colors.pink, Colors.orange, Icons.face);

      item.modify(
        newBackgroundColor: Colors.red,
      );
      expect(item.backgroundColor, Colors.red); // Changed
      expect(item.textColor, Colors.pink);      // Unchanged
      expect(item.iconColor, Colors.orange);    // Unchanged
      expect(item.icon, Icons.face);            // Unchanged

      item.modify(
        newTextColor: Colors.green,
      );
      expect(item.textColor, Colors.green);     // Changed
      expect(item.backgroundColor, Colors.red); // Unchanged

      item.modify(); // Call with no arguments
      expect(item.backgroundColor, Colors.red);
      expect(item.textColor, Colors.green);
    });
  });

  group('ColorPalette', () {
    late ColorPalette colorPalette;

    setUp(() {
      // Initialize a fresh ColorPalette before each test
      colorPalette = ColorPalette();
    });

    test('Initial currentMode is notConnected', () {
      expect(colorPalette.currentMode, ColorPaletteMode.notConnected);
    });

    test('Initial items are correctly set up based on constants', () {
      // Verify initial default values for each mode
      expect(colorPalette.items[ColorPaletteMode.alarmSet.index].backgroundColor, deviceAlarmSetBackgroundColor);
      expect(colorPalette.items[ColorPaletteMode.notConnected.index].backgroundColor, deviceNotConnectedBackgroundColor);
      expect(colorPalette.items[ColorPaletteMode.workingOff.index].backgroundColor, deviceWorkingOffBackgroundColor);
      expect(colorPalette.items[ColorPaletteMode.workingOn.index].backgroundColor, deviceWorkingOnBackgroundColor);

      expect(colorPalette.items[ColorPaletteMode.alarmSet.index].icon, Icons.alarm_on);
      expect(colorPalette.items[ColorPaletteMode.notConnected.index].icon, Icons.not_interested);
      expect(colorPalette.items[ColorPaletteMode.workingOff.index].icon, Icons.power_off);
      expect(colorPalette.items[ColorPaletteMode.workingOn.index].icon, Icons.power_outlined);
    });

    group('setCurrentPalette', () {
      test('sets mode to alarmSet if alarmOn is true', () {
        colorPalette.setCurrentPalette(true, true, true); // alarmOn=true, connected=true, isOn=true
        expect(colorPalette.currentMode, ColorPaletteMode.alarmSet);

        colorPalette.setCurrentPalette(true, false, false); // alarmOn=true, connected=false, isOn=false
        expect(colorPalette.currentMode, ColorPaletteMode.alarmSet);
      });

      test('sets mode to notConnected if alarmOn is false and connected is false', () {
        colorPalette.setCurrentPalette(false, false, true); // alarmOn=false, connected=false, isOn=true
        expect(colorPalette.currentMode, ColorPaletteMode.notConnected);

        colorPalette.setCurrentPalette(false, false, false); // alarmOn=false, connected=false, isOn=false
        expect(colorPalette.currentMode, ColorPaletteMode.notConnected);
      });

      test('sets mode to workingOn if alarmOn is false, connected is true, and isOn is true', () {
        colorPalette.setCurrentPalette(false, true, true); // alarmOn=false, connected=true, isOn=true
        expect(colorPalette.currentMode, ColorPaletteMode.workingOn);
      });

      test('sets mode to workingOff if alarmOn is false, connected is true, and isOn is false', () {
        colorPalette.setCurrentPalette(false, true, false); // alarmOn=false, connected=true, isOn=false
        expect(colorPalette.currentMode, ColorPaletteMode.workingOff);
      });
    });

    group('currentPaletteItem and getters', () {
      test('returns correct item and properties for notConnected mode', () {
        colorPalette.setCurrentPalette(false, false, false); // Set to notConnected
        final item = colorPalette.currentPaletteItem();

        expect(item.backgroundColor, deviceNotConnectedBackgroundColor);
        expect(item.textColor, deviceNotConnectedTextColor);
        expect(item.iconColor, deviceNotConnectedIconColor);
        expect(item.icon, Icons.not_interested);

        expect(colorPalette.backgroundColor(), deviceNotConnectedBackgroundColor);
        expect(colorPalette.textColor(), deviceNotConnectedTextColor);
        expect(colorPalette.iconColor(), deviceNotConnectedIconColor);
        expect(colorPalette.icon(), Icons.not_interested);
      });

      test('returns correct item and properties for workingOn mode', () {
        colorPalette.setCurrentPalette(false, true, true); // Set to workingOn
        final item = colorPalette.currentPaletteItem();

        expect(item.backgroundColor, deviceWorkingOnBackgroundColor);
        expect(item.textColor, deviceWorkingOnTextColor);
        expect(item.iconColor, deviceWorkingOnIconColor);
        expect(item.icon, Icons.power_outlined);

        expect(colorPalette.backgroundColor(), deviceWorkingOnBackgroundColor);
        expect(colorPalette.textColor(), deviceWorkingOnTextColor);
        expect(colorPalette.iconColor(), deviceWorkingOnIconColor);
        expect(colorPalette.icon(), Icons.power_outlined);
      });

      // Add more tests for alarmSet and workingOff modes as needed
    });

    group('modify method (modifies item specified by newMode)', () {
      test('modifies the specific item corresponding to newMode, regardless of currentMode', () {
        // Store original values for verification
        final originalNotConnectedText = deviceNotConnectedTextColor;
        final originalWorkingOnIcon = deviceWorkingOnIconColor;
        final originalAlarmSetText = deviceAlarmSetTextColor;

        // Ensure currentMode is not the target of the modification initially
        colorPalette.setCurrentPalette(false, true, false); // Set currentMode to workingOff
        expect(colorPalette.currentMode, ColorPaletteMode.workingOff);

        // 1. Modify the 'notConnected' item by explicitly passing ColorPaletteMode.notConnected
        colorPalette.modify(ColorPaletteMode.notConnected, newBackgroundColor: Colors.orange);

        // Assert that the 'notConnected' item's property has changed
        expect(colorPalette.items[ColorPaletteMode.notConnected.index].backgroundColor, Colors.orange);
        // Assert that the currentMode is still workingOff and its properties are UNCHANGED
        expect(colorPalette.currentMode, ColorPaletteMode.workingOff);
        expect(colorPalette.backgroundColor(), deviceWorkingOffBackgroundColor); // Should still be the original workingOff background

        // 2. Modify the 'workingOn' item by explicitly passing ColorPaletteMode.workingOn
        colorPalette.modify(ColorPaletteMode.workingOn, newIconColor: Colors.cyan);

        // Assert that the 'workingOn' item's property has changed
        expect(colorPalette.items[ColorPaletteMode.workingOn.index].iconColor, Colors.cyan);
        // Current mode is still workingOff, its properties unchanged
        expect(colorPalette.currentMode, ColorPaletteMode.workingOff);
        expect(colorPalette.iconColor(), deviceWorkingOffIconColor);

        // 3. Modify the 'alarmSet' item by explicitly passing ColorPaletteMode.alarmSet
        colorPalette.modify(ColorPaletteMode.alarmSet, newTextColor: Colors.brown);

        // Assert that the 'alarmSet' item's property has changed
        expect(colorPalette.items[ColorPaletteMode.alarmSet.index].textColor, Colors.brown);
        // Current mode is still workingOff, its properties unchanged
        expect(colorPalette.currentMode, ColorPaletteMode.workingOff);
        expect(colorPalette.textColor(), deviceWorkingOffTextColor);

        // Verify that items NOT targeted by modify calls retain their original default values
        expect(colorPalette.items[ColorPaletteMode.notConnected.index].textColor, originalNotConnectedText); // This line is slightly tricky if the initial default was also orange, but for clarity, ensure it matches what you expect after just the background change.
        expect(colorPalette.items[ColorPaletteMode.workingOn.index].backgroundColor, deviceWorkingOnBackgroundColor); // Background of workingOn was not changed
        expect(colorPalette.items[ColorPaletteMode.alarmSet.index].icon, Icons.alarm_on); // Icon of alarmSet was not changed
      });
    });

  });
}