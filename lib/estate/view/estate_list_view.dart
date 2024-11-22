import 'package:flutter/material.dart';

import '../../look_and_feel.dart';
import '../../view/my_drawer_view.dart';
import '../estate.dart';

class EstateListView extends StatefulWidget {
  const EstateListView({Key? key}) : super(key: key);

  @override
  _EstateListViewState createState() => _EstateListViewState();
}

class _EstateListViewState extends State<EstateListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: appIconAndTitle(appName, 'asunnot'), actions: [
                  ]),
        body: Column(children: <Widget>[
          for (var estate in myEstates.estates)
            Container(
              margin: myContainerMargin,
              padding: myContainerPadding,
              child: InputDecorator(
                decoration: InputDecoration(labelText: estate.name),
                textAlignVertical: TextAlignVertical.top,
                child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Text('hyödyllistä tietoa')
                    ]
                  )
                )
              )
          ]),

    );
  }
}
