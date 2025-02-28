import 'dart:math';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../devices/device/device.dart';
import '../../../estate/estate.dart';
import '../../../functionalities/functionality/functionality.dart';
import '../../../logic/dropdown_content.dart';
import '../../../look_and_feel.dart';
import '../../../view/my_dropdown_widget.dart';
import '../../../view/ready_widget.dart';
import '../electricity_price.dart';
import '../json/electricity_price_parameters.dart';


String electricityText(Electricity e) {
  if (e.eTemplateName == 'eSpot') {
    return ('${e.eName} (pörssisähkö)\n'
        '  - pörssisähkö + alv\n'
        '  - marginaali: ${e.par1.toStringAsFixed(2)} c/kWh\n');
  }
  else {
    return ('${e.eName} (kiinteä)\n'
        '  - tuntihinta: ${e.par1.toStringAsFixed(2)} c/kWh\n');
        }
}

String eAgreementText(int nameIndex) {
  int index = nameIndex-1;
  if (index < 0) {
    return 'Ei määritelty';
  }
  else {
    return electricityText(electricityPriceParameters.electricity[index]);
  }
}

String eDistributionText(EDistribution d, double tax) {
  if (d.dTemplateName == 'dTimeOfDay') {
    return '${d.dName} (aikaveloitus)\n'
        '- sähkövero ${tax.toStringAsFixed(5)} c/kWh\n'
        '- siirto päivä (${d.par3.toInt()}-${d.par4.toInt()}): ${d.par1.toStringAsFixed(2)} c/kWh\n'
        '- siirto yö (${d.par4.toInt()}-${d.par3.toInt()}): ${d.par2.toStringAsFixed(2)} c/kWh';
  }
  else {
    return '${d.dName} (kiinteä)\n'
        '- sähkövero ${tax.toStringAsFixed(5)} c/kWh\n'
        '- siirto ${d.par1.toStringAsFixed(2)} c/kWh\n';
  }
}

ElectricityTariff _eTariff(int nameIndex) {
  int index = nameIndex - 1;
  ElectricityTariff e = ElectricityTariff();
  if (index < 0) {
    e.setValue('', TariffType.constant, 0);
  }
  else {
    e.setValue(
        electricityPriceParameters.electricity[index].eName,
        electricityPriceParameters.electricityAgreementIsSpot(nameIndex) ? TariffType.spot : TariffType.constant,
        electricityPriceParameters.electricity[index].par1);
  }
  return e;
}

String distributorAgreementText(int nameIndex) {
  int index = nameIndex-1;
  if (index < 0) {
    return 'Ei määritelty';
  }
  else {
    return eDistributionText(
        electricityPriceParameters.eDistribution[index],
        electricityPriceParameters.basicElectricityParameters.electricityTax);
  }
}

ElectricityDistributionPrice _dTariff(int nameIndex) {
  int index = nameIndex-1;
  ElectricityDistributionPrice d = ElectricityDistributionPrice();
  if (index < 0) {
    d.setConstantParameters('', 0,0);
  }
  else {
    if (electricityPriceParameters.eDistribution[index].dTemplateName == 'constant') {
      d.setConstantParameters(
          electricityPriceParameters.eDistribution[index].dName,
          electricityPriceParameters.eDistribution[index].par1,
          electricityPriceParameters.basicElectricityParameters.electricityTax);
    }
    else {
      d.setTimeOfDayParameters(
          electricityPriceParameters.eDistribution[index].dName,
          electricityPriceParameters.eDistribution[index].par3.toInt(),
          electricityPriceParameters.eDistribution[index].par4.toInt(),
          electricityPriceParameters.eDistribution[index].par1,
          electricityPriceParameters.eDistribution[index].par2,
          electricityPriceParameters.basicElectricityParameters.electricityTax);
    }
  }
  return d;
}

class EditElectricityView extends StatefulWidget {
  final Estate estate;
  final Functionality functionality;
  final Device device;
  const EditElectricityView({Key? key, required this.estate, required this.functionality, required this.device}) : super(key: key);

  @override
  _EditElectricityViewState createState() => _EditElectricityViewState();
}

