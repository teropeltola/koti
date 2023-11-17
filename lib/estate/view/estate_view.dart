import 'package:flutter/material.dart';
import 'package:koti/devices/wlan/active_wifi_name.dart';
import 'package:koti/view/my_drawer_view.dart';
import 'package:provider/provider.dart';

import '../estate.dart';
import '../../look_and_feel.dart';

class EstateView extends StatefulWidget {
  final Estate estate;
  const EstateView({Key? key, required this.estate}) : super(key: key);

  @override
  _EstateViewState createState() => _EstateViewState();
}

class _EstateViewState extends State<EstateView> {

  List<Widget> myBlocks = [];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    _getGridViewItems(context);
  }

  List<Widget> _getGridViewItems(BuildContext context){
    List<Widget> allWidgets = [];
    for (int i = 0; i < widget.estate.views.length; i++) {
      allWidgets.add(widget.estate.views[i].gridBlock(context, (){setState(() {});}));
    }
    return allWidgets;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveWifiName>(
        builder: (context, myActiveWifi, childNotUsed) {
          return Scaffold(
              appBar: AppBar(
                title:  appTitle(widget.estate.name),
                actions: [
                  widget.estate.isMyWifi(myActiveWifi.activeWifiName)
                  ? const Icon(Icons.wifi,color: Colors.green)
                  : const Icon(Icons.wifi_off, color: Colors.red)
                ]
              ),
              drawer: Drawer(
                child: myDrawerView(context, (){})
              ),
              body: //SingleChildScrollView(
                  //child:
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    padding: const EdgeInsets.all(4.0),
                    children: _getGridViewItems(context),
                  )

          );
        }
    );
  }
}

Widget _estateFunctionalityView(Color color, Widget widget) {
  return Container(
    color: color,
    child: widget
  );
}

