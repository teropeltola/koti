import 'dart:io'; // Crucial for InternetAddress
import 'dart:async';
import 'dart:typed_data'; // For Uint8List in NsdServiceInfo
import 'package:flutter_nsd/flutter_nsd.dart'; // The correct package import

// Define your service type (e.g., Shelly's mDNS type)
const String SHELLY_SERVICE_TYPE = '_shelly._tcp';

class NsdDiscoveryManager {
  // Use the singleton instance provided by the package
  final FlutterNsd _nsdPlugin = FlutterNsd(); // was .instance;
  StreamSubscription<NsdServiceInfo>? _discoveryEventSubscription;

  // Stream to output the preferred IPv4 addresses found by your logic
  final StreamController<String> _ipv4AddressController = StreamController.broadcast();
  Stream<String> get ipv4AddressStream => _ipv4AddressController.stream;

  Future<void> startDiscovery() async {
    // Ensure any previous discovery is properly stopped before starting a new one
    await stopDiscovery();

    print('Starting NSD discovery for service type: $SHELLY_SERVICE_TYPE');

    // 1. Subscribe to the stream where discovery events will be pushed.
    // This stream provides NsdServiceInfo objects as services are found/updated/lost.
    _discoveryEventSubscription = _nsdPlugin.stream.listen(
          (NsdServiceInfo serviceInfo) async {
        // The stream can emit events for service lost, etc., where 'name' might be null.
        // We are interested in actual service info.
        if (serviceInfo.name == null) {
          print('Received incomplete serviceInfo (e.g., status update): $serviceInfo');
          return;
        }

        print('Discovered/Updated service: ${serviceInfo.name}');
        print('  Hostname: ${serviceInfo.hostname}');
        print('  Port: ${serviceInfo.port}');
        print('  Host Addresses (raw from plugin): ${serviceInfo.hostAddresses}');

        String? preferredIPv4;

        // 1. Prioritize checking hostAddresses list (works well on Android, etc.)
        if (serviceInfo.hostAddresses != null && serviceInfo.hostAddresses!.isNotEmpty) {
          for (String addrString in serviceInfo.hostAddresses!) {
            final InternetAddress? addr = InternetAddress.tryParse(addrString);

            if (addr != null && addr.isIPv4) {
              preferredIPv4 = addr.address;
              print('  Found IPv4 in hostAddresses: $preferredIPv4');
              break; // Found an IPv4, take the first one and exit loop
            }
          }
        }

        // 2. Fallback for iOS (where hostAddresses might be null)
        // and other cases where hostAddresses might be empty/non-IPv4,
        // if a hostname is available.
        // We use !Platform.isAndroid to cover iOS and other non-Android platforms
        // where hostAddresses might not be populated directly.
        if (preferredIPv4 == null && serviceInfo.hostname != null && !Platform.isAndroid) {
          try {
            print('  Falling back to InternetAddress.lookup for IPv4 on hostname: ${serviceInfo.hostname}');
            // InternetAddress.lookup performs a DNS lookup.
            // This can be slower and relies on DNS servers resolving local mDNS names.
            final List<InternetAddress> addresses = await InternetAddress.lookup(serviceInfo.hostname!);
            for (InternetAddress addr in addresses) {
             if (addr.isIPv4) {
                preferredIPv4 = addr.address;
                print('  Found IPv4 via hostname lookup: $preferredIPv4');
                break;
             // }
            }
          } catch (e) {
            print('  Error during hostname lookup for ${serviceInfo.hostname}: $e');
          }
        }

        if (preferredIPv4 != null) {
          _ipv4AddressController.add(preferredIPv4); // Add to your stream for UI/connection logic
        } else {
          print('  No IPv4 address found for ${serviceInfo.name} after all attempts.');
        }
      },
      onError: (e) {
        print('NSD Discovery Stream Error: $e');
      },
      onDone: () {
        print('NSD Discovery Stream Done.');
      },
    );

    // 2. Now, initiate the discovery process itself.
    // This method returns a Future<void> and signals that the discovery has been started.
    try {
      await _nsdPlugin.startDiscovery(SHELLY_SERVICE_TYPE);
      print('NSD Discovery started successfully.');
    } catch (e) {
      print('Failed to start NSD discovery: $e');
      // If starting fails, ensure the stream subscription is cancelled
      await stopDiscovery();
    }
  }

  Future<void> stopDiscovery() async {
    // Cancel the stream subscription first to stop processing events
    if (_discoveryEventSubscription != null) {
      await _discoveryEventSubscription!.cancel();
      _discoveryEventSubscription = null;
    }

    // Then, tell the native plugin to stop discovery
    try {
      await _nsdPlugin.stopDiscovery();
      print('NSD Discovery stopped successfully.');
    } catch (e) {
      print('Failed to stop NSD discovery: $e');
    }
  }

  void dispose() {
    // Ensure all resources are cleaned up
    stopDiscovery(); // Ensure discovery is stopped
    _ipv4AddressController.close(); // Close the stream controller
    print('NSD Discovery Manager disposed.');
  }
}

// --- Example Usage in your Widget/State's initState/dispose ---
void maxxin() {
  final manager = NsdDiscoveryManager();

  // Listen to the stream of found IPv4 addresses
  manager.ipv4AddressStream.listen((ipv4) {
    print('\n*** App received a NEW/UPDATED IPv4 address from stream: $ipv4 ***');
    // Here you would typically update your UI or initiate a connection
  });

  // Start discovery when your app/widget initializes
  manager.startDiscovery();

  // Simulate app lifecycle: stop discovery after some time
  Future.delayed(Duration(seconds: 45), () {
    print('\n--- Simulating app closing, stopping discovery ---');
    manager.stopDiscovery();
    manager.dispose();
  });
}