class _EditElectricityViewState extends State<EditElectricityView> {
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  late ElectricityPrice myElectricityPrice;
  late DropdownContent electricityAgreement; // = DropdownContent([''], '', 0);
  late DropdownContent electricityDistributionAgreement; // = DropdownContent([''], '', 0);


  @override
  void initState() {
    super.initState();
    electricityAgreement = DropdownContent(electricityPriceParameters.electricityAgreementNames(), '', 0);
    electricityDistributionAgreement = DropdownContent(electricityPriceParameters.eDistributionNames(), '', 0);
    myElectricityPrice = widget.functionality as ElectricityPrice;
    refresh();
  }

  void refresh() {
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeWifi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Keskeytä laitteen tietojen muokkaus',
                    onPressed: () async {
                      // check if the user wants to cancel all the changes
                      bool doExit = await askUserGuidance(context,
                          'Poistuttaessa ....',
                          'Haluatko poistua... ?'
                      );
                      if (doExit) {
                        Navigator.of(context).pop();
                      }
                    }),
                title: appTitleOld('Sähkösopimukset'),
              ), // new line
              body: SingleChildScrollView(
                  child: Column(children: <Widget>[

                    Container(
                        margin: myContainerMargin,
                        padding: myContainerPadding,
                        child: InputDecorator(
                            decoration:
                            const InputDecoration(labelText: 'Sähkö- ja siirtosopimus'), //k
                            child: Column(children: <Widget>[
                              Row(children: <Widget>[
                                Expanded(
                                  flex: 15,
                                  child: Container(
                                    margin: myContainerMargin,
                                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                                    child: InputDecorator(
                                      decoration:
                                      const InputDecoration(labelText: 'Sähköyhtiö'),
                                      child: SizedBox(
                                          height: 30,
                                          width: 120,
                                          child: MyDropdownWidget(
                                            keyString: 'electricityAgreement',
                                              dropdownContent: electricityAgreement,
                                              setValue: (newValue) {
                                                electricityAgreement
                                                    .setIndex(newValue);
                                                setState(() {});
                                              })),
                                    ),
                                  ),
                                ),
                                const Spacer(flex: 1),
                                Expanded(
                                    flex: 20,
                                    child: Text(eAgreementText(electricityAgreement.currentIndex()))),
                              ]),
                              Row(children: <Widget>[
                                Expanded(
                                  flex: 15,
                                  child: Container(
                                    margin: myContainerMargin,
                                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                                    child: InputDecorator(
                                      decoration:
                                      const InputDecoration(labelText: 'Siirtoyhtiö'),
                                      child: SizedBox(
                                          height: 30,
                                          width: 120,
                                          child: MyDropdownWidget(
                                            keyString: 'electricityDistributionAgreement',
                                              dropdownContent: electricityDistributionAgreement,
                                              setValue: (newValue) {
                                                electricityDistributionAgreement
                                                    .setIndex(newValue);
                                                setState(() {});
                                              })),
                                    ),
                                  ),
                                ),
                                const Spacer(flex: 1),
                                Expanded(
                                    flex: 20,
                                    child: Text(distributorAgreementText(electricityDistributionAgreement.currentIndex()))),
                              ]),
                            ]))),
                    electricityPriceParameters.electricityAgreementIsSpot(electricityAgreement.currentIndex()) ? Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      height: 150,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Spot-hinnan lähde'), //k
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Spacer(),
                              Row(children: <Widget>[
                                const Flexible(flex:1, child: Text('Nimi: ')),
                                Flexible(flex:5, child: AutoSizeText(widget.device.name, style:const TextStyle(fontSize:14,color:Colors.blue))),
                              ]),
                              const Spacer(),
                              Row(children: <Widget>[
                                const Flexible(flex:1, child: Text('Osoite: ')),
                                Flexible(flex:5,
                                    child: AutoSizeText(electricityPriceParameters.basicElectricityParameters.spotAddress,
                                        style:const TextStyle(fontSize:14,color:Colors.blue))),
                              ]),
                              const Spacer(),
                            ]),
                      ),
                    )
                    : emptyWidget(),
                    readyWidget(() async {
                      myElectricityPrice.tariff = _eTariff(electricityAgreement.currentIndex());
                      myElectricityPrice.distributionPrice = _dTariff(electricityDistributionAgreement.currentIndex());
                      await myElectricityPrice.init();
                      /*
                                if (_functionality.currentIndex() == 0) {
                                  PlainSwitchFunctionality newFunctionality = PlainSwitchFunctionality();
                                  newFunctionality.pair(newDevice);
                                  newFunctionality.init();
                                  widget.estate.addFunctionality(newFunctionality);
                                  widget.estate.addView(newFunctionality.myView());
                                  log.info('${widget.estate.name}: laite ${newDevice.name}(${newDevice.id}) asetettu toimintoon "${_functionality.currentString()}"');
                                }
                                else {

                                }


                                widget.estate.addDevice(newDevice);
                                 */
                      showSnackbarMessage('Sähkösopimustiedot päivitetty!');
                      Navigator.pop(context, true);
                    })
                  ])
              )
          );
  }
}

