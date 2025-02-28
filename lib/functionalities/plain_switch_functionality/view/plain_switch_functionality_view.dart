
import 'package:flutter/material.dart';

import '../../../devices/device/device.dart';
import '../../../look_and_feel.dart';
import '../../../trend/trend_switch.dart';
import '../../functionality/view/functionality_view.dart';
import '../plain_switch_functionality.dart';

class PlainSwitchFunctionalityView extends FunctionalityView {

  @override
  String viewName() {
    return PlainSwitchFunctionality.functionalityName;
  }

  @override
  String subtitle() {
    return mySwitch().myDevice().name;
  }

  PlainSwitchFunctionality mySwitch() {
    return myFunctionality() as PlainSwitchFunctionality;
  }

  PlainSwitchFunctionalityView();

  PlainSwitchFunctionalityView.fromJson(Map<String, dynamic> json);


  @override
  Widget gridBlock(BuildContext context, Function callback) {

    return ElevatedButton(
        style: mySwitch().switchStatusPeek()
          ? buttonStyle(Colors.green, Colors.white)
          : buttonStyle(Colors.grey, Colors.white),
        onPressed: () async {
          await mySwitch().toggle();
          callback();
        },
        onLongPress: () async {
          await _switchStatistics(context, mySwitch(), 0);

        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          Text(
          mySwitch().myDevice().name,
          style: const TextStyle(
          fontSize: 12)),
          Icon(
            mySwitch().switchStatusPeek()
            ? Icons.power
            : Icons.power_off,
            size: 50,
            color:
              mySwitch().switchStatusPeek()
                ? Colors.yellowAccent
                : Colors.white,

          )
            ])
    );
  }
}

Future <void> _switchStatistics(BuildContext context, PlainSwitchFunctionality mySwitch, int switchNumber) async {
  Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            SwitchTrendView(
              switchFunctionality: mySwitch,
            ),
      )
  );

}

class SwitchTrendView extends StatefulWidget {
  final PlainSwitchFunctionality switchFunctionality;
  const SwitchTrendView({required this.switchFunctionality, Key? key}) : super(key: key);

  @override
  State<SwitchTrendView> createState() => _SwitchTrendViewState();
}

class _SwitchTrendViewState extends State<SwitchTrendView> {

  List<TrendSwitch> switchTrend = [];
  late Device deviceWithSwitchFunctionality;
  String deviceName = '';

  @override
  void initState() {
    super.initState();
    deviceWithSwitchFunctionality = widget.switchFunctionality.myDevice();
    deviceName = deviceWithSwitchFunctionality.name;
    switchTrend = widget.switchFunctionality.mySwitchDeviceService.services.trendBox().getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: appIconAndTitle(deviceName,'tapahtumat'),
            backgroundColor: myPrimaryColor,
            iconTheme: const IconThemeData(color:myPrimaryFontColor)
        ),// new line
        body: SingleChildScrollView( child: Column(children: <Widget>[
          for (int index=switchTrend.length-1; index>=0; index--)
            switchTrend[index].showInLine(),
        ]
        )
        ),

        bottomNavigationBar: Container(
          height: bottomNavigatorHeight,
          alignment: AlignmentDirectional.topCenter,
          color: myPrimaryColor,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                    icon: const Icon(Icons.share,
                        color:myPrimaryFontColor,
                        size:40),
                    tooltip: 'jaa näyttö somessa',
                    onPressed: () async {
                    }
                ),
              ]),

        )
    );
  }
}

