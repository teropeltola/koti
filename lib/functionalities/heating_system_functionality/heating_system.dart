
import 'package:koti/functionalities/heating_system_functionality/view/heating_system_view.dart';
import '../../devices/ouman/ouman_device.dart';
import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class HeatingSystem extends Functionality {

  HeatingSystem() {
  }

  late OumanDevice myOuman;

  void init (OumanDevice myOumanDevice) async {
    myOuman = myOumanDevice;
  }

  @override
  FunctionalityView myView() {
    return HeatingSystemView(this);
  }

}