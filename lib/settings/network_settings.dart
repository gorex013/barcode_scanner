import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class NetworkSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NetworkSettings();
}

class _NetworkSettings extends State<NetworkSettings> {
  var hostController = TextEditingController();
  var portController = TextEditingController();
  var pressedResetHost = false;
  var pressedResetPort = false;

  readHost() async {
    final directory = await getApplicationDocumentsDirectory();
    final hostFile = File('${directory.path}/host.data');
    if (!await hostFile.exists()) {
      return null;
    }
    var host = utf8.decode(await hostFile.readAsBytes());
    if (host.isEmpty) return null;
    return host;
  }

  readPort() async {
    final directory = await getApplicationDocumentsDirectory();
    final portFile = File('${directory.path}/port.data');
    if (!await portFile.exists()) {
      return null;
    }
    var port = utf8.decode(await portFile.readAsBytes());
    if (port.isEmpty) return null;
    return port;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FutureBuilder(
            future: readHost(),
            builder: (context, snapshot) {
              var apiKeyTextField = Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: hostController,
                  keyboardType: TextInputType.number,
//                  inputFormatters: [
//                    FilteringTextInputFormatter(
//                      RegExp(r'[0-9]'),
//                      allow: true,
//                    )
//                  ],
                  decoration: InputDecoration(
                    labelText: "Adresa IP:",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () async {
                        setState(() {
                          hostController.text = "";
                          pressedResetHost = true;
                        });
                      },
                    ),
                  ),
                ),
              );

              if (snapshot.hasData && !pressedResetHost) {
                hostController.text = snapshot.data;
              }
              return apiKeyTextField;
            },
          ),
          FutureBuilder(
            future: readPort(),
            builder: (context, snapshot) {
              var apiKeyTextField = Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: portController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Port:",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () async {
                        setState(() {
                          portController.text = "";
                          pressedResetPort = true;
                        });
                      },
                    ),
                  ),
                ),
              );

              if (snapshot.hasData && !pressedResetPort) {
                portController.text = snapshot.data;
              }
              return apiKeyTextField;
            },
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        child: RaisedButton.icon(
          onPressed: () async {
            final directory = await getApplicationDocumentsDirectory();
            final hostFile = File('${directory.path}/host.data');
            hostFile.writeAsBytes(utf8.encode(hostController.text));
            final portFile = File('${directory.path}/port.data');
            portFile.writeAsBytes(utf8.encode(portController.text));
            Navigator.pop(context, true);
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          label: Text("Salvare"),
          icon: Icon(Icons.done),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
