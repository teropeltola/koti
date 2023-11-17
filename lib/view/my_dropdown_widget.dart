import 'package:flutter/material.dart';

import '../logic/dropdown_content.dart';
import '../look_and_feel.dart';

class MyDropdownWidget extends StatefulWidget {
  final DropdownContent dropdownContent;
  final Function setValue;
  const MyDropdownWidget({Key? key,
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
      isExpanded: true,
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 14,
      // elevation: 16,
      style: const TextStyle(//backgroundColor: Colors.white,
          color: mySecondaryFontColor,
          //fontSize: 20,
          height: 1.2,
          fontWeight: FontWeight.bold),
      underline: emptyWidget(),
      onChanged: (String? newValue) {
        dropdownValue = newValue!;
        int index = widget.dropdownContent.optionIndex(dropdownValue);
        widget.setValue(index);
        widget.dropdownContent.getValue(index);
        setState(() {});
      },
      items: widget.dropdownContent.options()
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: mySecondaryFontColor)),
        );
      }).toList(),
    );
  }
}
