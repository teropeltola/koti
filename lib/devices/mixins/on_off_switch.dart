import '../../estate/estate.dart';
import '../../logic/state_broker.dart';
import '../../service_catalog.dart';
import '../../trend/trend.dart';
import '../../trend/trend_switch.dart';
import '../../logic/services.dart';
import '../device/device.dart';

mixin OnOffSwitch {

  StateBoolNotifier switchOn = StateBoolNotifier(false);

  late TrendBox<TrendSwitch> trendBox;

  late OnOffSwitchService service;

  Future <void> initSwitch(
      { required Estate myEstate,
        required Device device,
        required String boxName,
        required Future<void> Function (bool, String) setFunction,
        required Future<bool> Function() getFunction,
        required bool Function() peekFunction}
  ) async {

    await trend.initBox<TrendSwitch>(boxName);
    trendBox = trend.open(boxName);

    service = OnOffSwitchService(setFunction, getFunction, peekFunction, trendBox);

    myEstate.stateBroker.initNotifyingBoolStateInformer(
        device: device,
        serviceName: powerOnOffStatusService,
        stateBoolNotifier: switchOn,
        dataReadingFunction: peekFunction);

    switchOn.data = await getFunction();
  }

  DeviceServiceClass<OnOffSwitchService> onOffServiceDefinition() {
    return DeviceServiceClass<OnOffSwitchService>(serviceName: powerOnOffWaitingService, services: service);
  }
}


class OnOffSwitchService {

  late final Future<void> Function(bool, String) _setOnOff;
  late final Future<bool> Function() _getOnOff;
  late final bool Function() _peekOnOff;
  late final TrendBox<TrendSwitch> _trendBox;

  OnOffSwitchService(this._setOnOff, this._getOnOff, this._peekOnOff, this._trendBox);

  Future <void> set(bool value, {String caller=''}) async {
    await _setOnOff(value, caller);
  }

  Future<bool> get() async {
    return await _getOnOff();
  }

  bool peek() {
    return _peekOnOff();
  }

  TrendBox<TrendSwitch> trendBox() {
    return _trendBox;
  }

}


