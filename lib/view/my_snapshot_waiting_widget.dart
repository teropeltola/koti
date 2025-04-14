
import 'package:flutter/material.dart';

import '../look_and_feel.dart';

Widget MySnapshopWaitingWidget(BuildContext context, Widget appTitle, bool snapshotHasError) {
  List<Widget> children;
  if (snapshotHasError) {
    children = <Widget>[
      const Icon(
        Icons.error_outline,
        color: myPrimaryFontColor,
        size: 60,
      ),
      const Padding(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Text('Hups, emme saa nyt yhteyttä paikallisverkkoon!',
          style: TextStyle(
            color: myPrimaryFontColor,
            backgroundColor: Colors.white,
            fontSize: 24,
          )
        ),
      ),
    ];
  } else {
    children = [Container(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
            children: [
            Text('Pieni hetki, tietoa haetaan laitteilta...',
              style: TextStyle(
                color: myPrimaryFontColor,
                backgroundColor: Colors.white,
                fontSize: 24,
              ),
              ),
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            ]
        ))];
  }
  return Scaffold (
    appBar: AppBar(
      title: appTitle,
    ),
    body: Column( children: children),
  );
}