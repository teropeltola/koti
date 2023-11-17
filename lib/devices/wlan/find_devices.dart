import 'dart:io';
import 'package:bonsoir/bonsoir.dart';
import 'package:network_discovery/network_discovery.dart';

class MyNetworkDiscovery {


  Future <String> scan() async {
    List <NetworkInterface> interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4, includeLinkLocal: false);

    String s = 'Lkm = ${interfaces.length}\n';
    for (int i=0; i<interfaces.length; i++) {
      s = '$s${interfaces[i]}\n';
    }
    return s;
  }

  Future <String> discoverNetworkDeviceIpAddress() async {

    final String deviceIP = await NetworkDiscovery.discoverDeviceIpAddress();
    if (deviceIP.isEmpty) {
      return 'No NetworkDeviceIPAddresses';
    }
    return 'NetworkDiscovery.discover: $deviceIP\n';
  }

  Future <List<List <String>>> searchBroadcastServices(String type) async {
    List <List <String>> jsonResponses = [];

    BonsoirDiscovery discovery = BonsoirDiscovery(type: type);
    await discovery.ready;

// If you want to listen to the discovery :
    discovery.eventStream!.listen((event) {
      //BonsoirService service = event.service!;
      // `eventStream` is not null as the discovery instance is "ready" !
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        jsonResponses.add( ['Found', event.service?.toJson().toString() ?? '' ]);
        event.service!.resolve(discovery.serviceResolver); // Should be called when the user wants to connect to this service.
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        jsonResponses.add( ['Resolved', event.service?.toJson().toString() ?? '' ]);
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        jsonResponses.add( ['Lost', event.service?.toJson().toString() ?? '' ]);
      }
    });

// Start discovery **after** having listened to discovery events
    await discovery.start();

    await Future.delayed(const Duration(seconds:2));

    // Then if you want to stop the discovery :
    await discovery.stop();

    return jsonResponses;
  }

  Future <String> listBroadcastServices(String type) async {

    List<List <String>> jsonTable = await searchBroadcastServices(type);

    if (jsonTable.isEmpty) {
      return 'Ei palvelu-broadcasteja';
    }
    String s = 'Vastaanotetut palvelu-broadcastit:\n';
    for (int i=0; i<jsonTable.length; i++) {
      s = '$s${jsonTable[i][0]}:${jsonTable[i][1]}\n';
    }
    return s;
  }
}