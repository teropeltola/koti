
import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/device/device.dart';
import 'package:koti/devices/device/device_state.dart';
import 'package:koti/devices/ouman/ouman_device.dart';
import 'package:koti/devices/shelly_timer_switch/shelly_timer_switch.dart';

import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/estate/estate.dart';
import 'package:koti/functionalities/heating_system_functionality/heating_system.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';
import 'package:koti/functionalities/tesla_functionality/tesla_functionality.dart';
import 'package:koti/functionalities/weather_forecast/weather_forecast.dart';
import 'package:koti/look_and_feel.dart';

void main() {
  group('Functionality tests', () {
    test('Simple functionality', () {
      Device device = Device();
      device.id = 'device.id';
      Functionality f = Functionality();
      f.pair(device);
      expect(device.connectedFunctionalities[0], f );

      var json = f.toJson();
      expect(json['type'], 'Functionality');
      Functionality f2 = Functionality.fromJson(json);
      expect(f2.device.id, 'device.id');
      expect(f.id(), f2.id());
      expect(f.id(), json['id']);
    });

    test('Functionality with extendedF', () {
      Device device = Device();
      device.id = 'device.id';
      Functionality f = Functionality();
      allFunctionalities.addFunctionality(f);
      f.pair(device);

      var json = f.toJson();

      Functionality f2 = extendedFunctionalityFromJson(json);
      expect(f2 is Functionality, true);
      expect(f2.device.id, 'device.id');
      expect(f2.id(), f.id());

      HeatingSystem h = HeatingSystem();
      OumanDevice o = OumanDevice();
      h.pair(o);
      allFunctionalities.addFunctionality(h);

      json = h.toJson();

      Functionality f3 = extendedFunctionalityFromJson(json);
      expect(f3 is HeatingSystem, true);
      expect(f3.device.name, 'Ouman');
      expect(f3.id(), h.id());

      PlainSwitchFunctionality p = PlainSwitchFunctionality();
      ShellyTimerSwitch s = ShellyTimerSwitch();
      p.pair(s);
      allFunctionalities.addFunctionality(p);

      json = p.toJson();

      Functionality f4 = extendedFunctionalityFromJson(json);
      expect(f4 is PlainSwitchFunctionality, true);
      expect(f4.device.name, '');
      expect(f4.id(), p.id());

      TeslaFunctionality t = TeslaFunctionality();
      t.pair(noDevice);
      allFunctionalities.addFunctionality(t);

      json = t.toJson();

      Functionality f5 = extendedFunctionalityFromJson(json);
      expect(f5 is TeslaFunctionality, true);
      expect(f5.device.name, '');
      expect(f5.id(), t.id());

      WeatherForecast w = WeatherForecast();
      w.pair(noDevice);
      allFunctionalities.addFunctionality(w);

      json = w.toJson();

      Functionality f6 = extendedFunctionalityFromJson(json);
      expect(f6 is WeatherForecast, true);
      expect(f6.device.name, '');
      expect(f6.id(), w.id());

    });

    test('Functionality with extendedF 2', () {
      Device device = Device();
      device.id = 'device.id';
      Functionality f = Functionality();
      f.pair(device);

      var json = f.toJson();

      Functionality f2 = extendedFunctionalityFromJson(json);
      expect(f2 is Functionality, true);
      expect(f2.device.id, 'device.id');
      expect(f2.id(), f.id());

      HeatingSystem h = HeatingSystem();
      OumanDevice o = OumanDevice();
      h.pair(o);

      json = h.toJson();

      Functionality f3 = extendedFunctionalityFromJson(json);
      expect(f3 is HeatingSystem, true);
      expect(f3.device.name, 'Ouman');

      PlainSwitchFunctionality p = PlainSwitchFunctionality();
      ShellyTimerSwitch s = ShellyTimerSwitch();
      p.pair(s);

      json = p.toJson();

      Functionality f4 = extendedFunctionalityFromJson(json);
      expect(f4 is PlainSwitchFunctionality, true);
      expect(f4.device.name, '');

      TeslaFunctionality t = TeslaFunctionality();
      t.pair(noDevice);

      json = t.toJson();

      Functionality f5 = extendedFunctionalityFromJson(json);
      expect(f5 is TeslaFunctionality, true);
      expect(f5.device.name, '');

      WeatherForecast w = WeatherForecast();
      w.pair(noDevice);

      json = w.toJson();

      Functionality f6 = extendedFunctionalityFromJson(json);
      expect(f6 is WeatherForecast, true);
      expect(f6.device.name, '');

    });
  });


  group('FunctionalityList tests', () {
    test('Simple FunctionalityList tests', () {
      FunctionalityList f = FunctionalityList();
      expect(f.findFunctionality('aaa'), f.noFunctionality());
      expect(f.findFunctionality(f.noFunctionality().id()), f.noFunctionality());
      expect(f.nbrOfFunctionalities(),1);

      Functionality fun1 = f.newFunctionality();
      expect(f.nbrOfFunctionalities(),2);
      expect(f.findFunctionality(fun1.id()), fun1);

      Functionality fun2 = f.functionalityWithId(fun1.id());
      expect(fun1, fun2);

      expect(f.findFunctionality(fun1.id()+'1'),f.noFunctionality());

      Functionality fun3 = f.functionalityWithId(fun1.id()+'2');
      expect(f.findFunctionality(fun1.id()+'2'),fun3);


    });
  });

    group('extendedFunctionality error tests', () {
      test('Missing implementation', () {
        Device device = Device();
        device.id = 'device.id';
        Functionality f = Functionality();
        f.pair(device);

        var json = f.toJson();
        json['type'] = 'bb';

        Functionality f2 = extendedFunctionalityFromJson(json);
        expect(f2 is Functionality, true);
        var x = log.history.last;
        expect(x.message, 'unknown functionality jsonObject(bb) not implemented');


      });

      test('Found different type', () {
        Device device = Device();
        device.id = 'device.id';
        Functionality f = Functionality();
        allFunctionalities.addFunctionality(f);
        f.pair(device);

        var json = f.toJson();

        Functionality f2 = extendedFunctionalityFromJson(json);
        expect(f2 is Functionality, true);
        expect(f2.device.id, 'device.id');
        expect(f2.id(), f.id());

        HeatingSystem h = HeatingSystem();
        allFunctionalities.addFunctionality(h);
        OumanDevice o = OumanDevice();
        h.pair(o);

        json = h.toJson();
        String earlierId = json['id'];

        Functionality f3 = extendedFunctionalityFromJson(json);
        expect(f3 is HeatingSystem, true);
        expect(f3.device.name, 'Ouman');
        expect(f3.id(), h.id());

        PlainSwitchFunctionality p = PlainSwitchFunctionality();
        ShellyTimerSwitch s = ShellyTimerSwitch();
        p.pair(s);

        json = p.toJson();
        json['id'] = earlierId;

        Functionality f4 = extendedFunctionalityFromJson(json);

        var x = log.history.last;
        expect(x.message, 'different functionality classes (HeatingSystem/PlainSwitchFunctionality) with the same id ($earlierId).');


      });

    });


}
