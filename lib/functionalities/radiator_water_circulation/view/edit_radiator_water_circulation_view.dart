import 'package:flutter/material.dart';

import '../../../devices/device/view/short_device_view.dart';
import '../../../devices/ouman/ouman_device.dart';
import '../../../estate/environment.dart';
import '../../../estate/estate.dart';
import '../../../logic/dropdown_content.dart';
import '../../../look_and_feel.dart';
import '../../../operation_modes/view/edit_operation_mode_view.dart';
import '../../../view/my_dropdown_widget.dart';
import '../../../view/ready_widget.dart';
import '../radiator_water_circulation.dart';

class EditRadiatorWaterCirculationView extends StatefulWidget {
  Environment environment;
  RadiatorWaterCirculation radiatorSystem;
  EditRadiatorWaterCirculationView({Key? key, required this.environment, required this.radiatorSystem}) : super(key: key);

  @override
  _EditRadiatorWaterCirculationViewState createState() => _EditRadiatorWaterCirculationViewState();
}

class _EditRadiatorWaterCirculationViewState extends State<EditRadiatorWaterCirculationView> {

  @override
  Widget build(BuildContext context) {
    Estate estate = widget.environment.myEstate();
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
                  Navigator.of(context).pop();
                }
              }),
          title: appIconAndTitle(widget.environment.name, RadiatorWaterCirculation.functionalityName),
        ), // new line
        body: SingleChildScrollView(
        child: Column(children: <Widget>[
          operationModeHandling(
            context,
            widget.environment,
            widget.radiatorSystem.operationModes,
            airPumpParameterSetting,
            () {setState(() {});}
          ),
          devicesGrid(context, 'liitetyt laitteet', Colors.blue, estate, widget.radiatorSystem.connectedDevices, (){}),
          Container(
            margin: myContainerMargin,
            padding: myContainerPadding,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Lisää uusi laite'),
                child: Column(children: <Widget>[
                  _categoryOfDevices(context, estate, widget.radiatorSystem, (){setState(() {});}),

                ]
                )
            )
          ),
          readyWidget(() async {
            String name = RadiatorWaterCirculation.functionalityName;
            log.info('${widget.environment.name}: $name luotu');
            showSnackbarMessage('Ouman-laitteen tietoja päivitetty!');
            Navigator.pop(context, true);
          }),
    ]
    )
    )
    );
  }
}

const List <String> _deviceCategories = ['', 'Ouman', 'lämpömittari'];

Widget _categoryOfDevices(BuildContext context, Estate estate, RadiatorWaterCirculation radiator, Function callback) {
  List<String> optionNames = _deviceCategories;

  DropdownContent dropDownContent = DropdownContent(optionNames, '', 0);
  return Row(
        children: [
          const Expanded(
              flex: 1,
              child: Text('Valitse laitetyyppi:')
          ),
          Expanded(
              flex: 1,
              child: MyDropdownWidget(
                keyString: 'radiatorDevices',
                  dropdownContent: dropDownContent,
                  setValue: (value) async {
                    if (_deviceCategories[value] == 'Ouman') {
                      OumanDevice ouman = await _getOuman(context, estate, radiator);
                      if (ouman.isOk()) {
                        radiator.pair(ouman);
                      }
                    }
                    dropDownContent.setIndex(0);
                    callback();
                  }
              )
          )
        ]
    );
}

Future<OumanDevice> _getOuman(BuildContext context, Estate estate, RadiatorWaterCirculation radiator) async {

  //check if I already have one
  int index = estate.devices.indexWhere((e){return e.runtimeType == OumanDevice;} );
  if (index >= 0) {
    return estate.devices[index] as OumanDevice;
  }
  else {
    bool success = await OumanDevice().editWidget(context, estate);
    if (success) {
      return await _getOuman(context, estate, radiator);
    }
    else {
      return OumanDevice.failed();
    }
  }
}

