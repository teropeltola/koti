import 'package:flutter/material.dart';
import 'package:koti/view/set_timer_task.dart';
import 'package:provider/provider.dart';

import '../estate/environment.dart';
import '../estate/estate.dart';
import '../interfaces/foreground_interface.dart';
import '../look_and_feel.dart';
import 'my_icon_button_widget.dart';

class TaskControllerView extends StatefulWidget {
  final Environment environment;
  final Function callback;
  const TaskControllerView({Key? key, required this.environment, required this.callback}) : super(key: key);

  @override
  _TaskControllerViewState createState() => _TaskControllerViewState();
}

class _TaskControllerViewState extends State<TaskControllerView> {

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: appIconAndTitle(currentEstate.name, 'tehtävät'), actions: [
        currentEstate.reactiveWifiIsActive(context)
          ? const Icon(Icons.wifi, color: Colors.green)
          : const Icon(Icons.wifi_off, color: Colors.red)
      ]),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Container(
            margin: myContainerMargin,
            padding: myContainerPadding,
            child:
            InputDecorator(
              decoration: const InputDecoration(
                  labelText: 'Lisää uusi tehtävä'), //k
              child:
              Row(children: <Widget>[
                Expanded(
                  flex: 1,
                  child: myIconButtonWidget(
                      Icons.timer,
                      'Lisää tehtävä',
                      'Lisää kellonaikaan tai sähkön hintaan liittyvä tehtävä',
                          () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const SetTimerTask(
                                    );
                                  },
                                )
                            );
                            refresh();
                      }
                  ),
                ),
              ]
              ),
            ),
          ),
          _TaskListWidget(widget.callback),
          /* EI VIELÄ TOTEUTETTU
          Container(
            margin: myContainerMargin,
            padding: myContainerPadding,
            child:
            InputDecorator(
              decoration: const InputDecoration(
                  labelText: 'Vanhoja tehtäviä'), //k
              child: Column(children: <Widget>[
                Text('lista tehtävistä, jotka eivät ole käytössä')
              ]
              ),
            ),

          )

           */

        ]
      ),
    )
    );
  }
}


class _TaskListWidget extends StatelessWidget {
  final Function callback;

  _TaskListWidget( this.callback);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: foregroundInterface.foregroundTasksNotifier,
      child: Consumer<ForegroundTasksNotifier>(
        builder: (context, notifier, child) {
          return Container(
              margin: myContainerMargin,
              padding: myContainerPadding,
              child:
              InputDecorator(
                  decoration:
                  const InputDecoration(
                      labelText: 'Nykyiset tehtävät'), //k
                  child:
                  (notifier.data.noTasks())
                      ? const Text('Ei ole asetettuja tehtäviä')
                      : ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: notifier.data.nbrOfTasks(),
                      itemBuilder: (context, index) => Card(
                          elevation: 6,
                          margin: const EdgeInsets.all(2),
                          child: ListTile(
                              contentPadding: EdgeInsets.fromLTRB(10,0,0,0),
                              leading: Icon(notifier.data.taskIcon(index)),
                              title: Text(notifier.data.taskTitle(index)),
                              subtitle: Text( notifier.data.taskDescription(index)),
                              trailing:
                              Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        icon: const Icon(Icons.edit),
                                        tooltip: 'muokkaa tehtävää',
                                        onPressed: () async {
                                        }),
                                    IconButton(
                                        icon: const Icon(Icons.delete),
                                        tooltip: 'poista tehtävä',
                                        onPressed: () async {
                                        }),
                                  ])
                          )
                      )
                  )
              )
          );
        },
      ),
    );
  }
}

