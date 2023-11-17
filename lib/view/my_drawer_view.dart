import 'package:flutter/material.dart';

import '../devices/ouman/view/ouman_view.dart';
import '../devices/shelly/shelly.dart';
import '../devices/wlan/find_devices.dart';
import '../estate/view/add_new_estate_view.dart';
import '../look_and_feel.dart';
import '../network/electricity_price/electricity_price.dart';
import '../network/electricity_price/view/electricity_price_view.dart';
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
          leading: const Icon(Icons.electrical_services,
              color: myPrimaryColor, size: 40),
          title: const Text('pörssisähkö'),
          onTap: () async {
            if (! myElectricityPrice.isInitialized()) {
              await myElectricityPrice.init();
            }
            await Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return const ElectricityPriceView();
              },
            ));
            callback();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.gas_meter,
              color: myPrimaryColor, size: 40),
          title: const Text('Ouman'),
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return  const MyOumanApp();
              },
            ));
            callback();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
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
            await device.switchGetStatus();
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
      ],
    ),
  );
}
