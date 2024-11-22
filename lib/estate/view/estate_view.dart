import 'package:flutter/material.dart';

import 'package:koti/view/my_drawer_view.dart';
import 'package:koti/operation_modes/view/operation_modes_selection_view.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../app_configurator.dart';
import '../../devices/device/device.dart';
import '../../functionalities/functionality/functionality.dart';
import '../../logic/diagnostics.dart';
import '../estate.dart';
import '../../look_and_feel.dart';
import 'edit_estate_view.dart';

// global variable that is used to do diagnostics as long as it finds problems
// (after finding errors this varible is turned off
bool doDiagnostics = true;
Diagnostics diagnostics = Diagnostics(myEstates, allDevices, allFunctionalities, applicationDeviceConfigurator);


class EstateView extends StatefulWidget {
  final int estateIndex;
  final Function callback;
  const EstateView({Key? key, required this.estateIndex, required this.callback}) : super(key: key);

  @override
  _EstateViewState createState() => _EstateViewState();
}

class _EstateViewState extends State<EstateView> {

  late Estate currentEstate;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  List<Widget> _getGridViewItems(BuildContext context, Estate estate) {
    List<Widget> allWidgets = [];
    for (var view in estate.views) {
      allWidgets.add(view.gridBlock(context, () {
        setState(() {});
      }));
    }
    return allWidgets;
  }

  void refresh() {
    currentEstate = myEstates.estates[widget.estateIndex];
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (doDiagnostics) {
      bool allGood = diagnostics.diagnosticsOk();
      if (!allGood) {
        diagnostics.diagnosticsLog.dumpDiagnosticsLogsToErrorLog();
        log.error('Autodiagnostiikka havaitsi sisäisen virheen, joka syntyi äskeisessä toiminnassa');
        doDiagnostics = false;
        return TalkerScreen(
          appBarLeading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Palaa takaisin',
              onPressed: () async {
                // check if the user wants to cancel all the changes
                bool doExit = await askUserGuidance(context,
                    'Poistuttaessa autodiagnostiikka ei ole enää käytössä.',
                    'Haluatko poistua lokinäytöltä?'
                );
                if (doExit) {
                  setState(() {});
                }
              }),
          talker: log,
          theme: const TalkerScreenTheme(
              backgroundColor: Colors.white,
              textColor: Colors.blue,
              cardColor: Colors.white
          ),
          appBarTitle: 'Loki',
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: appIconAndTitle(currentEstate.name, ''), actions: [
        currentEstate.reactiveWifiIsActive(context)
          ? const Icon(Icons.wifi, color: Colors.green)
          : const Icon(Icons.wifi_off, color: Colors.red)
        ]),
      drawer: Drawer(child: myDrawerView(context, () {widget.callback();})),
      body: SingleChildScrollView(
        child: Column(children: [
                OperationModesSelectionView(
                  operationModes: currentEstate.operationModes,
                  topHierarchy: true,
                  callback: () {setState(() {}); }
                ),
                Container(
                    height: 400,
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      padding: const EdgeInsets.all(4.0),
                      children: _getGridViewItems(context, currentEstate),
                    )
                )
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
                                        estateName: currentEstate.name
                                    );
                                  },
                                )
                            );
                            setState(() {});
                          }
                      ),
                      IconButton(
                          icon: const Icon(
                              Icons.delete_forever,
                              color: myPrimaryFontColor,
                              size: 40),
                          tooltip: 'tuhoa asunnon tiedot apista',
                          onPressed: () async {
                            bool doDestroy = await askUserGuidance(context,
                                'Tämä komento tuhoaa kaikki asunnon tiedot eikä sitä voi perua.',
                                'Oletko varma, että haluat tuhota asunnon tiedot?');
                            if (doDestroy) {
                              myEstates.removeEstate(currentEstate.id);
                              await myEstates.store();
                            }
                            widget.callback();
                          }
                      ),

                    ]),
              )
          );
  }
}

