import 'package:flutter/material.dart';
import '../look_and_feel.dart';

Widget noNeededResources(BuildContext context, String resourceProblemText) {
  return Column(children: <Widget>[
    Container(
        margin: myContainerMargin,
        padding: myContainerPadding,
        height: 200,
        child: InputDecorator(
            decoration: const InputDecoration(),
            child:
            Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      margin: myContainerMargin,
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                      child: Text(resourceProblemText)
                  ),
                  Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      child: Tooltip(
                          message: 'Paina tästä poistuaksesi näytöltä',
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                backgroundColor: mySecondaryColor,
                                side: const BorderSide(
                                    width: 2, color: mySecondaryColor),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                                elevation: 10),
                            onPressed: () async {
                              Navigator.pop(context, false);
                            },
                            child: const Text(
                              'Ok',
                              maxLines: 1,
                              style: TextStyle(color: mySecondaryFontColor),
                              textScaler: TextScaler.linear(2.2),
                            ),
                          ))),
                ]
            )
        )
    )
  ]
  );
}