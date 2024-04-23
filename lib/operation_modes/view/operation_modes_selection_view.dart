
import 'package:flutter/material.dart';
import '../operation_modes.dart';
import '../../look_and_feel.dart';

class OperationModesSelectionView extends StatefulWidget {
  final OperationModes operationModes;

  const OperationModesSelectionView({
    Key? key,
    required this.operationModes,
  }) : super(key: key);

  @override
  State<OperationModesSelectionView> createState() =>_OperationModesSelectionViewState();
}

class _OperationModesSelectionViewState extends State<OperationModesSelectionView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.operationModes.nbrOfModes() == 0) {
      return emptyWidget();
    }
    return Container(
        height: 50,
        child: Row(
          children: [ListView.builder(
            itemCount: widget.operationModes.nbrOfModes(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              bool indexIsCurrentMode = widget.operationModes.currentIndex() == index;
              return OutlinedButton(
                  onPressed: () {
                    setState(() {
                      widget.operationModes.selectIndex(index);
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: indexIsCurrentMode
                        ? Colors.amber
                        : Colors.white,
                    side: BorderSide(
                      color: indexIsCurrentMode
                          ? Colors.amber
                          : Colors.white,
                    ),
                  ),
                  child: Text(widget.operationModes.modeName(index),
                      style: TextStyle(color: Colors.brown[900])));
        })],));
  }
}