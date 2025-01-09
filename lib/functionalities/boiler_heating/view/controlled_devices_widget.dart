import 'package:flutter/material.dart';

import '../../../logic/dropdown_content.dart';
import '../../../look_and_feel.dart';
import '../../../view/my_dropdown_widget.dart';

Widget controlledDevicesWidget(
    String headline,
    String inputTitle,
    DropdownContent possibleDevicesDropdown,
    Function callback) {
  return Container(
    margin: myContainerMargin,
    padding: myContainerPadding,
    height: 120,
    child: InputDecorator(
      decoration: InputDecoration(labelText: headline), //k
      child:
      Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: myContainerMargin,
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
              child: InputDecorator(
                decoration: InputDecoration(labelText: inputTitle),
                child: SizedBox(
                    height: 30,
                    width: 120,
                    child: MyDropdownWidget(
                        keyString: 'boilerDropdown',
                        dropdownContent: possibleDevicesDropdown,
                        setValue: (newValue) {
                          possibleDevicesDropdown
                              .setIndex(newValue);
                          callback();
                        }
                    )
                ),
              ),
            ),
          ]),
    ),
  );
}