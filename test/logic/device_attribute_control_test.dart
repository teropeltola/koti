import 'package:flutter_test/flutter_test.dart';
import 'package:koti/logic/device_attribute_control.dart';

void main() {
  group('ControlledDevice tests ', () {
    test('Basic functionality', () {
      ControlledDevice c = ControlledDevice();
      c.initStructure(
        deviceId: 'deviceId',
        deviceAttributes: [DeviceAttributeCapability.directControl],
        setFunction: _mySetFunction,
        getFunction: _myGetFunction
      );

      expect(c.valuesOn({}), true);
      expect(c.valuesOn({'a': 'b'}), false);

      c.setDirectValue({'c': 'd'});
      expect(c.valuesOn({}), true);
      expect(c.valuesOn({'a': 'b'}), false);
      expect(c.valuesOn({'c': 'd'}), true);
      expect(myPars['c'],'d');

      _mySetFunction({}); // reset remote value
      c.setDirectValue({'c': 'd'});
      expect(myPars.isEmpty,true);
    });
  });
}

Map<String, dynamic> _myGetFunction() {
  return myPars;
}

void _mySetFunction(Map<String, dynamic> newParameters) {
  myPars = newParameters;
}

Map <String, dynamic> myPars = {};