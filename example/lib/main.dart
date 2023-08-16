// example app deps, not necessarily needed for tor usage
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_libtor/flutter_libtor.dart';
// imports needed for tor usage:
import 'package:flutter_libtor/models/tor_config.dart';
<<<<<<< HEAD
=======
import 'package:flutter_libtor_example/socks5.dart';
>>>>>>> socks5
import 'package:path_provider/path_provider.dart';
import 'package:socks5_proxy/socks_client.dart'; // just for example; can use any socks5 proxy package, pick your favorite.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final tor = Tor();
  late TorConfig _torConfig;
  late String? _password;
  // final portController = TextEditingController();
  // final passwordController = TextEditingController();
  final hostController = TextEditingController(text: 'https://icanhazip.com/');
  // https://check.torproject.org is also a good option

  @override
  void initState() {
    unawaited(init());
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    hostController.dispose();
    super.dispose();
  }

  Future<void> init() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
<<<<<<< HEAD
=======
    print('starting tor at');
    print(appDocDir.path);
    // int newControlPort = await tor.getRandomUnusedPort(
    //     excluded: [/*int.parse(portController.text)*/]);
    // TorConfig torConfig = new TorConfig(
    //     dataDirectory: appDocDir.path + '/tor',
    //     logFile: appDocDir.path + '/tor/tor.log',
    //     socksPort: int.parse(portController.text),
    //     controlPort: newControlPort,
    //     password: passwordController.text);

>>>>>>> socks5
    // Start the Tor daemon
    _torConfig = await tor.start(torDir: Directory('${appDocDir.path}/tor'));
    _password = _torConfig.password;
    print('done awaiting; tor should be running');
  }

  @override
  Widget build(BuildContext context) {
    // const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tor example'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    child: TextField(
                        controller: hostController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'host to request',
                        )),
                  ),
                  spacerSmall,
                  TextButton(
                      onPressed: () async {
                        // socks5_proxy package example; use socks5 connection of your choice
                        // Create HttpClient object
                        final client = HttpClient();

                        // Assign connection factory
                        SocksTCPClient.assignToHttpClient(client, [
                          ProxySettings(InternetAddress.loopbackIPv4, tor.port,
                              password:
                                  _password), // need to get from tor config file
                        ]);

                        // GET request
                        final request =
                            await client.getUrl(Uri.parse(hostController.text));
                        final response = await request.close();
                        // Print response
                        var responseString = await utf8.decodeStream(response);
                        print(responseString);
                        // if host input left to default icanhazip.com, a Tor exit node IP should be printed to the console. https://check.torproject.org is also good for doublechecking torability

                        // Close client
                        client.close();
                      },
                      child: const Text("make proxied request")),
                ]),
                spacerSmall,
                TextButton(
                    onPressed: () async {
                      // TODO check that tor is running
<<<<<<< HEAD

                      // // custom socks_socket WIP POC
                      // SOCKSSocket socksSocket = SOCKSSocket(
                      //     host: InternetAddress.loopbackIPv4.address,
                      //     port: tor.port);
                      // try {
                      //   await socksSocket.connect();
                      // } catch (e) {
                      //   print(e);
                      // }
                      // try {
                      //   await socksSocket.connectTo(
                      //       'bitcoincash.stackwallet.com', 50001);
                      // } catch (e) {
                      //   print(e);
                      // }

                      // https://github.com/LacticWhale/socks_dart/blob/master/example/client/tcp_1_simple_connect.dart
                      const host = 'bitcoincash.stackwallet.com';
                      const port = 50001;

                      final InternetAddress address;
                      try {
                        // Lookup address
                        address = (await InternetAddress.lookup(host))[0];
                      } catch (e) {
                        // Lookup failed
                        return print(e);
                      }

                      print("connecting to socks socket on ${tor.port}");
                      final Socket proxySocket;
                      try {
                        // Connect to proxy
                        proxySocket = await SocksTCPClient.connect(
                          [
                            ProxySettings(
                                InternetAddress.loopbackIPv4, tor.port),
                          ],
                          address,
                          port,
                        );
=======
                      try {
                        final sock = await RawSocket.connect(
                            InternetAddress.loopbackIPv4, tor.port);
                        final proxy = SOCKSSocket(sock);
                        await proxy
                            .connect('bitcoincash.stackwallet.com:50001');

                        proxy.onData.listen((data) {
                          print('Received from proxy: $data');
                        });
>>>>>>> socks5
                      } catch (e) {
                        print(e);
                        return;
                      }

<<<<<<< HEAD
                      print("listening to socks socket on ${tor.port}");
                      // Receive data from proxy
                      proxySocket
                        ..listen((event) {
                          print(ascii.decode(event));

                          exit(0);
                        })
                        // Send data to client
                        // proxyClient.add(Uint8List.fromList([0x01, 0x02, 0x03]));
//                         ..write(
//                           '''HEAD / HTTP/1.1
// HOST: example.com
// Connection: close
//
//
// ''',
                        ..write(jsonEncode({
                          "jsonrpc": "2.0",
                          "id": "0",
                          "method": "server.features",
                          "params": []
                        }));
                      // await proxySocket.flush();
                      // await proxySocket.close();

                      Future.delayed(const Duration(seconds: 30), () {
                        print(
                            'Timeout. Target haven\'t replied in given time.');
                        proxySocket.flush();
                        proxySocket.close();
                        exit(0);
                      });

=======
>>>>>>> socks5
                      // TODO request server features
                    },
                    child: const Text(
                        "connect to bitcoincash.stackwallet.com:50001")),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum Socks5 { init, auth, connect }
