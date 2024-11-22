import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:talker/talker.dart';

import 'estate/estate.dart';
import 'logic/observation.dart';

const appName = 'Koti';

const familyDeliminator = '/';

const String celsius =  "\u2103";
const double noValueDouble = -99.9987654;

ThemeData myTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue //myPrimaryColor,
    ),
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(color:myPrimaryColor),
    color: Colors.white,
  ),
  //primarySwatch: Colors.blueGrey
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.bold
    ),
    titleLarge: TextStyle(
      fontSize: 30,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(
      color: mySecondaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 20),
    enabledBorder: OutlineInputBorder(
      gapPadding: 3,
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        color: mySecondaryColor,
        width: 2
      ),
    ),
    fillColor: Colors.grey
  ),
  dropdownMenuTheme: const DropdownMenuThemeData(
    textStyle: TextStyle(
        backgroundColor: Colors.blue,
        color: mySecondaryColor)
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      )
    )
  )

);

const Color myPrimaryColor = Colors.white; //Colors.blueGrey;
const Color mySecondaryColor = Color(0xFFC0D0C6); // Colors.grey;
const Color myPrimaryFontColor =  Colors.blue;
const Color mySecondaryFontColor = Colors.white;
const Color myDropdownFontColor = Colors.blueGrey;
const Color myPrimaryButtonColor = Colors.blueGrey;

const Color defaultIconColor = myPrimaryFontColor;

const myAlertDialogTitleScale = 0.6;
const EdgeInsets myContainerMargin =  EdgeInsets.all(2.0);
const EdgeInsets myContainerPadding =  EdgeInsets.all(2.0);


Widget emptyWidget () {
  return const Offstage(offstage: true, child:Text(''),);
}

const _presetAppFontSizes = [28.0, 24.0, 20.0, 16.0, 12.0];

Widget appIconAndTitle(String estateName, String titleText) {
  var myAutoSizeGroup = AutoSizeGroup();
  return Row(children: [
    Expanded(
        flex: 5,
        child:
          AutoSizeText(
            '$estateName',
            //group: myAutoSizeGroup,
            maxLines: 1,
            presetFontSizes: _presetAppFontSizes,
            style: const TextStyle(
              color: Colors.blue,
            ),
            textAlign: TextAlign.right
          ),
    ),
    Expanded(
      flex: 1,
      child: Text(' '),
    ),
    Expanded(
        flex: 3,
        child: Image.asset(
            'assets/images/main_image.png',
            fit: BoxFit.contain)
    ),
    Expanded(
      flex: 1,
      child: Text(' '),
    ),
    Expanded(
        flex: 12,
        child:
          AutoSizeText(
            '$titleText',
            //group: myAutoSizeGroup,
            maxLines: 2,
            style: const TextStyle(color: Colors.blue),
            textAlign: TextAlign.left,
            wrapWords: false,
            presetFontSizes: _presetAppFontSizes,
        ),
    ),
  ]
  );
}

Widget appTitleOld(String titleText) {
  return Text(
           titleText,
           style: const TextStyle(fontSize:28, color: Colors.blue)
         );
}

Future <bool> informMatterToUser(BuildContext context, String titleText, String basicText) async {
  await showDialog<bool>(
    context: context,
    builder:
        (BuildContext dialogContext) {
      return AlertDialog(
          title: Text(
              titleText,
              textScaler: const TextScaler.linear(1.1),
          ),
          content: Text(basicText),
          actions: <Widget>[
            TextButton(
              key: const Key('informMatterOK'),
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(
                    dialogContext,
                    true);
              },
            )
          ]
      );
    },
  );
  return true;
}

final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();

void showSnackbarMessage(String message) {
  final SnackBar snackBar = SnackBar(content: Text(message));
  snackbarKey.currentState?.showSnackBar(snackBar);
}

Talker log = Talker();

Color properTextColor(Color backgroundColor) {
  return backgroundColor.computeLuminance() < 0.5
      ? Colors.white
      : Colors.black;
}

Future<bool> askUserGuidance(BuildContext context, String titleText, String contentText) async {
  bool? doExit = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
          title: Text(titleText,
              textScaler: const TextScaler.linear(myAlertDialogTitleScale),
          ),
          content: Text(contentText),
          actions: <Widget>[
            TextButton(
                child: const Text('Kyllä'),
                onPressed: () async {
                  Navigator.pop(dialogContext, true);
                }),
            TextButton(
              child: const Text('En'),
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
            )
          ]);
    },
  );
  return doExit ?? false;
}

Color observationSymbolColor(ObservationLevel level) {
  if ((level == ObservationLevel.ok) || (level == ObservationLevel.informatic)) {
    return Colors.green;
  }
  else if (level == ObservationLevel.warning) {
    return Colors.yellow;
  }
  else {
    return Colors.red;
  }
}

const bottomNavigatorHeight = 60.0;

Widget dumpTextLine(String text) {
  return AutoSizeText(text, maxLines: 1);
}

String dumpTimeString(DateTime d) {
  return '${d.day}.${d.month}. ${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';
}

Future <void> storeChanges() async {
  await myEstates.store();
  showSnackbarMessage(
      'Muutokset talletettu!');

}

String currencyCentInText(double cents) {
  if (cents == noValueDouble) {
    return '??';
  }
  else {
    return '${cents.toStringAsFixed(2)} c';
  }
}

