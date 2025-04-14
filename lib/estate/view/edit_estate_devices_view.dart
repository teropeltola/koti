import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:koti/devices/shelly_blu_trv/shelly_blu_trv.dart';

import '../../app_configurator.dart';
import '../../devices/device/device.dart';
import '../../devices/device/view/short_device_view.dart';
import '../../devices/shelly/shelly_scan.dart';
import '../../devices/shelly_blu_gw/shelly_blu_gw.dart';
import '../../service_catalog.dart';
import '../../view/ready_widget.dart';
import '../estate.dart';
import '../../look_and_feel.dart';

class _DevicePrototypes {
  List <Device> protypeList = [];

  List <String> currentShellyServices = [];

  List <Device> shellyBluConnectedDevices = [];

  void init(Estate editedEstate) {
    refresh(editedEstate);
  }

  Future<void> refresh(Estate editedEstate) async {
    remove();
    protypeList.addAll(_findPossibleDevices(editedEstate));
    scanPossibleShellyServices(editedEstate);
    await addShellyBluConnectedDevices(editedEstate);
  }

  void remove() {
    for (var device in protypeList) {
      device.remove();
    }
    protypeList.clear();
    currentShellyServices.clear();
    shellyBluConnectedDevices.clear();
  }

  void removeFromList(List <String> removedNames) {
    for (var device in protypeList) {
      if (removedNames.contains(device.id)) {
        protypeList.remove(device);
        device.remove();
      }
    }

  }

  // check estate connected Shelly Blu gateways and add to the possible list the connected blu devices
  // that are not yet in use.
  Future<void> addShellyBluConnectedDevices(Estate estate) async {
    shellyBluConnectedDevices.clear();

    for (var d in estate.devices) {
      if (d is ShellyBluGw) {
        ShellyBluGw gw = d;
        await gw.updateConnectedDevices();
        for (var connectedDevice in gw.bluTrvStatusList) {
          String deviceId = connectedDevice.deviceId();
          if (! estate.deviceExists(deviceId)) {
            shellyBluConnectedDevices.add(ShellyBluTrv(deviceId, gw.id, connectedDevice.status.id));
          }
        }
      }
    }

    protypeList.addAll(shellyBluConnectedDevices);
  }

  void scanPossibleShellyServices(Estate editedEstate) {

    List <String> newShellyServices = shellyScan.listPossibleServices();

    // remove shelly services that are already installed
    for (int index = newShellyServices.length-1; index >= 0; index--) {
      if (editedEstate.deviceExists(newShellyServices[index])) {
        newShellyServices.removeAt(index);
      }
    }

    if (! listEquals(newShellyServices, currentShellyServices)) {

      removeFromList(currentShellyServices);

      for (var shellyName in newShellyServices) {
        Device shellyDevice = deviceFromTypeName(
            findShellyTypeName(shellyName));
        shellyDevice.id = shellyName;
        protypeList.add(shellyDevice);
      }
    }
  }


  List <Device> _findPossibleDevices(Estate estate) {
    List <Device> devices = applicationDeviceConfigurator.getDevicesWithAttribute(deviceWithManualCreation);

    // remove existing devices that are not allowed to be several times
    for (int index = devices.length-1; index>=0; index--) {
      var device = devices[index];
      if (! device.isReusableForFunctionalities()) {
        if (estate.hasDeviceOfType(devices[index].runtimeType)) {
          devices.removeAt(index);
          device.remove();
        }
      }
    }
    return devices;
  }
}

class EditEstateDevicesView extends StatefulWidget {
  final Estate candidateEstate;
  const EditEstateDevicesView({Key? key, required this.candidateEstate}) : super(key: key);

  @override
  _EditEstateDevicesViewState createState() => _EditEstateDevicesViewState();
}

class _EditEstateDevicesViewState extends State<EditEstateDevicesView> {

  _DevicePrototypes foundDevices = _DevicePrototypes();

  late Future<bool> devicesInitiated;

  @override
  void initState() {
    super.initState();

    if (_createNewEstate()) {
      devicesInitiated = Future.value(true);
    }
    else {
      devicesInitiated = deviceInitializationDone();
    }
    refresh();
  }

  Future<bool> deviceInitializationDone() async {
    await foundDevices.refresh(widget.candidateEstate);
    return true;
  }


  void refresh() async {
    await foundDevices.refresh(widget.candidateEstate);
    setState(() { });
  }

  void _removeTemporaryDevicePrototypes() {
    foundDevices.remove();
  }

  bool _createNewEstate() {
    return widget.candidateEstate.name == '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Palaa takaisin tallentamatta muutoksia',
              onPressed: () async {
                // check if the user wants to cancel all the changes
                bool doExit = await askUserGuidance(context,
                    'Poistuttaessa muutokset eivät säily.',
                    'Haluatko poistua muutossivulta ?'
                );
                if (doExit) {
                  _removeTemporaryDevicePrototypes();
                  Navigator.of(context).pop();
                }
              }),
          title: appIconAndTitle(widget.candidateEstate.name, 'laitteet'),
        ), // new line
        body:
        SingleChildScrollView(
            child: Column(children: <Widget>[
              DeviceEditingWidget(
                  devicesInitiated: devicesInitiated,
                  estate: widget.candidateEstate,
                  prototypeDevices: foundDevices.protypeList,
                  callback: refresh
              ),
              readyWidget(() async {
                    _removeTemporaryDevicePrototypes();
                    Navigator.pop(context, true);
              })
            ])
        )
    );
  }
}

class DeviceEditingWidget extends StatefulWidget {
  final Future<bool> devicesInitiated;
  final Estate estate;
  final List<Device> prototypeDevices;
  final Function callback;
  const DeviceEditingWidget(
      {super.key, required this.devicesInitiated, required this.estate,
        required this.prototypeDevices, required this.callback});

  @override
  State<DeviceEditingWidget> createState() => _DeviceEditingWidgetState();
}

class _DeviceEditingWidgetState extends State<DeviceEditingWidget> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: widget.devicesInitiated, // a previously-obtained Future<bool> or null
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        List<Widget> children = [];
        if (snapshot.hasData) {
          return Container(
              margin: myContainerMargin,
              padding: myContainerPadding,
              child: /* InputDecorator(
                    decoration: const InputDecoration(labelText: 'laitteet'),
                    child:

                 */
              Column(
                // mainAxisSize: MainAxisSize.min,
                  children: [
                    devicesGrid(
                        context,
                        'käytössä olevat laitteet',
                        Colors.blue,
                        widget.estate,
                        widget.estate.devices,
                        widget.callback
                    ),
                    devicesGrid(
                        context,
                        'lisää uusia laitteita:',
                        Colors.lightBlue,
                        widget.estate,
                        widget.prototypeDevices,
                        widget.callback
                    ),
                  ]
              )
          );
        } else if (snapshot.hasError) {
          children = <Widget>[
            const Icon(
              Icons.error_outline,
              color: myPrimaryFontColor,
              size: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Hups, emme saa nyt yhteyttä verkkoon!'),
            ),
          ];
        } else {
          children = const <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Pieni hetki, tietoa haetaan laitteilta...\n'),
            ),
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),

          ];
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        );

      },
    );
  }
}
