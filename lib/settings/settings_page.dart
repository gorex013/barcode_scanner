import 'package:barcode_scanner/settings/auth_settings.dart';
import 'package:barcode_scanner/settings/network_settings.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _APIKeySettingsPage();
}

class _APIKeySettingsPage extends State<SettingsPage> {
  bool auth = false;
  bool net = true;
  final netBody = NetworkSettings();

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
      body:netBody,
    );
  }
}
