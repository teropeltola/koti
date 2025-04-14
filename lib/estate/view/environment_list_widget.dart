import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../look_and_feel.dart';
import '../../view/my_button_widget.dart';
import '../environment.dart';
import '../estate.dart';
import 'edit_environment_view.dart';


ButtonStyle _buttonStyle (Color backgroundColor, Color foregroundColor) {
  return   ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: const EdgeInsets.all(2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      )
  );
}
const int _crossAxisCount = 4;

double _height(int itemCount) {
  if (itemCount == 0) {
    return 100.0;
  }
  else {
    int nbrOfLines = 1 + ((itemCount-1) ~/ _crossAxisCount);
    return 20.0 + 100.0 * nbrOfLines;
  }
}

class EnvironmentListWidget extends StatefulWidget {
  final Environment environment;
  final Function callback;
  const EnvironmentListWidget(
      {super.key, required this.environment, required this.callback});

  @override
  State<EnvironmentListWidget> createState() => _EnvironmentListViewWidgetState();
}

class _EnvironmentListViewWidgetState extends State<EnvironmentListWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: myContainerMargin,
      padding: myContainerPadding,
      child:  InputDecorator(
        decoration: InputDecoration(labelText: '${widget.environment.name}: huoneet ja osa-alueet'),
        child: Column( children: [
        widget.environment.nbrOfSubEnvironments() == 0
            ? const Text('Ei ole vielä huoneita tai muita osa-alueita. Lisää niitä painamalla "Luo uusi" painiketta!')
            : SizedBox(
          height: _height(widget.environment.nbrOfSubEnvironments()),
          width: MediaQuery.of(context).size.width,
          child:
            GridView.count(
              crossAxisCount: _crossAxisCount,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              shrinkWrap: true, // TODO: is this needed?
              padding: const EdgeInsets.all(1.0),
              children: [
                for (var subEnvironment in widget.environment.environments)
                  ElevatedButton(
                    style:_buttonStyle(Colors.green, Colors.white),
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EditEnvironmentView(
                                  environment: subEnvironment
                              );
                            },
                          )
                      );
                      //bool status = await .editWidget(context, estate);
                      setState((){});
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            fit:FlexFit.loose,
                            child:
                            Text(subEnvironment.name,
                                style: const TextStyle(fontSize: 12)),
                        ),
                        Flexible(
                            fit:FlexFit.loose,
                            child:
                            Icon(
                              Icons.room_preferences,
                              size: 18,
                              color: Colors.white,
                            ),
                        ),
                      ]
                    )
      )
        ]
            )
        ),
        myButtonWidget(
          'Luo uusi',
          'Luo uusi huone tai osa-alue',
          () async {
            Environment environment = Environment();
            widget.environment.addSubEnvironment(environment);
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return EditEnvironmentView(
                        environment: environment
                    );
                  },
                )
            );
            widget.callback();

           }
        )]
       )
      )
    );
  }
}
