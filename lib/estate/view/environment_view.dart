import 'package:flutter/material.dart';
import 'package:koti/estate/view/edit_environment_view.dart';
import 'package:provider/provider.dart';

import '../../devices/device/device_state.dart';
import '../../view/task_controller_view.dart';
import '../environment.dart';
import '../estate.dart';
import '../../look_and_feel.dart';
import 'environment_widget.dart';


class EnvironmentView extends StatefulWidget {
  final Environment environment;
  final Function callback;
  const EnvironmentView({Key? key, required this.environment, required this.callback}) : super(key: key);

  @override
  _EnvironmentViewState createState() => _EnvironmentViewState();
}

class _EnvironmentViewState extends State<EnvironmentView> {

  late Estate currentEstate;

  @override
  void initState() {
    super.initState();
    currentEstate = widget.environment.myEstate();

    refresh();
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: appIconAndTitle(currentEstate.name, widget.environment.name), actions: [
            Consumer<StateNotifier>(
              builder: (context, stateNotifier, child) {
                return stateNotifier.data == StateModel.connected // currentEstate.myWifiDevice().state.connected()
                  ? const Icon(Icons.wifi, color: Colors.green)
                  : const Icon(Icons.wifi_off, color: Colors.red);
              },
            )
        ]),
        //drawer: Drawer(child: myDrawerView(context, () {widget.callback();})),
        body: SingleChildScrollView(
          child: enviromentWidget(context, widget.environment, () {setState(() {});}),
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
                        Icons.more_time_rounded,
                        color: myPrimaryFontColor,
                        size: 40),
                    tooltip: 'aseta uusi tehtävä',
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return TaskControllerView(
                                  environment: widget.environment,
                                  callback: () {});
                            },
                          )
                      );
                      // local variables like currentEstate need to be updated
                      refresh();
                    }
                ),
                IconButton(
                    icon: const Icon(
                        Icons.edit,
                        color: myPrimaryFontColor,
                        size: 40),
                    tooltip: 'muokkaa näytön tietoja',
                    onPressed: () async {
                      bool storeResults = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EditEnvironmentView(environment: widget.environment,);
                            },
                          )
                      );
                      if (storeResults) {
                        await storeChanges();
                      }
                      // local variables like currentEstate need to be updated
                      refresh();
                    }
                ),
                IconButton(
                    icon: const Icon(
                        Icons.delete_forever,
                        color: myPrimaryFontColor,
                        size: 40),
                    tooltip: 'tuhoa huone/osa-alue tiedot apista',
                    onPressed: () async {
                      bool doDestroy = await askUserGuidance(context,
                          'Ei vielä toteutettu.',
                          'Paina nappia ja mene eteenpäin');
                      if (doDestroy) {
                      }
                      widget.callback();
                    }
                ),

              ]),
        )
    );
  }
}

