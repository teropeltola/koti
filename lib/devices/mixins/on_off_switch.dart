import '../../estate/estate.dart';
import '../../logic/state_broker.dart';
import '../../service_catalog.dart';
import '../../trend/trend.dart';
import '../../trend/trend_switch.dart';
import '../../logic/services.dart';
import '../device/device.dart';

mixin OnOffSwitch {

  late TrendBox<TrendSwitch> trendBox;

  late OnOffSwitchService onOffService;

  Future <void> initSwitch(
      { required Estate myEstate,
        required Device device,
        required String boxName,
        required Future<void> Function (bool, String) setFunction,
        required Future<bool> Function() getFunction,
        required bool Function() peekFunction,
        required Future<bool> Function(Map<String, dynamic> ) defineTask}
  ) async {

    await trend.initBox<TrendSwitch>(boxName);
    trendBox = trend.open(boxName);

    onOffService = OnOffSwitchService(setFunction, getFunction, peekFunction, defineTask, trendBox);

    myEstate.stateBroker.initNotifyingBoolStateInformer(
        device: device,
        serviceName: powerOnOffStatusService,
        stateBoolNotifier: onOffService.switchOn,
        dataReadingFunction: peekFunction);

    onOffService.switchOn.data = await getFunction();
  }

  DeviceServiceClass<OnOffSwitchService> onOffServiceDefinition() {
    return DeviceServiceClass<OnOffSwitchService>(serviceName: powerOnOffWaitingService, services: onOffService);
  }
}


class OnOffSwitchService {

  StateBoolNotifier switchOn = StateBoolNotifier(false);

  late final Future<void> Function(bool, String) _setOnOff;
  late final Future<bool> Function() _getOnOff;
  late final bool Function() _peekOnOff;
  late final Future<bool> Function(Map<String, dynamic>) _defineTask;
  late final TrendBox<TrendSwitch> _trendBox;

  OnOffSwitchService(this._setOnOff, this._getOnOff, this._peekOnOff, this._defineTask, this._trendBox);

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

  Future<bool> defineTask(Map<String, dynamic> parameters) async {
    return await _defineTask(parameters);
  }
}


