import 'package:flutter/material.dart';
import '../look_and_feel.dart';

Widget myIconButtonWidget(
    IconData icon,
    String buttonText,
    String buttonTooltip,
    Function selectionRoutine,
    ) {
  return Container(
      margin: myContainerMargin,
      padding: myContainerPadding,
      child: Tooltip(
          message: buttonTooltip,
          child: Container(
            margin: myContainerMargin,
            padding: EdgeInsets.zero,
            child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:[

              Icon(icon, color: mySecondaryFontColor,size:30),
              Text(buttonText,
                maxLines: 2,
                style: TextStyle(color: mySecondaryFontColor),
              ),
            ])
          )
          )
      )
  );
}