import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class APIKeySettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _APIKeySettings();
}

class _APIKeySettings extends State<APIKeySettings> {
  readKey() async {
    final directory = await getApplicationDocumentsDirectory();
    final apiFile = File('${directory.path}/warehouse.key');
    final apiKey = utf8.decode(await apiFile.readAsBytes());
    return apiKey;
  }

  var apiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: readKey(),
        builder: (context, snapshot) {
          var apiKeyTextField = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: apiKeyController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "API key:",
                suffixIcon: IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () async {
                    setState(() {
                      apiKeyController.text = "";
                    });
                    final directory = await getApplicationDocumentsDirectory();
                    final apiFile = File('${directory.path}/warehouse.key');
                    apiFile.writeAsBytes(utf8.encode(apiKeyController.text));
                    Navigator.pop(context,false);
                  },
                ),
              ),
            ),
          );

          if (snapshot.hasData) {
            apiKeyController.text = snapshot.data;
          }
          return apiKeyTextField;
        },
      ),
//      floatingActionButton: SizedBox(
//        width: MediaQuery.of(context).size.width - 20,
//        child: RaisedButton.icon(
//          onPressed: () async {
//            final directory = await getApplicationDocumentsDirectory();
//            final apiFile = File('${directory.path}/warehouse.key');
//            apiFile.writeAsBytes(utf8.encode(apiKeyController.text));
//            Navigator.pop(context, true);
//          },
//          shape:
//              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//          label: Text("Salvare"),
//          icon: Icon(Icons.done),
//        ),
//      ),
//      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
