import 'package:flutter/material.dart';

import '../../../devices/device/view/short_device_view.dart';
import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../heating_system.dart';

class EditHeatingSystemView extends StatefulWidget {
  String estateName;
  HeatingSystem heatingSystem;
  EditHeatingSystemView({Key? key, required this.estateName, required this.heatingSystem}) : super(key: key);

  @override
  _EditHeatingSystemViewState createState() => _EditHeatingSystemViewState();
}

class _EditHeatingSystemViewState extends State<EditHeatingSystemView> {
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
                  Navigator.of(context).pop();
                }
              }),
          title: appIconAndTitle(widget.estateName, HeatingSystem.functionalityName),
        ), // new line
        body: SingleChildScrollView(
        child: Column(children: <Widget>[
          devicesGrid(
              context,
              'liitetyt laitteet',
              Colors.blue,
              myEstates.estate(widget.estateName),
              widget.heatingSystem.connectedDevices,
              () {}
          ),
          Container(
            margin: myContainerMargin,
            padding: myContainerPadding,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Toimintovalinnat'),
                child: Column(children: <Widget>[
                  Text('laadidaa')
                ]
                )
            )
          )
    ]
    )
    )
    );

  }
}
