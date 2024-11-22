import 'package:flutter/material.dart';
import '../look_and_feel.dart';

Widget readyWidget(
  Function beforeExitRoutine,
)
{
  return Container(
      margin: myContainerMargin,
      padding: myContainerPadding,
      child: Tooltip(
          message:
          'Paina tästä tallentaaksesi muutokset ja poistuaksesi näytöltä',
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
              await beforeExitRoutine();
            },
            child: const Text(
              'Valmis',
              maxLines: 1,
              style: TextStyle(color: mySecondaryFontColor),
              textScaler: const TextScaler.linear(2.2),
            ),
          )));
}