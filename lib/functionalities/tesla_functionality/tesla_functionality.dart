import 'package:koti/functionalities/tesla_functionality/view/tesla_functionality_view.dart';

import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class TeslaFunctionality extends Functionality {

  TeslaFunctionality();

  @override
  Future<void> init () async {
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

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  TeslaFunctionality.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
  }


}