
import 'dart:io';
import 'dart:ui';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

import 'package:koti/app_configurator.dart';
import 'package:koti/functionalities/electricity_price/json/electricity_price_parameters.dart';
import 'package:koti/interfaces/foreground_interface.dart';
import 'package:koti/logic/observation.dart';

import 'package:koti/devices/wlan/connection_status_listener.dart';
import 'devices/device/device.dart';
import 'devices/my_device_info.dart';
import 'devices/shelly/shelly_scan.dart';
import 'devices/wlan/active_wifi_name.dart';
import 'estate/estate.dart';
import 'estate/view/edit_estate_view.dart';
import 'estate/view/estate_page_view.dart';
import 'functionalities/functionality/functionality.dart';
import 'logic/events.dart';
import 'my_task_handler.dart';
import 'trend/trend.dart';
import 'look_and_feel.dart';
import 'operation_modes/operation_modes.dart';

Future<void> _requestFlutterForegroundTaskPermissions() async {
  // Android 13+, you need to allow notification permission to display foreground service notification.
  //
  // iOS: If you need notification, ask for permission.
  final NotificationPermission notificationPermission =
  await FlutterForegroundTask.checkNotificationPermission();
  if (notificationPermission != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }

  if (Platform.isAndroid) {
    // Android 12+, there are restrictions on starting a foreground service.
    //
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Use this utility only if you provide services that require long-term survival,
    // such as exact alarm service, healthcare service, or Bluetooth communication.
    //
    // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
    // Using this permission may make app distribution difficult due to Google policy.
    if (!await FlutterForegroundTask.canScheduleExactAlarms) {
      // When you call this function, will be gone to the settings page.
      // So you need to explain to the user why set it.
      await FlutterForegroundTask.openAlarmsAndRemindersSettings();
    }
  }
}

Future <void> getPermissions() async {

// You can request multiple permissions at once.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
  ].request();

  await _requestFlutterForegroundTaskPermissions();
}

bool runningInSimulator = false;

ConnectionStatusListener connectionStatusListener = ConnectionStatusListener(activeWifiName);

Future <void> resetAllFatal() async {
  await myEstates.resetAll();
  allFunctionalities.clear();
  allDevices.clear();
  log.cleanHistory();
  const FlutterSecureStorage().deleteAll();

  applicationDeviceConfigurator.initConfiguration();
}

Future <void> appInitializationRoutines() async {
  //DartPluginRegistrant.ensureInitialized();
  await initMySettings();
  FlutterForegroundTask.initCommunicationPort();
  registerOperationModeTypes();
  await getPermissions();
  runningInSimulator = await isSimulator();

  await Hive.initFlutter();
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());

  applicationDeviceConfigurator.initConfiguration();

  await foregroundInterface.init();

  await shellyScan.init();

  await connectionStatusListener.initialize();

  await trend.init();

  await events.init();

  await myEstates.init();

  //electricityPriceParameters.init();
  electricityPriceParameters = await readElectricityPriceParameters();

  events.write('','',ObservationLevel.ok,'$appName käynnistyi (laitteen wifi on "${activeWifiName.activeWifiName}")');

  await foregroundInterface.initDataStructures();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appInitializationRoutines();
  //await resetAllFatal();

  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  void initState() {
    super.initState();
    // Add a callback to receive data sent from the TaskHandler.
    //foregroundInterface.init();
  }

  @override
  void dispose() {
    // Remove a callback to receive data sent from the TaskHandler.
    //foregroundInterface.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (myEstates.nbrOfEstates() == 0) {
      return FirstPage( callback: () {setState(() {});});
    }
    else {
      return EstatePageView(callback: () {setState(() {});});
    }
  }
}

class FirstPage extends StatefulWidget {
  final Function callback;
  const FirstPage({Key? key, required this.callback}) : super(key: key);

  @override
    _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: appIconAndTitle(appName, 'Tervetuloa'),
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
              Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(5),
                  child: const InputDecorator(
                    decoration: InputDecoration(labelText: 'Tervetuloa!'),
                    child: Column(children: <Widget>[
                      Center(child: Text(
                          'Tervetuloa käyttämään $appName-sovellusta!\n'
                              'Sovelluksella hallitaan oman kodin ja mahdollisten muiden asuntojen automaatiota. \n'
                              'Katso lyhyt esittelyvideo täältä: xxx \n'
                              'Tai voit perehtyä tarkemmin sovelluksen toimintaan täältä: yyy\n'
                              'Ensimmäiseksi sinun pitää määritellä asunto, jonka laitteita haluat '
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
                                return const EditEstateView(estateName: '');
                              },
                            ));
                            widget.callback();
                          },
                          child: const Text(
                            'Määrittele hallittava kohde',
                            maxLines: 1,
                            style: TextStyle(color: mySecondaryFontColor),
                            textScaler: TextScaler.linear(1.5),
                          )
                      ))),
            ])
        )
    );
  }
}
