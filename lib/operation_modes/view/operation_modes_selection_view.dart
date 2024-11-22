
import 'package:flutter/material.dart';
import '../../estate/estate.dart';
import '../operation_modes.dart';
import '../../look_and_feel.dart';
import 'edit_operation_mode_view.dart';

class OperationModesSelectionView extends StatefulWidget {
  final OperationModes operationModes;
  final bool topHierarchy;
  final Function callback;

  const OperationModesSelectionView({
    Key? key,
    required this.operationModes,
    required this.topHierarchy,
    required this.callback
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
        margin: EdgeInsets.all(2),
        height: 50,
        child:
         ListView(
           scrollDirection: Axis.horizontal,
          children: [ListView.builder(
              itemCount: widget.operationModes.nbrOfModes(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                bool indexIsCurrentMode = widget.operationModes.currentIndex() == index;
                bool currentModeIsValid = indexIsCurrentMode ? widget.operationModes.currentIndexIsValid() : false;
                return OutlinedButton(
                    onPressed: () {
                      widget.operationModes.selectIndex(index, widget.topHierarchy ? widget.operationModes : null);
                      widget.callback();
                      setState(() {});
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: indexIsCurrentMode
                          ? Colors.amber
                          : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      side: BorderSide(
                        color: indexIsCurrentMode
                            ? (currentModeIsValid ? Colors.blueGrey : Colors.red)
                            : Colors.white,
                      ),
                    ),
                    child: Text(widget.operationModes.modeName(index),
                        style: TextStyle(color: Colors.brown[900])));
              })],)
    );
  }
}

class OperationModesSelectionView2 extends StatefulWidget {
  final OperationModes operationModes;
  final String initSelectionName;
  final Function returnSelectedModeName;

  const OperationModesSelectionView2({
    Key? key,
    required this.operationModes,
    required this.initSelectionName,
    required this.returnSelectedModeName,
  }) : super(key: key);

  @override
  State<OperationModesSelectionView2> createState() =>_OperationModesSelectionViewState2();
}

class _OperationModesSelectionViewState2 extends State<OperationModesSelectionView2> {
  String currentSelectionName = '';
  @override
  void initState() {
    currentSelectionName = widget.initSelectionName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.operationModes.nbrOfModes() == 0) {
      widget.returnSelectedModeName('');
      return emptyWidget();
    }
    return Container(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [ListView.builder(
              itemCount: widget.operationModes.nbrOfModes(),
              shrinkWrap: true,
              padding: EdgeInsets.all(2),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                bool indexIsCurrentMode = widget.operationModes.modeName(index) == currentSelectionName;
                return OutlinedButton(
                    onPressed: () {
                      currentSelectionName = widget.operationModes.modeName(index);
                      widget.returnSelectedModeName(currentSelectionName);
                      setState(() {});
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    child: Text(widget.operationModes.modeName(index),
                        style: TextStyle(color: Colors.brown[900])));
              })],));
  }
}
/*

class OperationModesSelectionInternalView extends StatefulWidget {
  final OperationModes operationModes;
  final Function selectionNameFunction;
  final Function returnSelectedModeName;

  const OperationModesSelectionInternalView({
    Key? key,
    required this.operationModes,
    required this.selectionNameFunction,
    required this.returnSelectedModeName,
  }) : super(key: key);

  @override
  State<OperationModesSelectionInternalView> createState() =>_OperationModesSelectionInternalViewState();
}

class _OperationModesSelectionInternalViewState extends State<OperationModesSelectionInternalView> {
  String currentSelectionName = '';
  @override
  void initState() {
    super.initState();
    currentSelectionName = widget.selectionNameFunction();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.operationModes.nbrOfModes() == 0) {
      widget.returnSelectedModeName('');
      return emptyWidget();
    }
    return SizedBox(
        height: 50,
        child: Row(
          children: [ListView.builder(
              itemCount: widget.operationModes.nbrOfModes(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                bool indexIsCurrentMode = widget.operationModes.modeName(index) == currentSelectionName;
                return OutlinedButton(
                    onPressed: () {
                      currentSelectionName = widget.operationModes.modeName(index);
                      widget.returnSelectedModeName(currentSelectionName);
                      setState(() {});
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
*/

class OperationModesEditingView extends StatefulWidget {
  //final String operationModeSetFunctionName;
  final Estate estate;
  final OperationModes operationModes;
  final Function selectionNameFunction;
  final Function returnSelectedModeName;
  final Function parameterReadingFunction;

  const OperationModesEditingView({
    Key? key,
    //required this.operationModeSetFunctionName,
    required this.estate,
    required this.operationModes,
    required this.selectionNameFunction,
    required this.returnSelectedModeName,
    required this.parameterReadingFunction,

  }) : super(key: key);

  @override
  State<OperationModesEditingView> createState() =>_OperationModesEditingViewState();
}

class _OperationModesEditingViewState extends State<OperationModesEditingView> {
  String currentSelectionName = '';
  @override
  void initState() {
    super.initState();
    currentSelectionName = widget.selectionNameFunction();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.operationModes.nbrOfModes() == 0) {
      widget.returnSelectedModeName('');
      return emptyWidget();
    }
    return Column(
          children: [
              for (int index=0; index<widget.operationModes.nbrOfModes(); index++)
                 Card(
                  elevation: 6,
                  margin: const EdgeInsets.fromLTRB(5,5,5,5),
                  child: ListTile(
                    title: Text(widget.operationModes.modeName(index)),
                    trailing: SizedBox(width: 112, child: Row(children: [
                      IconButton(
                        key: Key('edit-${widget.operationModes.modeName(index)}'),
                        icon: const Icon(Icons.edit,
                              color: myPrimaryFontColor, size: 40),
                          tooltip: 'Muokkaa toimintatilaa',
                          onPressed: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return EditOperationModeView(
                                        estate: widget.estate,
                                        initOperationModeName: widget.operationModes.modeName(index), //operationModes.currentModeName(),
                                        operationModes: widget.operationModes,
                                        parameterFunction: widget.parameterReadingFunction,
                                        callback: (){setState(() {});});
                                  },
                                )
                            );
                            setState(() {});
                          }),
                      IconButton(
                          key: Key('delete-${widget.operationModes.modeName(index)}'),
                          icon: const Icon(Icons.delete,
                              color: myPrimaryFontColor, size: 40),
                          tooltip: 'Poista toimintotila',
                          onPressed: () async {
                            bool doDelete = await askUserGuidance(context, 'Komennolla tuhotaan tämä toimintotila eikä sitä voi perua.', 'Haluatko tuhota toimintotilan?');
                            if (doDelete) {
                              widget.operationModes.remove(widget.operationModes.modeName(index));
                            }
                            setState(() {});
                          }),
                      ])),
                    subtitle: Text(widget.operationModes.getModeAt(index).typeName())
                )
              )],);
  }
}


