import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:screenshot/screenshot.dart';

import '../estate/estate.dart';
import '../look_and_feel.dart';

class DataStructureDumpView extends StatefulWidget {
  const DataStructureDumpView({Key? key}) : super(key: key);

  @override
  State<DataStructureDumpView> createState() => _DataStructureDumpViewState();
}

Widget _dumpWidgetizer({required String headline,
                        required List<String> textLines,
                        required List<Widget> widgets}) {
  try {
    return Container(
        margin: myContainerMargin,
        padding: myContainerPadding,
        child: InputDecorator(
            decoration: InputDecoration(labelText: headline),
            textAlignVertical: TextAlignVertical.top,
            child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget> [
                  for (var textLine in textLines)
                    AutoSizeText(textLine, maxLines: 1),
                  for (var widget in widgets)
                      widget,
                ]
              )
        )
    );
  }
  catch (e, st) {
    log.error('Unvalid dump formatter with "$headline"', e, st);
    return Text('Sisäinen virhe tietojen tulostuksessa ("headline"');
  }

}

class _DataStructureDumpViewState extends State<DataStructureDumpView> {

  ScreenshotController screenshotController = ScreenshotController();

  bool shareButtonAlreadyPressed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var myAutoSizeGroup = AutoSizeGroup();
    return Screenshot(
        controller: screenshotController,
        child: Scaffold(
            appBar: AppBar(
                title: appIconAndTitle('Kaikki','tiedot'),
                backgroundColor: myPrimaryColor,
                iconTheme: const IconThemeData(color:myPrimaryFontColor)
            ),// new line
            body: SingleChildScrollView( child: Column(children: <Widget>[
              _genDataWidget(),
              for (var estate in myEstates.estates)
                estate.dumpData(formatterWidget: _dumpWidgetizer),
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
                        icon: const Icon(Icons.share,
                            color:myPrimaryFontColor,
                            size:40),
                        tooltip: 'jaa näyttö somessa',
                        onPressed: () async {
                          if (shareButtonAlreadyPressed) {
                            return;
                          }
                          shareButtonAlreadyPressed = true;
                          Uint8List ?imageBuffer;
                          bool successfulScreenshot = true;
                          try {
                            /*
                            imageBuffer = await screenshotController
                                .captureFromLongWidget(
                                InheritedTheme.captureAll(
                                    context,
                                    Material(
                                        child: _speciesListFormForSome(context,
                                            listOfSpecies,
                                            _obsCat.value(),
                                            _tagList,
                                            _timeRangeSelection)
                                    )
                                ),
                                context: context,
                                constraints: const BoxConstraints(
                                  maxWidth: 400,
                                )
                            );
                            TEMP
                             */
                          }
                          catch(e) {
                            successfulScreenshot = false;
                          }

                          if (successfulScreenshot) {
                      // TEMP      await socialShareBuffer(context, imageBuffer!);
                          } else {
                            await informMatterToUser(context,
                                'Jakaminen sosiaaliseen mediaan ei onnistunut',
                                'Tämä liittyy bbongin käyttämään kirjastoon ja on tiedossa oleva ongelma. ' );
                          }
                          shareButtonAlreadyPressed = false;
                        }
                    ),
                  ]),
            )
        )
    );
  }
}


Widget _genDataWidget() {

  return _dumpWidgetizer(
    headline: 'Yleiset tietorakenteet',
    textLines: [
          'Asuntojen lukumäärä: ${myEstates.nbrOfEstates()}',
          'Toiminnallisuuksien lukumäärä: ${allFunctionalities
              .nbrOfFunctionalities()}',
        ],
    widgets: []
  );
}
