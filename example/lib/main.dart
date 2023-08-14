// example app deps, not necessarily needed for tor usage
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_libtor/flutter_libtor.dart';
// imports needed for tor usage:
import 'package:flutter_libtor/models/tor_config.dart';
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

  @override
  void initState() {
    unawaited(init());
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    // portController.dispose();
    // passwordController.dispose();
    hostController.dispose();
    super.dispose();
  }

  Future<void> init() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    // int newControlPort = await tor.getRandomUnusedPort(
    //     excluded: [/*int.parse(portController.text)*/]);
    // TorConfig torConfig = new TorConfig(
    //     dataDirectory: appDocDir.path + '/tor',
    //     logFile: appDocDir.path + '/tor/tor.log',
    //     socksPort: int.parse(portController.text),
    //     controlPort: newControlPort,
    //     password: passwordController.text);

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
                //     // TODO add password input and start button to start Tor daemon with password input
                //     const Text(
                //       'Enter the port and password of your Tor daemon/SOCKS5 proxy and press connect'
                //       'See the console logs for your port or ~/Documents/tor/tor.log',
                //       style: textStyle,
                //       textAlign: TextAlign.center,
                //     ),
                //     spacerSmall,
                //     Row(children: [
                //       TextButton(
                //           onPressed: () async {
                //             getPort();
                //           },
                //           child: Text("generate unused port")),
                //       spacerSmall,
                //       Expanded(
                //         child: TextField(
                //             controller: portController,
                //             decoration: const InputDecoration(
                //               border: OutlineInputBorder(),
                //               hintText: 'SOCKS5 proxy port',
                //             )),
                //       ),
                //     ]),
                //     Row(children: [
                //       TextButton(
                //           onPressed: () async {
                //             getPassword();
                //           },
                //           child: Text("generate password")),
                //       spacerSmall,
                //       Expanded(
                //         child: TextField(
                //             controller: passwordController,
                //             decoration: const InputDecoration(
                //               border: OutlineInputBorder(),
                //               hintText: 'password',
                //             )),
                //       ),
                //     ]),
                //     spacerSmall,
                // TextButton(
                //     onPressed: () async {
                //       final Directory appDocDir =
                //           await getApplicationDocumentsDirectory();
                //       int newControlPort = await this.tor.getRandomUnusedPort(
                //           excluded: [int.parse(portController.text)]);
                //
                //       TorConfig torConfig = new TorConfig(
                //           dataDirectory: appDocDir.path + '/tor',
                //           logFile: appDocDir.path + '/tor/tor.log',
                //           socksPort: int.parse(portController.text),
                //           controlPort: newControlPort,
                //           password: passwordController.text);
                //
                //       // Start the Tor daemon
                //       await this
                //           .tor
                //           .start(torDir: Directory(appDocDir.path + '/tor'));
                //       print('done awaiting');
                //     },
                //     child: Text("start tor")),
                // spacerSmall,
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
                        print(
                            responseString); // if host input left to default icanhazip.com, a Tor exit node IP should be printed to the console

                        // Close client
                        client.close();
                      },
                      child: const Text("make proxied request")),
                ]),
                spacerSmall,
                TextButton(
                    onPressed: () async {
                      // TODO check that tor is running'
                      String targetHost = 'bitcoincash.stackwallet.com';
                      int targetPort = 50001;

                      String socksLogin = '';
                      String socksPassword = '';

                      // Establish a TCP connection with the socks5 server
                      Socket socket = await Socket.connect(
                          InternetAddress.loopbackIPv4, tor.port);

                      // Here, it is recorded at which stage the communication with the server is
                      Socks5 step = Socks5.init;

                      // Server response result
                      int result = 0;

                      // IP address given by the server after successful connection establishment
                      InternetAddress ip = InternetAddress('8.8.8.8');

                      // Port issued by the server after successful connection establishment
                      int port = 80;

                      // Completer is necessary for synchronizing requests
                      Completer completer = Completer();

                      // Listen to the server's response
                      // data is List<int> (bytes with information from the server)
                      socket.listen((data) async {
                        // The request result (success/failure etc.) is passed in data[1]
                        result = data[1];

                        // If the CONNECT command was executed, then from the server's response, you can extract the ip and port
                        // issued by the server for communication with the target host
                        if (step == Socks5.connect) {
                          // data[3] determines in which format the address is provided
                          if (data[3] == 1) {
                            // data[3] == 1 - address in IPv4 format
                            ip = new InternetAddress(
                                data.sublist(4, 8).join('.'));
                          } else if (data[3] == 3) {
                            //data[3] == 3 - address as a domain name
                            ip = (await InternetAddress.lookup(
                                new String.fromCharCodes(
                                    data.sublist(5, 5 + data[4])),
                                type: InternetAddressType.IPv4))[0];
                          }
                          port = int.parse('0x' +
                              data
                                  .sublist(data.length - 2)
                                  .map((int byte) => byte.toRadixString(16))
                                  .join());
                        }
                        completer.complete();
                      });

                      // First step
                      step = Socks5.init;
                      print('Connecting to the socks5 server...');
                      // completer = Completer();
                      // The request format can be found in RFC 1928
                      socket.add([0x05, 0x02, 0x00, 0x02]);
                      await completer.future;
                      if (result == 0xff) {
                        print(
                            'The specified authentication methods are not supported');
                        socket.close();
                        exit(1);
                      }
                      print('done');

                      // If the server selected the authentication method by username and password (2),
                      // then perform authentication
                      if (result == 2) {
                        step = Socks5.auth;
                        print('Authentication');
                        completer = new Completer();
                        List<int> loginBytes = socksLogin.codeUnits;
                        List<int> passwordBytes = socksPassword.codeUnits;

                        // Forming an authentication request
                        // Request format, see RFC 1929
                        List<int> authRequest = [1];
                        authRequest.add(loginBytes.length);
                        authRequest.addAll(loginBytes);
                        authRequest.add(passwordBytes.length);
                        authRequest.addAll(passwordBytes);

                        socket.add(authRequest);

                        await completer.future;
                        if (result != 0) {
                          print('Incorrect login or password');
                          socket.close();
                          exit(1);
                        }
                        print('Ok');
                      }

                      // Establish a connection to the target host
                      step = Socks5.connect;
                      print('Establishing a connection...');
                      completer = new Completer();
                      List<int> targetHostBytes = targetHost.codeUnits;
                      String hexTargetPortString =
                          targetPort.toRadixString(16).padLeft(4, '0');
                      Iterable<int> targetPortBytes = [
                        hexTargetPortString.substring(0, 2),
                        hexTargetPortString.substring(2)
                      ].map((String byte) => int.parse(byte, radix: 16));
                      List<int> connectRequest = [5, 1, 0, 3];
                      connectRequest.add(targetHostBytes.length);
                      connectRequest.addAll(targetHostBytes);
                      connectRequest.addAll(targetPortBytes);
                      socket.add(connectRequest);
                      await completer.future;
                      print(ip);
                      print(port);
                      // Here, presumably, there should be communication with the target host
                      socket.close();
                      // TODO request server features
                    },
                    child: const Text(
                        "connect to bitcoincash.stackwallet.com:50002")),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // getPort() async {
  //   portController.text = "${await this.tor.getRandomUnusedPort()}";
  // }
  //
  // getPassword() async {
  //   passwordController.text = "${await this.tor.generatePassword()}";
  // }
}

enum Socks5 { init, auth, connect }
