import 'package:flutter/material.dart';
import '../look_and_feel.dart';

Widget interruptEditingWidget(BuildContext context, Function cleaningFunction) {
  return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Keskeytä laitteen tietojen muokkaus',
      onPressed: () async {
        // check if the user wants to cancel all the changes
        bool doExit = await askUserGuidance(context,
            'Poistuttaessa muutetut tiedot katoavat.',
            'Haluatko poistua näytöltä?'
        );
        if (doExit) {
          await cleaningFunction();
          Navigator.of(context).pop(false);
        }
      }
      );
}