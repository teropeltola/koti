import 'package:flutter/material.dart';
import 'package:koti/estate/environment.dart';

import '../../../estate/estate.dart';
import '../../../look_and_feel.dart';
import '../../../operation_modes/conditional_operation_modes.dart';
import '../../../operation_modes/operation_modes.dart';
import '../../../operation_modes/view/conditional_option_list_view.dart';
import '../../../operation_modes/view/edit_operation_mode_view.dart';
import '../../../view/ready_widget.dart';
import '../../air_heat_pump_functionality/view/air_heat_pump_view.dart';
import '../general_agent.dart';

class EditGeneralAgentView extends StatefulWidget {
  Environment environment;
  GeneralAgent generalAgent;
  EditGeneralAgentView({Key? key, required this.environment, required this.generalAgent}) : super(key: key);

  @override
  _EditGeneralAgentViewState createState() => _EditGeneralAgentViewState();
}

class _EditGeneralAgentViewState extends State<EditGeneralAgentView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Palaa takaisin tallentamatta muutoksia',
              onPressed: () async {
                // check if the user wants to cancel all the changes
                bool doExit = await askUserGuidance(context,
                    'Poistuttaessa muutokset eivät säily.',
                    'Haluatko poistua muutossivulta ?'
                );
                if (doExit) {
                  Navigator.of(context).pop();
                }
              }),
          title: appIconAndTitle(widget.environment.name, GeneralAgent.functionalityName),
        ), // new line
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
              operationModeHandling(
                context,
                widget.environment,
                widget.generalAgent.operationModes,
                generalParameterSetting,
                () {setState(() {});}
              ),
          Container(
            margin: myContainerMargin,
            padding: myContainerPadding,
            child: const InputDecorator(
              decoration: InputDecoration(labelText: 'Näyttövalinnat'),
                child: Column(children: <Widget>[
                  Text('laadidaa')
                ]
                )
            )
          ),
              readyWidget(() async {
              })

            ]
    )
    )
    );

  }
}

Future <GeneralAgent> createGeneralAgent(BuildContext context, Environment enviroment, String serviceName) async {
  GeneralAgent generalAgent = GeneralAgent();
  await generalAgent.init();

  bool success = await Navigator.push(context, MaterialPageRoute(
      builder: (context)
      {
        return EditGeneralAgentView(
            environment: enviroment,
            generalAgent: generalAgent
        );
      }
  ));

  if (! success) {
    generalAgent.setFailed();
  }
  return generalAgent;

}

List<String> possibleParameterTypes = [constWarming, relativeWarming, dynamicOperationModeText];

Widget generalParameterSetting(
    OperationMode operationMode,
    Estate estate,
    OperationModes operationModes
    )
{
  Widget myWidget;
  if (operationMode is ConstantOperationMode) {
    ConstantOperationMode cOM = operationMode;
    myWidget=temperatureSelectionForm(temperatureParameterId, cOM.parameters);
  }
  else if (operationMode is ConditionalOperationModes) {
    ConditionalOperationModes conditionalModes = operationMode;
    myWidget = ConditionalOperationView(
        conditions: operationMode
    );
  }
  else {
    myWidget=const Text('ei oo toteutettu, mutta ideana on antaa +/- arvoja edelliseen verrattuna');
  }
  return myWidget;
}


