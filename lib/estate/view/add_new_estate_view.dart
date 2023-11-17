import 'package:flutter/material.dart';
import 'package:koti/devices/plain_switch_functionality/view/plain_switch_functionality_view.dart';
import 'package:koti/devices/wlan/active_wifi_name.dart';
import 'package:provider/provider.dart';

import '../../devices/plain_switch_functionality/plain_switch_functionality.dart';
import '../../logic/dropdown_content.dart';
import '../../network/electricity_price/electricity_price.dart';
import '../../network/electricity_price/view/electricity_price_view.dart';
import '../estate.dart';
import '../../look_and_feel.dart';
import '../../main.dart';
import '../../view/my_dropdown_widget.dart';

DropdownContent _electricityAgreement = DropdownContent(
    ['', 'Fortum/Tarkka', 'XXX', 'YY', 'ZZZ'], 'electricity/agreement', 0);

DropdownContent _electricityTransferAgreement = DropdownContent(
    ['', 'Helen', 'XXX', 'YY', 'ZZZ'], 'electricity/transfer', 0);

class AddNewEstateView extends StatefulWidget {
  const AddNewEstateView({Key? key}) : super(key: key);

  @override
  _AddNewEstateViewState createState() => _AddNewEstateViewState();
}

class _AddNewEstateViewState extends State<AddNewEstateView> {
  Estate newEstate = Estate();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeWifi = FocusNode();
  final myEstateNameController = TextEditingController();
  List<String> shellyServices = [];

  @override
  void initState() {
    super.initState();
    shellyServices = shellyScan.listPossibleServices();
    newEstate.init('','e1',activeWifiName.activeWifiName, activeWifiBroadcaster);
    newEstate.addView(ElectricityGridBlock(myElectricityPrice));
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
    return Consumer<ActiveWifiName>(
      builder: (context, myActiveWifi, childNotUsed) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Palaa takaisin lisäämättä uutta asuntoa',
                onPressed: () async {
                  // check if the user wants to cancel all the changes
                  bool? doExit = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                          title: const Text(
                              'Poistuttaessa uusi asunto ei säily.',
                              textScaleFactor: myAlertDialogTitleScale),
                          content:
                          const Text('Haluatko poistua lisäyssivulta ?'),
                          actions: <Widget>[
                            TextButton(
                                child: const Text('Kyllä'),
                                onPressed: () async {
                                  Navigator.pop(dialogContext, true);
                                }),
                            TextButton(
                              child: const Text('En'),
                              onPressed: () {
                                Navigator.pop(dialogContext, false);
                              },
                            )
                          ]);
                    },
                  );
                  doExit ??= false;
                  if (doExit) {
                    Navigator.of(context).pop();
                  }
                }),
            title: appTitle('uusi asunto'),
          ), // new line
          body: SingleChildScrollView(
              child: Column(children: <Widget>[
                Container(
                margin: myContainerMargin,
                padding: myContainerPadding,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Asunnon tiedot'), //k
                  child: Column(children: <Widget>[
                    TextField(
                        key: const Key('estateName'),
                        decoration: const InputDecoration(
                          labelText: 'asunnon nimi',
                          hintText: 'kirjoita tähän asunnolle nimi, esim. koti',
                        ),
                        focusNode: _focusNode,
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        controller: myEstateNameController,
                        maxLines: 1,
                        onChanged: (String newText) {
                          newEstate.name = newText;
                        },
                        onEditingComplete: () {
                          _focusNode.unfocus();
                        }),
                    const Text(''),
                    TextFormField(
                        key: const Key('wifiName'),
                        decoration: const InputDecoration(
                          labelText: 'wifi-verkon nimi (oletuksena nykyinen)',
                          hintText: 'oletusarvona on nykyinen wifi',
                        ),
                        focusNode: _focusNodeWifi,
                        initialValue: myActiveWifi.activeWifiName,
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        maxLines: 1,
                        onChanged: (String newWifi) {
                          newEstate.changeWifiName(newWifi);
                          setState(() { });
                        },
                        onEditingComplete: () {
                          _focusNodeWifi.unfocus();
                        }),
                  ]),
                ),
              ),
              Container(
                  margin: myContainerMargin,
                  padding: myContainerPadding,
                  child: InputDecorator(
                      decoration:
                      const InputDecoration(labelText: 'Sähkön kustannus'), //k
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
                          const Expanded(
                              flex: 20,
                              child: Text('Fortum/Tarkka:\n'
                                  '- pörssisähkö + alv\n'
                                  '- marginaali: 0.45 c/kWh')),
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
                                        dropdownContent: _electricityTransferAgreement,
                                        setValue: (newValue) {
                                          _electricityTransferAgreement
                                              .setIndex(newValue);
                                          setState(() {});
                                        })),
                              ),
                            ),
                          ),
                          const Spacer(flex: 1),
                          const Expanded(
                              flex: 20,
                              child: Text('Helen:\n'
                                  '- sähkövero 2,79372 c/kWh\n'
                                  '- siirto päivä(7-22): 2.59 c/kWh\n'
                                  '- siirto yö(22-7): 1.35 c/kWh')),
                        ]),
                      ]))),
              Container(
                  margin: myContainerMargin,
                  padding: myContainerPadding,
                  child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Automaattisesti liitettävät laitteet'),
                      child: newEstate.iAmActive
                        ? shellyServices.isEmpty
                            ? const Text('Paikallisverkossa ei ole yhtään liitettävää laitetta')
                            : ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: shellyServices.length,
                                  itemBuilder: (context, index) => Card(
                                    elevation: 6,
                                    margin: const EdgeInsets.all(10),
                                      child: ListTile(
                                        title: Text(shellyServices[index]),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.add_home_work,
                                                  color: Colors.black, size: 40),
                                              tooltip: 'Lisää asunnon laitteisiin',
                                              onPressed: () async {
                                                //newEstate.addDevice
                                                //todo: lisää systeemiin
                                                refresh();
                                                setState(() {});
                                              })
                                      )
                                  )
                              )
                        : const Text('Et ole nyt liitettävän asunnon wifi-verkossa')
                  )
              ),
                      Container(
                          margin: myContainerMargin,
                          padding: myContainerPadding,
                          child: Tooltip(
                              message:
                              'Paina tästä tallettaessa havainto ja poistu näytöltä',
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
                                  myEstates.addEstate(newEstate);
                                  myEstates.pushCurrent(newEstate);
                                  //////////////
                                  PlainSwitchFunctionality p = PlainSwitchFunctionality();
                                  p.name = 'Valot';
                                  newEstate.addFunctionality(p);
                                  newEstate.addView(PlainSwitchFunctionalityView(p));
                                  //////////////
                                  showSnackbarMessage('kohde lisätty!');
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
