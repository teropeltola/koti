import 'package:flutter/material.dart';
import '../look_and_feel.dart';

Widget myButtonWidget(
    String buttonText,
    String buttonTooltip,
    Function selectionRoutine,
    ) {
  return Container(
      margin: myContainerMargin,
      padding: myContainerPadding,
      child: Tooltip(
          message: buttonTooltip,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                backgroundColor: mySecondaryColor,
                side: const BorderSide(
                    width: 2,
                    color: mySecondaryColor
                ),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                elevation: 10),
            onPressed: () async {
              await selectionRoutine();
            },
            child: Text(buttonText,
              maxLines: 1,
              style: TextStyle(color: mySecondaryFontColor),
              textScaler: TextScaler.linear(2.2),
            ),
          )
      )
  );
}