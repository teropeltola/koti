// diagnostics checks the consistency of the data and reports anomalies
// to the error.log.


import 'package:koti/functionalities/functionality/functionality.dart';

import '../app_configurator.dart';
import '../devices/device/device.dart';
import '../estate/environment.dart';
import '../estate/estate.dart';
import '../look_and_feel.dart';

class LogLines {
  List<String> lines = [];
  LogLines(this.lines);

  void dumpLog() {
    for (var line in lines) {
      log.error(line);
    }
  }
}

class DiagnosticsLog {
  List <LogLines> diagnosticsLog = [];

  bool noErrorsFound() {
    return diagnosticsLog.isEmpty;
  }

  int nbrOfLogs() {
    return diagnosticsLog.length;
  }

  void clearLog() {
    diagnosticsLog.clear();
  }

  String lastDiagnosticLogTitle() {
    if (diagnosticsLog.isNotEmpty) {
      return diagnosticsLog[diagnosticsLog.length - 1].lines[0];
    }
    else {
      return '';
    }
  }

  void add(List<String> newLog ) {
    diagnosticsLog.add(LogLines(newLog));
  }

  void dumpDiagnosticsLogsToErrorLog() {
    for (var logItem in diagnosticsLog) {
      logItem.dumpLog();
    }
  }
}

class Diagnostics {

  final Estates _myEstates;
  final DeviceList _allDevices;
  final FunctionalityList _allFunctionalities;
  final ApplicationDeviceTypes _applicationDeviceConfigurator;


  DiagnosticsLog diagnosticsLog = DiagnosticsLog();

  Diagnostics(this._myEstates, this._allDevices, this._allFunctionalities, this._applicationDeviceConfigurator);

  bool diagnosticsOk() {
    diagnosticsLog.clearLog();
    bool success = true;

    for (var estate in _myEstates.estates) {
      success = success && diagnoseEstate(estate);
    }

    if (foundOrphanDevices()) {
      success = false;
    }

    return success;
  }

  bool foundOrphanDevices() {
    List<bool> deviceInUse = List.filled(_allDevices.list.length, false);
    bool problemsFound = false;

    for (var e in _myEstates.estates) {
      for (var d in e.devices) {
        int index = _allDevices.list.indexOf(d);
        if (index >= 0) {
          if (deviceInUse[index]) {
            diagnosticsLog.add(['Device ${d.name}/${d.id} of estate ${e.name} has double id']);
            problemsFound = true;
          }
          deviceInUse[index] = true;
        }
        else {
          diagnosticsLog.add(['Device ${d.name}/${d.id} of estate ${e.name} is missing from allDevices']);
          problemsFound = true;
        }
      }
    }

    for (var e in _applicationDeviceConfigurator.typeList) {
      int index = _allDevices.list.indexOf(e.devicePrototype);
      if (index >= 0) {
        if (deviceInUse[index]) {
          diagnosticsLog.add(['Device prototype ${e.runtimeTypeName} has double use']);
          problemsFound = true;
        }
        deviceInUse[index] = true;
      }
      else {
        diagnosticsLog.add(['Device prototype  ${e.runtimeTypeName} is missing from allDevices']);
        problemsFound = true;
      }

    }

    for (int index=0; index<deviceInUse.length; index++) {
      if (! deviceInUse[index]) {
        diagnosticsLog.add(['Device ${_allDevices.list[index].name}/'
            '${_allDevices.list[index].id}/'
            '${_allDevices.list[index].runtimeType.toString()}/'
            '$index is orphan in allDevices']);
        problemsFound = true;

      }
    }

    return problemsFound;
  }

  bool diagnoseEstate(Estate estate) {
    bool success = true;
    if (_nameNotCorrect(estate.name)) {
      diagnosticsLog.add(['Estate name "${estate.name}" not correct']);
      success = false;
    }
    success = success && _checkWifi(estate);

    for (var device in estate.devices) {
      success = success && diagnoseDevice(estate, device);
    }
    return success;
  }

  bool diagnoseDevice(Estate estate, Device device) {
    bool success = true;
    if (_nameNotCorrect(device.name)) {
      diagnosticsLog.add(
          ['Device name "${device.name}" not correct in "${estate.name}"']);
      success = false;
    }
    if (device.isNotOk()) {
      diagnosticsLog.add(
          ['Device name "${device.name}" is failed in "${estate.name}"']);
      success = false;
    }
    if (! _allDevices.list.contains(device)) {
      diagnosticsLog.add(
          ['Device name "${device.name}" in "${estate.name}" is not in allDevices']);
      success = false;
    }

    if (device.myEstateId != estate.id) {
      diagnosticsLog.add(
          ['Device "${device.name}" estate id is not valid in "${estate.name}"']);
      success = false;
    }

    for (var connectedFunctionality in device.connectedFunctionalities) {
      if (estate.findEnvironmentFor(connectedFunctionality) == noEnvironment) {
        diagnosticsLog.add(
            ['Connected functionality "${connectedFunctionality.id} of device "${device.name}" in "${estate.name}" not in estate feature list']);
        success = false;
      }
      if (! connectedFunctionality.connectedDevices.contains(device)) {
        diagnosticsLog.add(
            ['Connected functionality "${connectedFunctionality.id} of device "${device.name}" in "${estate.name}" has not connection to this device']);
        success = false;
      }
    }

    return success;
  }

  bool _checkWifi(Estate estate) {
    if (!estate.devices.contains(estate.myWifiDevice())) {
      diagnosticsLog.add(['Estate "${estate.name}" wifi is not in estate devices']);
      return false;
    }
    return true;
  }

}


bool _nameNotCorrect(String name) {
  return name.isEmpty;
}