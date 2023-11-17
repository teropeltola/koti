
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:koti/devices/wlan/connection_status_listener.dart';
import 'package:koti/estate/view/add_new_estate_view.dart';
import 'devices/my_device_info.dart';
import 'devices/shelly/shelly_scan.dart';
import 'devices/wlan/active_wifi_name.dart';
import 'estate/estate.dart';
import 'estate/view/estate_view.dart';
import 'look_and_feel.dart';
import 'network/electricity_price/electricity_price.dart';

Future <bool> getPermissions() async {

// You can request multiple permissions at once.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
  ].request();
  return true;
}

bool runningInSimulator = false;

ShellyScan shellyScan = ShellyScan();

Estates myEstates = Estates();

ConnectionStatusListener connectionStatusListener = ConnectionStatusListener(activeWifiName);

Estates _testEstates() {
  String wifiName = runningInSimulator ? simulatorWifiName() : '"VK3"';

  Estates e = Estates();

  Estate home = Estate();
  home.init('koti','e001', wifiName, activeWifiBroadcaster);
  e.addEstate(home);

  return e;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initMySettings();
  await getPermissions();
  runningInSimulator = await isSimulator();
  await connectionStatusListener.initialize();
  shellyScan.init();
  await myElectricityPrice.init();

  // myEstates = _testEstates();

  runApp(
    ChangeNotifierProvider<ActiveWifiName>(
      create: (_) => activeWifiName,
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: myTheme,
      scaffoldMessengerKey: snackbarKey,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    if (myEstates.nbrOfEstates() == 0) {
      return _firstPage( context, () {setState(() {});});
    }
    else {
      return Consumer<ActiveWifiName>(
          builder: (context, myWifi, child) =>
              EstateView(estate: myEstates.currentEstate()));
    }
  }
}

Widget _firstPage(BuildContext context, Function callback) {
  return Scaffold(
      appBar: AppBar(
        title: appTitle(appName),
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Container(
            margin: myContainerMargin,
            padding: myContainerPadding,
            child: const InputDecorator(
              decoration: InputDecoration(labelText: 'Tervetuloa!'),
              child: Column(children: <Widget>[
                Center(child: Text('Tervetuloa käyttämään $appName-sovellusta!\n'
                    'Sovelluksella hallitaan esim. oman kodin automaatiota. \n'
                    'Voit perehtyä tarkemmin sovelluksen toimintaan täältä: xxx\n'
                    'Ensimmäiseksi sinun pitää määritellä kohde, jonka laitteita haluat '
                    'hallita sovelluksella. ')),
              ]),
            )
          ),
          Container(
              margin: myContainerMargin,
              padding: myContainerPadding,
              child: Tooltip(
                  message:
                  'Paina tästä määritelläksi ensimmäisen hallittavan asunnon tiedot',
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
                      await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const AddNewEstateView();
                        },
                      ));
                      callback();
                    },
                    child: const Text(
                      'Määrittele hallittava kohde',
                      maxLines: 1,
                      style: TextStyle(color: mySecondaryFontColor),
                      textScaleFactor: 1.5,
                    )
                  ))),
        ])
      )
  );
}

