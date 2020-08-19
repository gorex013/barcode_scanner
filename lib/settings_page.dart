import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatefulWidget {
  final host;
  final port;

  const SettingsPage({Key key, this.host, this.port}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _APIKeySettingsPage();
}

class _APIKeySettingsPage extends State<SettingsPage> {
  readKey() async {
    final directory = await getApplicationDocumentsDirectory();
    final apiFile = File('${directory.path}/warehouse.key');
    final apiKey = utf8.decode(await apiFile.readAsBytes());
    return apiKey;
  }

  var apiKeyController = TextEditingController();
  var loginController = TextEditingController();
  var passwordController = TextEditingController();
  var pressedReset = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Setare access"),
      ),
      body: FutureBuilder(
          future: readKey(),
          builder: (context, snapshot) {
            var apiKeyTextField = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                autofocus: true,
                controller: apiKeyController,
                decoration: InputDecoration(
                  labelText: "API key:",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        apiKeyController.text = "";
                        pressedReset = true;
                      });
                    },
                  ),
                ),
              ),
            );

            if (snapshot.hasData && !pressedReset) {
              apiKeyController.text = snapshot.data;
            }
            return apiKeyTextField;
          }),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        child: RaisedButton.icon(
          onPressed: () async {
            final directory = await getApplicationDocumentsDirectory();
            final apiFile = File('${directory.path}/warehouse.key');
            apiFile.writeAsBytes(utf8.encode(apiKeyController.text));
            Navigator.pop(context);
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
