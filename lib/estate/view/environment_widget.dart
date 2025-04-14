import 'package:flutter/material.dart';

import '../../operation_modes/view/operation_modes_selection_view.dart';
import '../environment.dart';
import 'environment_view.dart';

const int _crossAxicCount = 3;

ButtonStyle _buttonStyle (Color backgroundColor, Color foregroundColor) {
  return   ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: const EdgeInsets.all(2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      )
  );
}
double _gridBlockHeight(int nbrOfItems) {
  return 120.0 * ((2 +nbrOfItems) / _crossAxicCount).floor();
}

List<Widget> _getFunctionalityViewItems(BuildContext context, Environment environment, Function callback) {
  List<Widget> allWidgets = [];
  for (var view in environment.views) {
    allWidgets.add(view.gridBlock(context, callback));
  }
  return allWidgets;
}

List<Widget> _getSubenvironmentItems(BuildContext context, Environment enviroment, Function callback) {
  List<Widget> allWidgets = [];
  for (var subEnvironment in enviroment.environments) {
    allWidgets.add(_gridEnvironmentButton(context, subEnvironment, callback));
  }
  return allWidgets;
}

List<Widget> _getAllItems(BuildContext context, Environment enviroment, Function callback) {
  List<Widget> allWidgets = _getFunctionalityViewItems(context, enviroment, callback);
  allWidgets.addAll(_getSubenvironmentItems(context, enviroment, callback));
  return allWidgets;
}

Widget _gridEnvironmentButton(BuildContext context, Environment environment, Function callback) {
  return ElevatedButton(
      style:_buttonStyle(Colors.green, Colors.white),
      onPressed: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return EnvironmentView(
                  environment: environment,
                  callback: callback,
                );
              },
            )
        );
        //bool status = await .editWidget(context, estate);
        callback();
      },
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit:FlexFit.loose,
              child:
              Text(environment.name,
                  style: const TextStyle(fontSize: 12)),
            ),
            Flexible(
              fit:FlexFit.loose,
              child:
              Icon(
                Icons.room_preferences,
                size: 18,
                color: Colors.white,
              ),
            ),
          ]
      )
  );
}

Widget enviromentWidget(BuildContext context, Environment environment, Function callback) {
  return Column(children: [
    OperationModesSelectionView(
        operationModes: environment.operationModes,
        topHierarchy: true,
        callback: callback
    ),
  SizedBox(
  height: 20000.0,
  child:
    GridView.count(
        crossAxisCount: _crossAxicCount,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            padding: const EdgeInsets.all(4.0),
            children: _getAllItems(context, environment, callback)
        )
    ),

  /*
    SizedBox(
        height: _gridBlockHeight(environment.views.length),
        child:
        GridView.count(
          crossAxisCount: _crossAxicCount,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          padding: const EdgeInsets.all(4.0),
          children: _getFunctionalityViewItems(context, environment, callback),
        )
    ),
    environment.nbrOfSubEnvironments() > 0
      ? Divider(color: Colors.blue, thickness: 4) : Divider(color: Colors.white, thickness: 4),
  SizedBox(
        height: _gridBlockHeight(environment.nbrOfSubEnvironments()),
        child:
        GridView.count(
          crossAxisCount: _crossAxicCount,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          padding: const EdgeInsets.all(4.0),
          children: _getSubenvironmentItems(context, environment, callback)
        )
    ),

     */
  ]
  );
}