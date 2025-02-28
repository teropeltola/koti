import 'package:flutter/material.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../general_agent.dart';
import 'edit_general_agent_view.dart';

class GeneralAgentOverview extends StatefulWidget {
  final Function callback;
  final GeneralAgent generalAgent;
  const GeneralAgentOverview({Key? key, required this.generalAgent, required this.callback}) : super(key: key);

  @override
  _GeneralAgentOverviewState createState() => _GeneralAgentOverviewState();
}

class _GeneralAgentOverviewState extends State<GeneralAgentOverview> {

  @override
  void initState() {
    super.initState();

    refresh();
  }

  void refresh() {
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: appIconAndTitle(myEstates.currentEstate().name,'lämmitys'),
          ), // new line
          body: SingleChildScrollView(
              child: Column(children: <Widget>[
                Container(
                margin: const EdgeInsets.fromLTRB(2,10,2,2),
                padding: myContainerPadding,
                //alignment: AlignmentDirectional.topStart,
                child: const InputDecorator(
                  decoration: InputDecoration(labelText: 'Ouman EH-800 lämmönsäädin'), //k
                  child: Row(children:<Widget> [

                  Expanded(
                      flex: 6,
                      child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                                  Text('Ulkolämpötila:'),
                                  Text('Veden lämpötila: '),
                                  Text('Haluttu veden lämpötila: '),
                                  Text('Venttiilin asento:'),
                                  Text('Aikaleima:')
                        ]),
                  ),
                  ]),
                ),
              ),
            ])
          ),
            bottomNavigationBar: Container(
              height: bottomNavigatorHeight,
              alignment: AlignmentDirectional.topCenter,
              color: myPrimaryColor,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                        icon: const Icon(
                            Icons.edit,
                            color: myPrimaryFontColor,
                            size: 40),
                        tooltip: 'muokkaa näytön tietoja',
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return EditGeneralAgentView(
                                    estate: myEstates.currentEstate(),
                                    generalAgent: widget.generalAgent,
                                  );
                                },
                              )
                          );
                          setState(() {});
                        }
                    ),
                  ]),
            )

        );
  }
}
