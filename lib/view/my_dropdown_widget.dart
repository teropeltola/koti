import 'package:flutter/material.dart';

import '../logic/dropdown_content.dart';
import '../look_and_feel.dart';

class MyDropdownWidget extends StatefulWidget {
  final String keyString;
  final DropdownContent dropdownContent;
  final Function setValue;
  const MyDropdownWidget({Key? key,
    required this.keyString,
    required this.dropdownContent,
    required this.setValue}) : super(key: key);

  @override
  State<MyDropdownWidget> createState() => _MyDropdownWidgetState();
}

class _MyDropdownWidgetState extends State<MyDropdownWidget> {

  String dropdownValue = '';

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.dropdownContent.currentString();
  }
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      key: Key(widget.keyString),
      isExpanded: true,
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 14,
      style: const TextStyle(//backgroundColor: Colors.white,
          color: mySecondaryFontColor,
          height: 1.2,
          fontWeight: FontWeight.bold),
      underline: emptyWidget(),
      onChanged: (String? newValue) {
        dropdownValue = newValue!;
        int index = widget.dropdownContent.optionIndex(dropdownValue);
        widget.dropdownContent.setIndex(index);
        widget.setValue(index);
        // TODO: CHECK IF THIS CHANGE HAS UNNECESSARY EFFECT (Done because of editThermometerView
        // setState(() {});
      },
      items: widget.dropdownContent.options()
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: myPrimaryFontColor)),
        );
      }).toList(),
    );
  }
}
