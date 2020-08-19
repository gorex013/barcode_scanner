import 'package:barcode_scanner/settings/api_key_settings.dart';
import 'package:barcode_scanner/settings/auth_settings.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final host;
  final port;

  const SettingsPage({Key key, this.host, this.port}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _APIKeySettingsPage();
}

class _APIKeySettingsPage extends State<SettingsPage> {

  bool body=true;
  final authBody = AuthSettings();
  final apiBody = APIKeySettings();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Setare access"),
      ),
      body: (body)?authBody:apiBody,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () {
                setState(() {
                  body = true;
                });
              },
              icon: Icon(Icons.account_circle),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  body = false;
                });
              },
              icon: Icon(Icons.vpn_key),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      ),
    );
  }
}
