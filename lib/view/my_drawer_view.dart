import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:koti/app_configurator.dart';
import 'package:koti/devices/shelly/shelly_script_code.dart';
import 'package:koti/main.dart';
import 'package:koti/view/data_structure_dump_view.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../devices/device/device.dart';
import '../devices/ouman/view/ouman_view.dart';
import '../devices/porssisahko/porssisahko.dart';
import '../devices/shelly/shelly_device.dart';
import '../devices/shelly/shelly_code_editor_view.dart';
import '../devices/shelly/shelly_script_analysis.dart';
import '../devices/wlan/find_devices.dart';
import '../estate/estate.dart';
import '../estate/view/edit_estate_view.dart';
import '../estate/view/estate_list_view.dart';
import '../functionalities/functionality/functionality.dart';
import '../logic/diagnostics.dart';
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
          decoration: BoxDecoration(
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
                return EditEstateView(estateName: '');
              },
            ));
            callback();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
        /*
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

         */
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
                      DataStructureDumpView(),
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

