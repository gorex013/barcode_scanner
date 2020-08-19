import 'package:flutter/material.dart';

class AuthSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthSettings();
}

class _AuthSettings extends State<AuthSettings> {
  var loginController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: loginController,
              textInputAction: TextInputAction.next,
              onEditingComplete: (){
                FocusScope.of(context).requestFocus(passwordFocus);
              },
              decoration: InputDecoration(
                labelText: "Login:",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              focusNode: passwordFocus,
              controller: passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password:",
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        child: RaisedButton.icon(
          onPressed: (){
//            final directory = await getApplicationDocumentsDirectory();
//            final apiFile = File('${directory.path}/warehouse.key');
//            apiFile.writeAsBytes(utf8.encode(apiKeyController.text));
            Navigator.pop(context, false);
          },
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          label: Text("Autentificare"),
          icon: Icon(Icons.done),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
