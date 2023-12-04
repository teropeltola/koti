import 'package:flutter/material.dart';

import '../../../look_and_feel.dart';

class FunctionalityView {

  dynamic myFunctionality;

  FunctionalityView(this.myFunctionality);

  ButtonStyle buttonStyle (Color backgroundColor, Color foregroundColor) {
    return   ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        )
    );
  }

  Widget gridBlock(BuildContext context, Function callback) {
    return emptyWidget();
  }
}
