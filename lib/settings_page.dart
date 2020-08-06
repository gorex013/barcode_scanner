import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  readKey() async {
    final directory = await getApplicationDocumentsDirectory();
    final apiFile = File('${directory.path}/warehouse.key');
    final apiKey = utf8.decode(await apiFile.readAsBytes());
    return apiKey;
  }

  var apiKeyController = TextEditingController();
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
            if (snapshot.hasData && !pressedReset) {
              apiKeyController.text = snapshot.data;
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                autofocus: true,
                controller: apiKeyController,
                decoration: InputDecoration(
                    labelText: "API key:",
                    hintText: "Set de caractere random ... ",
                    helperText:
                        "Această cheie o primești de la adminitrator după înregistrare",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        setState(() {
                          apiKeyController.text = "";
                          pressedReset = true;
                        });
                      },
                    )),
              ),
            );
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
