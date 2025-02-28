import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/my_device_info.dart';
import 'package:koti/functionalities/electricity_price/view/electricity_price_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:koti/functionalities/electricity_price/electricity_price.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  group('ElectricityPriceView test', () {
    test('basics', () {
      ElectricityPrice e = ElectricityPrice();
      ElectricityGridBlock eGB = e.myView as ElectricityGridBlock;
      expect(e.myView.runtimeType,ElectricityGridBlock);
      expect(eGB.myFunctionality().runtimeType, ElectricityPrice);
    });

    test('structure evaluation', () {
       F f1 = F();
      F2 f2 = F2();
      expect(f2.myView.myF, f2);
    });
  });
}

class F {
  late FV myView;

  F() {
    myView = FV();
    myView.set(this);
  }
}
class F2 extends F{
  F2(){
    myView = FV2();
    myView.set(this);
  }

}

F nf = F();

F x() {
  return nf;
}
class FV {
  late F myF;

  set(F f) {
    myF = f;
  }
}

class FV2 extends FV {
}