
import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/device/device.dart';
import 'package:koti/devices/device/device_state.dart';
import 'package:koti/devices/ouman/ouman_device.dart';
import 'package:koti/devices/shelly_timer_switch/shelly_timer_switch.dart';
import 'package:koti/functionalities/electricity_price/electricity_price.dart';
import 'package:koti/functionalities/electricity_price/view/electricity_price_view.dart';

import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:koti/estate/estate.dart';
import 'package:koti/functionalities/functionality/view/functionality_view.dart';
import 'package:koti/functionalities/heating_system_functionality/heating_system.dart';
import 'package:koti/functionalities/heating_system_functionality/view/heating_system_view.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';
import 'package:koti/functionalities/plain_switch_functionality/view/plain_switch_functionality_view.dart';
import 'package:koti/functionalities/tesla_functionality/tesla_functionality.dart';
import 'package:koti/functionalities/tesla_functionality/view/tesla_functionality_view.dart';
import 'package:koti/functionalities/weather_forecast/view/weather_forecast_view.dart';
import 'package:koti/functionalities/weather_forecast/weather_forecast.dart';
import 'package:koti/look_and_feel.dart';

void main() {
  group('FunctionalityView tests', () {
    test('Simple FunctionalityView', () {
      FunctionalityView f = FunctionalityView(allFunctionalities.noFunctionality());

      var json = f.toJson();
      expect(json['type'], 'FunctionalityView');
      FunctionalityView f2 = FunctionalityView.fromJson(json);
      expect(f2.myFunctionality, f.myFunctionality);
    });

    test('FunctionalityView with extendedF', () {
      Device device = Device();
      device.id = 'device.id';
      Functionality f = Functionality();
      allFunctionalities.addFunctionality(f);
      f.pair(device);

      FunctionalityView fv = FunctionalityView(f);
      var json = fv.toJson();

      FunctionalityView fv2 = extendedFunctionalityViewFromJson(json);
      expect(fv2 is FunctionalityView, true);
      expect(fv2.myFunctionality.id(), f.id());

      HeatingSystem h = HeatingSystem();
      allFunctionalities.addFunctionality(h);
      OumanDevice o = OumanDevice();
      h.pair(o);

      HeatingSystemView hv = HeatingSystemView(h);
      json = hv.toJson();

      FunctionalityView fv3 = extendedFunctionalityViewFromJson(json);
      expect(fv3 is HeatingSystemView, true);
      expect(fv3.myFunctionality.id(), h.id());

      PlainSwitchFunctionality p = PlainSwitchFunctionality();
      allFunctionalities.addFunctionality(p);

      PlainSwitchFunctionalityView pv = PlainSwitchFunctionalityView(p);
      json = pv.toJson();

      FunctionalityView fv4 = extendedFunctionalityViewFromJson(json);
      expect(fv4 is PlainSwitchFunctionalityView, true);
      expect(fv4.myFunctionality.id(), p.id());

      TeslaFunctionality t = TeslaFunctionality();
      allFunctionalities.addFunctionality(t);

      TeslaFunctionalityView tv = TeslaFunctionalityView(t);
      json = tv.toJson();

      FunctionalityView fv5 = extendedFunctionalityViewFromJson(json);
      expect(fv5 is TeslaFunctionalityView, true);
      expect(fv5.myFunctionality.id(), t.id());

      WeatherForecast w = WeatherForecast();
      allFunctionalities.addFunctionality(w);

      WeatherForecastView wv = WeatherForecastView(w);
      json = wv.toJson();

      FunctionalityView fv6 = extendedFunctionalityViewFromJson(json);
      expect(fv6 is WeatherForecastView, true);
      expect(fv6.myFunctionality.id(), w.id());

      ElectricityPrice ep = ElectricityPrice();
      allFunctionalities.addFunctionality(ep);

      ElectricityGridBlock e = ElectricityGridBlock(ep);
      json = e.toJson();

      FunctionalityView fv7 = extendedFunctionalityViewFromJson(json);
      expect(fv7 is ElectricityGridBlock, true);
      expect(fv7.myFunctionality.id(), ep.id());

    });

  });


  test('range', () {
  });

}
