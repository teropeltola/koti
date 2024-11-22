import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:koti/devices/shelly/shelly_script_code.dart';

import '../../look_and_feel.dart';

Widget editCode(BuildContext context, ShellyScriptCode code, Function setValue) {
  String currentCode = code.originalCode;
  FocusNode focusNode = FocusNode();
  return Scaffold(
      appBar: AppBar(title: appTitleOld('Shelly scriptin syöttö')),
      body:
      SingleChildScrollView(
          child:
          Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(5,5,5,5),
                  padding: const EdgeInsets.all(5),
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Shelly Script'),
                    child: TextField(
                        key: const Key('codeField'),
                        focusNode: focusNode,
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        controller: TextEditingController(
                          text: currentCode,
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (String codeText) {
                          currentCode = codeText;
                        },
                        onEditingComplete: () {
                          focusNode.unfocus();
                        }),
                  ),
                ),
                Row(children: <Widget>[
                  Expanded(
                      child: Container(
                          margin: const EdgeInsets.fromLTRB(30,5,30,5),
                          padding: const EdgeInsets.all(5),
                          height: 70,
                          child: Tooltip(
                              message:
                              'Talletetaan pysyvästi tekemäsi muutokset',
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  //shape: StadiumBorder(),
                                    backgroundColor: myPrimaryColor,
                                    side: const BorderSide(
                                        width: 2, color: myPrimaryColor),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                    elevation: 10),
                                onPressed: () async {
                                  // check if the data is ok
                                  if (currentCode.isEmpty) {
                                    informMatterToUser(context, "rakennekuvaus ei voi olla tyhjä", "Määrittele tulostusrakenne");
                                  }
                                  else {
                                    String errorText =  ''; //errorFoundFromCode(listSelectionContent.thisList, currentCode);
                                    if (errorText != '') {
                                      informMatterToUser(context, "koodi virheellinen, korjaa se!", errorText);
                                    }
                                    else {
                                      code.setCode(currentCode);
                                      await setValue();
                                      Navigator.pop(context,true);
                                    }
                                  }
                                },
                                child: const AutoSizeText(
                                  'Talleta muutokset',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white),
                                  textScaleFactor: 2.0,
                                ),
                              ))))
                ]),
              ]
          )
      )
  );

}
