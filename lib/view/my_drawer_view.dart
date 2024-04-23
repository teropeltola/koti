import 'package:flutter/material.dart';
import 'package:koti/devices/mitsu_air-source_heat_pump/mitsu_air-source_heat_pump.dart';
import 'package:koti/devices/shelly/shelly_script_code.dart';
import 'package:koti/main.dart';

import '../devices/ouman/view/ouman_view.dart';
import '../devices/shelly/shelly_device.dart';
import '../devices/shelly/shelly_code_editor_view.dart';
import '../devices/shelly/shelly_script_analysis.dart';
import '../devices/wlan/find_devices.dart';
import '../estate/view/add_new_estate_view.dart';
import '../functionalities/electricity_price/electricity_price.dart';
import '../functionalities/electricity_price/view/electricity_price_view.dart';
import '../functionalities/functionality/functionality.dart';
import '../look_and_feel.dart';
import '../operation_modes/view/conditional_option_list_view.dart';
import 'my_talker_view.dart';

Drawer myDrawerView( BuildContext context,
    Function callback) {
  return Drawer(

    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: myPrimaryColor,
          ),
          child: Center(
              child: Text(appName,
                  style: TextStyle(color: Colors.white),
                  textScaleFactor:2)
          ),
        ),
        ListTile(
          leading: const Icon(Icons.electrical_services,
              color: myPrimaryColor, size: 40),
          title: const Text('Lisää asunto'),
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return const AddNewEstateView();
              },
            ));
            callback();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),

        ListTile(
          leading: const Icon(Icons.list,
              color: myPrimaryColor, size: 40),
          title: const Text('listan testaus'),
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return const ReorderableAppTest();
              },
            ));
          }
        ),
        ListTile(
          leading: const Icon(Icons.network_check,
              color: myPrimaryColor, size: 40),
          title: const Text('Scan'),
          onTap: () async {
            String s = await MyNetworkDiscovery().discoverNetworkDeviceIpAddress();
            s = s + await MyNetworkDiscovery().scan();
            s = s + await MyNetworkDiscovery().listBroadcastServices('_http._tcp');
            s = s + await MyNetworkDiscovery().listBroadcastServices('_shelly._tcp');
            await informMatterToUser(context, 'scan', s);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.on_device_training,
              color: myPrimaryColor, size: 40),
          title: const Text('Shelly'),
          onTap: () async {
            ShellyDevice device = ShellyDevice();
            device.setIpAddress('192.168.72.79');
            //await device.sysGetConfig();
            //await device.plugsUiGetConfig();
            await device.switchGetStatus(0);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.speaker_notes,
              color: myPrimaryColor, size: 40),
          title: const Text('Lokit'),
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return  MyTalkerView(talker: log );
              },
            ));
            callback();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
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
          leading: const Icon(Icons.gas_meter,
              color: myPrimaryColor, size: 40),
          title: const Text('Ilpo'),
          onTap: () async {
            MitsuHeatPumpDevice ilpo = MitsuHeatPumpDevice();
            bool loginOK = await ilpo.login();
            if (loginOK) {
              bool deviceListOK = await ilpo.getDevices();
            }
            bool a = false;
            /*
            await Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return  const MyOumanApp();
              },
            ));

             */
            callback();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.restart_alt,
              color: Colors.red, size: 40),
          title: const Text('Aloita alusta'),
          onTap: () async {
            bool ok = await askUserGuidance(context, 'Tämä komento tuhoaa kaikki syötetyt tiedot', 'Oletko varma?');
            if (ok) {
              await myEstates.resetAll();
              allFunctionalities.clear();
              Navigator.pop(context);
            }
            callback();
            if (!context.mounted) return;
          },
        ),

      ],
    ),
  );
}
