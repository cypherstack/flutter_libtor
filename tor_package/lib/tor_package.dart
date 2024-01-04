library tor_package;

import 'dart:convert';
import 'dart:io';

// Imports needed for tor usage:
import 'package:path_provider/path_provider.dart';
import 'package:socks5_proxy/socks_client.dart'; // Just for example; can use any socks5 proxy package, pick your favorite.
import 'package:tor_ffi_plugin/tor_ffi_plugin.dart';

/// Tor in a package.
///
/// See flutter_libtor testing branch around 2024-02-04 for usage example.
class TorPackage {
  // Flag to track if tor has started.
  bool torIsRunning = false;

  Future<void> startTor() async {
    // Start the Tor daemon.
    await Tor.instance.start(
      torDataDirPath: (await getApplicationSupportDirectory()).path,
    );

    // Toggle started flag.
    torIsRunning = Tor.instance.status == TorStatus.on; // Update flag.

    print('Done awaiting, Tor should be running.');
  }

  Future<String> iCanHazIp() async {
    // `socks5_proxy` package example
    final client = HttpClient();
    SocksTCPClient.assignToHttpClient(client, [
      ProxySettings(InternetAddress.loopbackIPv4, Tor.instance.port,
          password: null), // TODO Need to get from tor config file.
    ]);

    final request = await client.getUrl(Uri.parse(
        'https://icanhazip.com/')); // See also https://check.torproject.org
    final response = await request.close();

    var responseString = await utf8.decodeStream(response);
    print("tor_package: $responseString");

    client.close();
    return responseString;
  }
}
