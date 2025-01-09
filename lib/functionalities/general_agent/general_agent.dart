import 'package:flutter/material.dart';

import 'package:koti/functionalities/general_agent/view/edit_general_agent_view.dart';
import 'package:koti/functionalities/general_agent/view/general_agent_view.dart';
import '../../devices/device/device.dart';
import '../../estate/estate.dart';
import '../../logic/device_attribute_control.dart';
import '../../look_and_feel.dart';
import '../../operation_modes/conditional_operation_modes.dart';
import '../../operation_modes/operation_modes.dart';
import '../functionality/functionality.dart';
import '../functionality/view/functionality_view.dart';

class GeneralAgent extends Functionality {

  static const String functionalityName = 'agentti';

  GeneralAgent() {
    myView = GeneralAgentView();
    myView.setFunctionality(this);
  }

  GeneralAgent.failed() {
    myView = GeneralAgentView();
    myView.setFunctionality(this);
    setFailed();
  }

  @override
  Future<void> init () async {
    operationModes.initModeStructure(
        estate: myEstates.currentEstate(),
        parameterSettingFunctionName: 'GeneralAgentParameterFunction',
        deviceId: '',
        deviceAttributes: [DeviceAttributeCapability.directControl],
        setFunction: setFunction,
        getFunction: getFunction );

    operationModes.addType(ConstantOperationMode().typeName());
    operationModes.addType(ConditionalOperationModes().typeName());

  }


  void setFunction(Map<String, dynamic> parameters) {
    log.info('GeneralAget setFunction');
  }

  Map<String, dynamic> getFunction() {
    Map<String, dynamic> map = {};
    return map;
  }


/*
  @override
  FunctionalityView myView() {
    return GeneralAgentView(this.id);
  }

 */


  @override
  Future<bool> editWidget(BuildContext context, bool createNew, Estate estate, Functionality functionality, Device device) async {
    return await Navigator.push(context, MaterialPageRoute(
        builder: (context)
        {
          return EditGeneralAgentView(
              estate: estate,
              generalAgent: this as GeneralAgent
          );
        }
    ));
  }

  @override
  Widget dumpData({required Function formatterWidget}) {
    return formatterWidget(
        headline: functionalityName,
        textLines: [
          'tunnus: $id',
        ],
        widgets: [
          dumpDataMyDevices(formatterWidget: formatterWidget)
        ]
    );
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  GeneralAgent.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    myView = GeneralAgentView();
    myView.setFunctionality(this);
  }

}
