import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:koti/devices/wlan/active_wifi_name.dart';
import 'package:koti/functionalities/plain_switch_functionality/plain_switch_functionality.dart';
import 'package:provider/provider.dart';

import '../../../devices/device/device.dart';
import '../../../estate/estate.dart';
import '../../../functionalities/functionality/functionality.dart';
import '../../../logic/dropdown_content.dart';
import '../../../look_and_feel.dart';
import '../../../view/my_dropdown_widget.dart';
import '../electricity_price.dart';
import '../json/electricity_price_parameters.dart';


late DropdownContent _electricityAgreement;
//= DropdownContent([''], 'electricity/agreement', 0);

late DropdownContent _electricityDistributionAgreement;
// = DropdownContent([''], 'electricity/distribution', 0);

late ElectricityPriceParameters electricityPriceParameters;

bool _spot() {
  int index = _electricityAgreement.currentIndex()-1;
  if (index < 0) {
    return false;
  }
  else {
    return electricityPriceParameters.electricity[index].eTemplateName == 'eSpot';
  }
}

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
String eAgreementText() {
  int index = _electricityAgreement.currentIndex()-1;
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

ElectricityTariff _eTariff() {
  int index = _electricityAgreement.currentIndex() - 1;
  ElectricityTariff e = ElectricityTariff();
  if (index < 0) {
    e.setValue('', TariffType.constant, 0);
  }
  else {
    e.setValue(
        electricityPriceParameters.electricity[index].eName,
        _spot() ? TariffType.spot : TariffType.constant,
        electricityPriceParameters.electricity[index].par1);
  }
  return e;
}

String distributorAgreementText() {
  int index = _electricityDistributionAgreement.currentIndex()-1;
  if (index < 0) {
    return 'Ei määritelty';
  }
  else {
    return eDistributionText(
        electricityPriceParameters.eDistribution[index],
        electricityPriceParameters.basicElectricityParameters.electricityTax);
  }
}

ElectricityDistributionPrice _dTariff() {
  int index = _electricityDistributionAgreement.currentIndex()-1;
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



Future <void> initElectricityAgreementData(Estate estate) async {
  electricityPriceParameters = await readElectricityPriceParameters();

  List <String> eAgreementNames = [''];
  for (int i = 0; i<electricityPriceParameters.electricity.length; i++) {
    eAgreementNames.add(electricityPriceParameters.electricity[i].eName);
  }
 _electricityAgreement = DropdownContent(eAgreementNames, 'electricity/a/${estate.name}', 0);

  List <String> eDistributionNames = [''];
  for (int i = 0; i<electricityPriceParameters.eDistribution.length; i++) {
    eDistributionNames.add(electricityPriceParameters.eDistribution[i].dName);
  }
  _electricityDistributionAgreement = DropdownContent(eDistributionNames, 'electricity/d/${estate.name}', 0);
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

  @override
  void initState() {
    super.initState();
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
    return Consumer<Estate>(
        builder: (context, estate, childNotUsed) {
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
                title: appTitle('Sähkösopimukset'),
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
                                              dropdownContent: _electricityAgreement,
                                              setValue: (newValue) {
                                                _electricityAgreement
                                                    .setIndex(newValue);
                                                setState(() {});
                                              })),
                                    ),
                                  ),
                                ),
                                const Spacer(flex: 1),
                                Expanded(
                                    flex: 20,
                                    child: Text(eAgreementText())),
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
                                              dropdownContent: _electricityDistributionAgreement,
                                              setValue: (newValue) {
                                                _electricityDistributionAgreement
                                                    .setIndex(newValue);
                                                setState(() {});
                                              })),
                                    ),
                                  ),
                                ),
                                const Spacer(flex: 1),
                                Expanded(
                                    flex: 20,
                                    child: Text(distributorAgreementText())),
                              ]),
                            ]))),
                    _spot() ? Container(
                      margin: myContainerMargin,
                      padding: myContainerPadding,
                      height: 150,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Spot-hinnan lähde'), //k
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Spacer(),
                              Row(children: <Widget>[
                                Flexible(flex:1, child: Text('Nimi: ')),
                                Flexible(flex:5, child: AutoSizeText(widget.device.name, style:TextStyle(fontSize:14,color:Colors.blue))),
                              ]),
                              Spacer(),
                              Row(children: <Widget>[
                                Flexible(flex:1, child: Text('Osoite: ')),
                                Flexible(flex:5,
                                    child: AutoSizeText(electricityPriceParameters.basicElectricityParameters.spotAddress,
                                        style:TextStyle(fontSize:14,color:Colors.blue))),
                              ]),
                              Spacer(),
                            ]),
                      ),
                    )
                    : emptyWidget(),
                    Container(
                        margin: myContainerMargin,
                        padding: myContainerPadding,
                        child: Tooltip(
                            message:
                            'Paina tästä tallentaaksesi muutokset ja poistuaksesi näytöltä',
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  backgroundColor: mySecondaryColor,
                                  side: const BorderSide(
                                      width: 2, color: mySecondaryColor),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                                  elevation: 10),
                              onPressed: () async {
                                  myElectricityPrice.tariff = _eTariff();
                                  myElectricityPrice.distributionPrice = _dTariff();
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
                              },
                              child: const Text(
                                'Valmis',
                                maxLines: 1,
                                style: TextStyle(color: mySecondaryFontColor),
                                textScaleFactor: 2.2,
                              ),
                            ))),
                  ])
              )
          );
        }
    );
  }
}