class EditElectricityShortView extends StatefulWidget {
  final Estate estate;
  const EditElectricityShortView({Key? key, required this.estate}) : super(key: key);

  @override
  _EditElectricityShortViewState createState() => _EditElectricityShortViewState();
}

class _EditElectricityShortViewState extends State<EditElectricityShortView> {
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  late ElectricityPrice myElectricityPrice;
  late DropdownContent electricityAgreement; // = DropdownContent([''], '', 0);
  late DropdownContent electricityDistributionAgreement; // = DropdownContent([''], '', 0);

  List <String> eAgreementNames = electricityPriceParameters.electricityAgreementNames();
  List <String> dAgreementNames = electricityPriceParameters.eDistributionNames();

  @override
  void initState() {
    super.initState();

    myElectricityPrice = widget.estate.myDefaultElectricityPrice();

    int eIndex = max(0, eAgreementNames.indexOf(myElectricityPrice.tariff.name));
    electricityAgreement = DropdownContent(electricityPriceParameters.electricityAgreementNames(), '', eIndex);

    int dIndex = max(0, dAgreementNames.indexOf(myElectricityPrice.distributionPrice.name));
    electricityDistributionAgreement = DropdownContent(electricityPriceParameters.eDistributionNames(), '', dIndex);

    refresh();
  }

  void refresh() {
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeWifi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
                        margin: myContainerMargin,
                        padding: myContainerPadding,
                        child: InputDecorator(
                            decoration:
                            const InputDecoration(labelText: 'Sähkö- ja siirtosopimus'), //k
                            child: Row(children: <Widget>[
                                Expanded(
                                  flex: 15,
                                  child: Container(
                                    margin: myContainerMargin,
                                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                                    child: InputDecorator(
                                      decoration:
                                      const InputDecoration(labelText: 'Sähkösopimus'),
                                      child: SizedBox(
                                          height: 30,
                                          width: 120,
                                          child: MyDropdownWidget(
                                              keyString: 'electricityAgreement',
                                              dropdownContent: electricityAgreement,
                                              setValue: (newValue) {
                                                electricityAgreement
                                                    .setIndex(newValue);

                                                myElectricityPrice.tariff = _eTariff(newValue);
                                                setState(() {});
                                              })),
                                    ),
                                  ),
                                ),
                                const Spacer(flex: 1),
                                Expanded(
                                  flex: 15,
                                  child: Container(
                                    margin: myContainerMargin,
                                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
                                    child: InputDecorator(
                                      decoration:
                                      const InputDecoration(labelText: 'Siirtoyhtiö'),
                                      child: SizedBox(
                                          height: 30,
                                          width: 120,
                                          child: MyDropdownWidget(
                                              keyString: 'electricityDistributionAgreement',
                                              dropdownContent: electricityDistributionAgreement,
                                              setValue: (newValue) {
                                                electricityDistributionAgreement
                                                    .setIndex(newValue);
                                                myElectricityPrice.distributionPrice = _dTariff(newValue);
                                                setState(() {});
                                              })),
                                    ),
                                  ),
                                ),
                            ])),
                  );
        }
}
