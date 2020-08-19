import 'package:flutter/material.dart';

class AuthSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthSettings();
}

class _AuthSettings extends State<AuthSettings> {
  var loginController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: loginController,
              textInputAction: TextInputAction.continueAction,
              decoration: InputDecoration(
                labelText: "Login:",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: passwordController,
              textInputAction: TextInputAction.send,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password:",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
