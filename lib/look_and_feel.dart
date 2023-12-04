import 'package:flutter/material.dart';
import 'package:talker/talker.dart';

const appName = 'himatuikku';

const familyDeliminator = '/';

const String celsius =  "\u2103";

ThemeData myTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue //myPrimaryColor,
    ),
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(color:Colors.white),
    color: myPrimaryColor,
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

const Color myPrimaryColor = Color(0xFFC0D0C6); //Colors.blueGrey;
const Color mySecondaryColor = Colors.grey;
const Color myPrimaryFontColor = Colors.white;
const Color mySecondaryFontColor = Colors.blue;
const Color myDropdownFontColor = Colors.blueGrey;
const Color myPrimaryButtonColor = Colors.blueGrey;

const myAlertDialogTitleScale = 0.6;
const EdgeInsets myContainerMargin =  EdgeInsets.all(2.0);
const EdgeInsets myContainerPadding =  EdgeInsets.all(2.0);


Widget emptyWidget () {
  return const Offstage(offstage: true, child:Text(''),);
}

Widget appTitle(String titleText) {
  return Text(
           titleText,
           style: const TextStyle(fontSize:28)
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
              textScaleFactor: 0.6),
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
                      textScaleFactor: myAlertDialogTitleScale),
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

