import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
