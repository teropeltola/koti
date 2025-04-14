
import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:koti/app_configurator.dart';
import 'package:koti/functionalities/electricity_price/electricity_price_foreground.dart';
import 'package:koti/interfaces/foreground_interface.dart';
import 'package:koti/main.dart';
import 'package:koti/view/data_structure_dump_view.dart';
import 'package:koti/view/temperature_setting_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../devices/device/device.dart';
import '../devices/porssisahko/json/porssisahko_data.dart';
import '../estate/estate.dart';
import '../estate/view/edit_estate_view.dart';
import '../estate/view/estate_list_view.dart';
import '../foreground_configurator.dart';
import '../functionalities/electricity_price/trend_electricity.dart';
import '../functionalities/functionality/functionality.dart';
import '../logic/diagnostics.dart';
import '../logic/events.dart';
import '../logic/observation.dart';
import '../logic/my_workmanager.dart';
import '../trend/trend_event.dart';
import '../look_and_feel.dart';

const _primaryDrawerFontColor = myPrimaryFontColor;
const _primaryDrawerIconSize = 40.0;

Drawer myDrawerView( BuildContext context,
    Function callback) {
  return Drawer(

    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: myPrimaryColor,
          ),
          child: Center(
              child: Image.asset(
                  'assets/images/main_image.png',
                  fit: BoxFit.contain)
          ),
        ),
        ListTile(
          leading: const Icon(Icons.list,
              color: myPrimaryFontColor, size: _primaryDrawerIconSize),
          title: const Text('Asunnot', style: TextStyle(color: _primaryDrawerFontColor)),
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return const EstateListView();
              },
            ));
            callback();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.electrical_services,
              color: myPrimaryFontColor, size: _primaryDrawerIconSize),
          title: const Text('Lisää asunto', style: TextStyle(color: _primaryDrawerFontColor)),
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return const EditEstateView(estateName: '');
              },
            ));
            callback();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
        /*
        ListTile(
          leading: const Icon(Icons.temple_hindu,
              color: _primaryDrawerFontColor, size: _primaryDrawerIconSize),
          title: const Text('Testaa fore', style: TextStyle(color: _primaryDrawerFontColor)),
          onTap: () async {
            var x = foregroundInterface.sendData('xxx',{});

          },
        ),

         */
        ListTile(
          leading: const Icon(Icons.temple_hindu,
              color: _primaryDrawerFontColor, size: _primaryDrawerIconSize),
          title: const Text('Testaa foreground', style: TextStyle(color: _primaryDrawerFontColor)),
          onTap: () async {
            await foregroundInterface.sendData(readDataStructureKey,{});
          }
          ),

        ListTile(
          leading: const Icon(Icons.speaker_notes,
              color: _primaryDrawerFontColor, size: _primaryDrawerIconSize),
          title: const Text('Loki', style: TextStyle(color: _primaryDrawerFontColor)),
          onTap: () async {
            await _callLog(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_tree,
              color: _primaryDrawerFontColor, size: _primaryDrawerIconSize),
          title: const Text('Tietorakenteet', style: TextStyle(color: _primaryDrawerFontColor)),
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const DataStructureDumpView(),
                )
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.manage_search,
              color: _primaryDrawerFontColor, size: _primaryDrawerIconSize),
          title: const Text('Diagnostiikka', style: TextStyle(color: _primaryDrawerFontColor)),
          onTap: () async {
            Diagnostics diagnostics = Diagnostics(myEstates, allDevices, allFunctionalities, applicationDeviceConfigurator);
            bool allGood = diagnostics.diagnosticsOk();
            if (allGood) {
              await informMatterToUser(context, "Kaikki kunnossa!", "Paina ok jatkaaksesi!");
            }
            else {
              await informMatterToUser(context, "Diagnostiikka havaitsi virheitä", "Avataan loki katsoaksesi havaintoja!");
              diagnostics.diagnosticsLog.dumpDiagnosticsLogsToErrorLog();
              await _callLog(context);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.event_note,
              color: _primaryDrawerFontColor, size: _primaryDrawerIconSize),
          title: const Text('Tapahtumaloki', style: TextStyle(color: _primaryDrawerFontColor)),
          onTap: () async {
            Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const EventsView(),
                )
            );
          },
        ),

        /*
        ListTile(
          leading: const Icon(Icons.code,
              color: myPrimaryColor, size: 40),
          title: const Text('Shelly koodi testejä'),
          onTap: () async {
            ShellyScriptAnalysis s = ShellyScriptAnalysis();
            await s.test1();
          }
        ),
        ListTile(
            leading: const Icon(Icons.code,
                color: myPrimaryColor, size: 40),
            title: const Text('Shelly uusi koodi'),
            onTap: () async {
              ShellyScriptAnalysis s = ShellyScriptAnalysis();
              ShellyScriptCode code = ShellyScriptCode();
              await Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return editCode(context, code, (){} );
                },
              ));
              //code.modify();
              code.modifiedCode = code.originalCode;
              await s.test2(code);
            }
        ),
        ListTile(
          leading: const Icon(Icons.price_change,
              color: myPrimaryColor, size: 40),
          title: const Text('Päivitä pörssisähkö'),
          onTap: () async {
            Porssisahko p = myEstates
                .currentEstate()
                .myDefaultElectricityPrice()
                .device as Porssisahko;
            p.myBroadcaster().poke();
          }
        ),

         */
        ListTile(
          leading: const Icon(Icons.restart_alt,
              color: Colors.red, size: _primaryDrawerIconSize),
          title: const Text('Aloita alusta', style: TextStyle(color: _primaryDrawerFontColor)),
          onTap: () async {
            bool ok = await askUserGuidance(context, 'Tämä komento tuhoaa kaikki syötetyt tiedot', 'Oletko varma?');
            if (ok) {
              await resetAllFatal();
              Navigator.pop(context);
            }
            callback();
            if (!context.mounted) return;
          },
        ),
        ListTile(
          leading: const Icon(Icons.arrow_back,
              color: _primaryDrawerFontColor, size: _primaryDrawerIconSize),
          title: const Text('Palaa takaisin', style: TextStyle(color: _primaryDrawerFontColor)),
          onTap: () async {
            callback();
            Navigator.pop(context);
          },
        ),

      ],
    ),
  );
}

