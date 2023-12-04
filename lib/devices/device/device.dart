
import 'package:koti/functionalities/functionality/functionality.dart';

import '../../estate/estate.dart';
import '../../logic/state.dart';

class Device {
  String name = '';
  String id = '';
  State state = State();
  Functionality functionality = Functionality();
  Estate myEstate = Estate();

  String detailsDescription() {
    return '';
  }

  Device clone() {
    Device newDevice = Device();
    newDevice.name = name;
    newDevice.id = id;
    newDevice.state = state;
    newDevice.functionality = functionality;
    newDevice.myEstate = myEstate;
    return newDevice;
  }
}