import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../app_configurator.dart';
import '../../devices/device/device.dart';
import '../../functionalities/functionality/functionality.dart';
import '../../logic/diagnostics.dart';
import '../../look_and_feel.dart';
import '../estate.dart';
import 'estate_view.dart';


class EstatePageView extends StatefulWidget {
  final Function callback;
  const EstatePageView({Key? key, required this.callback}) : super(key: key);

  @override
  _EstatePageViewState createState() => _EstatePageViewState();
}


class _EstatePageViewState extends State<EstatePageView> {

  final controller = PageController(
    initialPage: myEstates.currentIndex
  );

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void _handlePageViewChanged(int currentPageIndex) {
    myEstates.setCurrentIndex(currentPageIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

      return PageView(
          controller: controller,
          onPageChanged: _handlePageViewChanged,
          children: [
            for (int index=0; index <myEstates.nbrOfEstates(); index++)
              EstateView(estateIndex: index, callback: widget.callback)
          ]
      );
    }
  }
