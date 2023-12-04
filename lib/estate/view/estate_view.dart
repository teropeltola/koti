import 'package:flutter/material.dart';
import 'package:koti/devices/wlan/active_wifi_name.dart';
import 'package:koti/view/my_drawer_view.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../estate.dart';
import '../../look_and_feel.dart';

class EstateView extends StatefulWidget {
  const EstateView({Key? key}) : super(key: key);

  @override
  _EstateViewState createState() => _EstateViewState();
}

class _EstateViewState extends State<EstateView> {
  List<Widget> myBlocks = [];

  @override
  void initState() {
    super.initState();
  }


  List<Widget> _getGridViewItems(BuildContext context, Estate estate) {
    List<Widget> allWidgets = [];
    for (int i = 0; i < estate.views.length; i++) {
      allWidgets.add(estate.views[i].gridBlock(context, () {
        setState(() {});
      }));
    }
    return allWidgets;
  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Estate>(
        create: (context) => myEstates.currentEstate(),
        child: Consumer<Estate>(builder: (context, estate, childNotUsed) {
          return Scaffold(
              appBar: AppBar(title: appTitle(estate.name), actions: [
                estate.isMyWifi(activeWifiName.activeWifiName)
                    ? const Icon(Icons.wifi, color: Colors.green)
                    : const Icon(Icons.wifi_off, color: Colors.red)
              ]),
              drawer: Drawer(child: myDrawerView(context, () {})),
              body: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                padding: const EdgeInsets.all(4.0),
                children: _getGridViewItems(context, estate),
              ));
        }));
  }
}

Widget _estateFunctionalityView(Color color, Widget widget) {
  return Container(color: color, child: widget);
}