Future <void> _callLog(BuildContext context) async {
  Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TalkerScreen(
              talker: log,
              theme: const TalkerScreenTheme(
                  backgroundColor: Colors.white,
                  textColor: Colors.blue,
                  cardColor: Colors.white
              ),
              appBarTitle: 'Loki',
            ),
      )
  );
}

/*
Future <bool> _testHive() async {

  Trend trend = Trend();
  await trend.init();
  int i = 75;
  assert(trend.nbrOfBoxes() == 1);

  TrendBox<TrendEvent> o = trend.open<TrendEvent> ('observations');
  await o.clearForTesting();
  assert(o.boxSize()==0);
  o.add(TrendEvent(DateTime(2024,12,5,20).millisecondsSinceEpoch, 'home', 'device1', ObservationLevel.informatic, 'obs1'));
  List<TrendEvent> all = o.getAll();
  assert(o.boxSize()==1);
  addX(o, 100, DateTime(2024,12,5,21),1);
  all = o.getAll();
  assert(all.length == 101);
  List<TrendEvent> last10 = o.getLastItems(10);
  return true;
}

void addX(TrendBox<TrendEvent> box, int count, DateTime startingTime, int intervalInMinutes) {
  for (int i=0; i<count; i++) {
    box.add(TrendEvent(
        startingTime
            .add(Duration(minutes: i * intervalInMinutes))
            .millisecondsSinceEpoch,
        'home', 'device1', ObservationLevel.ok, 'interval $i'));
  }
}

*/

class EventsView extends StatefulWidget {
  const EventsView({Key? key}) : super(key: key);

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> {

  List<TrendEvent> myEvents = events.getAll();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
                title: appIconAndTitle(appName,'tapahtumat'),
                backgroundColor: myPrimaryColor,
                iconTheme: const IconThemeData(color:myPrimaryFontColor)
            ),// new line
            body: SingleChildScrollView( child: Column(children: <Widget>[
              for (int index=myEvents.length-1; index>=0; index--)
                showEvent(myEvents[index]),
            ]
            )
            ),

            bottomNavigationBar: Container(
              height: bottomNavigatorHeight,
              alignment: AlignmentDirectional.topCenter,
              color: myPrimaryColor,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                        icon: const Icon(Icons.share,
                            color:myPrimaryFontColor,
                            size:40),
                        tooltip: 'jaa näyttö somessa',
                        onPressed: () async {
                        }
                    ),
                  ]),

            )
    );
  }
}

class TestView extends StatefulWidget {
  const TestView({Key? key}) : super(key: key);

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {

  List<TrendEvent> myEvents = events.getAll();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: appIconAndTitle(appName,'testaus'),
            backgroundColor: myPrimaryColor,
            iconTheme: const IconThemeData(color:myPrimaryFontColor)
        ),// new line
        body: SingleChildScrollView( child: Column(children: <Widget>[
          const Text('ttt'),
          TemperatureSettingWidget(currentTarget: 22.0, currentTemperature: 19.0,
              returnValue: (value){}),
          TemperatureSettingWidget(currentTarget: 22.0, currentTemperature: 10.0,
              returnValue: (value){}),
          TemperatureSettingWidget(currentTarget: 22.0, currentTemperature: 30.0,
              returnValue: (value){}),
          TemperatureSettingWidget(currentTarget: 22.0, currentTemperature: 20.0,
              returnValue: (value){}),
        ]
        )
        ),

    );
  }
}

const int _intervalInMinutes = 10;

void _testSetTimer() {
  const Duration delay =  Duration(
    minutes: _intervalInMinutes,
  );

  // Schedule a given time
  Timer timer = Timer(delay, () async {
    events.write(myEstates.currentEstate().id, '', ObservationLevel.ok, "testi jatkuu" );
    _testSetTimer();
  });
}


