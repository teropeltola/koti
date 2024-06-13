import 'package:flutter/material.dart';
import 'package:koti/view/my_drawer_view.dart';
import 'package:koti/operation_modes/view/operation_modes_selection_view.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../estate.dart';
import '../../look_and_feel.dart';
import 'edit_estate_view.dart';

class EstateView extends StatefulWidget {
  final Function callback;
  const EstateView({Key? key, required this.callback}) : super(key: key);

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

  void refresh() {

  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
              appBar: AppBar(title: appTitle(myEstates.currentEstate().name), actions: [
                myEstates.currentEstate().myWifiIsActive
                    ? const Icon(Icons.wifi, color: Colors.green)
                    : const Icon(Icons.wifi_off, color: Colors.red)
              ]),
              drawer: Drawer(child: myDrawerView(context, () {widget.callback();})),
              body: Column(children: [
                OperationModesSelectionView(
                  operationModes: myEstates.currentEstate().operationModes,
                  topHierarchy: true,
                  callback: () {setState(() {}); }
                ),
                Container(
                    height: 300,
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      padding: const EdgeInsets.all(4.0),
                      children: _getGridViewItems(context, myEstates.currentEstate()),
                    )
                )
              ]
              ),
              bottomNavigationBar: Container(
                height: bottomNavigatorHeight,
                alignment: AlignmentDirectional.topCenter,
                color: myPrimaryColor,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                          icon: const Icon(
                              Icons.edit,
                              color: myPrimaryFontColor,
                              size: 40),
                          tooltip: 'muokkaa näytön tietoja',
                          onPressed: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return EditEstateView(
                                        estateName: myEstates.currentEstate().name
                                    );
                                  },
                                )
                            );
                            setState(() {});
                          }
                      ),
                    ]),
              )
          );
  }
}

Widget _estateFunctionalityView(Color color, Widget widget) {
  return Container(color: color, child: widget);
}

