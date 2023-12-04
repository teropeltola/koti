import 'package:koti/functionalities/tesla_functionality/view/tesla_functionality_view.dart';

import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class TeslaFunctionality extends Functionality {

  void init () async {
  }

  bool status() {
    return false;
  }

  void setCharging() {
  }

  @override
  FunctionalityView myView() {
    return TeslaFunctionalityView(this);
  }

}