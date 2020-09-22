import 'package:flutter/material.dart';
import 'network_settings.dart';

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
