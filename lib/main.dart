
import 'package:koti/functionalities/electricity_price/json/electricity_price_parameters.dart';
import 'package:koti/functionalities/electricity_price/view/edit_electricity_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:koti/devices/wlan/connection_status_listener.dart';
import 'package:koti/estate/view/add_new_estate_view.dart';
import 'devices/my_device_info.dart';
import 'devices/shelly/shelly_scan.dart';
import 'devices/wlan/active_wifi_name.dart';
import 'estate/estate.dart';
import 'estate/view/edit_estate_view.dart';
import 'estate/view/estate_view.dart';
import 'functionalities/electricity_price/electricity_price.dart';
import 'logic/service_caller.dart';
import 'look_and_feel.dart';

Future <void> getPermissions() async {

// You can request multiple permissions at once.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
  ].request();
}

bool runningInSimulator = false;

Estates myEstates = Estates();

ConnectionStatusListener connectionStatusListener = ConnectionStatusListener(activeWifiName);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initMySettings();
  await getPermissions();
  runningInSimulator = await isSimulator();
  await shellyScan.init();
  await connectionStatusListener.initialize();
  await myEstates.init();
  //electricityPriceParameters.init();
  electricityPriceParameters = await readElectricityPriceParameters();
  runApp(
    ChangeNotifierProvider<Estate>(
      create: (_) => myEstates.currentEstate(),
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
      return Consumer<Estate>(
          builder: (context, estate, child) =>
              EstateView(callback: () {setState(() {});}));
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
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(5),
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
                          return EditEstateView(estateName:'');
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

