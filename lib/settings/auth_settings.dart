import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class AuthSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthSettings();
}

class _AuthSettings extends State<AuthSettings> {
  var nameController = TextEditingController();
  var loginController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var apiKeyController = TextEditingController();
  var loginFocus = FocusNode();
  var passwordFocus = FocusNode();
  var confirmPasswordFocus = FocusNode();
  var isEmptyPassword = false;
  var isEmptyLogin = false;
  var needToRegister = false;
  var isEmptyName = false;
  var hidePassword = true;
  var differentPasswords = false;

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
    var host = utf8.decode(await portFile.readAsBytes());
    if (host.isEmpty) return null;
    return host;
  }

  readKey() async {
    final directory = await getApplicationDocumentsDirectory();
    final apiFile = File('${directory.path}/warehouse.key');
    final apiKey = utf8.decode(await apiFile.readAsBytes());
    return apiKey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          (needToRegister)
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(loginFocus);
                    },
                    decoration: InputDecoration(
                      labelText: "Nume:",
                      errorText: (isEmptyName)
                          ? "Câmpul numelui nu poate fi gol"
                          : null,
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(0),
                ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              focusNode: loginFocus,
              controller: loginController,
              textInputAction: TextInputAction.next,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(passwordFocus);
              },
              decoration: InputDecoration(
                labelText: "Login:",
                errorText:
                    (isEmptyLogin) ? "Câmpul login nu poate fi gol." : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              focusNode: passwordFocus,
              controller: passwordController,
              textInputAction: (!needToRegister)
                  ? TextInputAction.done
                  : TextInputAction.next,
              obscureText: hidePassword,
              decoration: InputDecoration(
                labelText: "Parola:",
                errorText: (isEmptyPassword)
                    ? "Câmpul parolei nu poate fi gol."
                    : null,
                suffixIcon: IconButton(
                  icon: (hidePassword)
                      ? Icon(Icons.visibility)
                      : Icon(Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),
              ),
            ),
          ),
          (needToRegister)
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    focusNode: confirmPasswordFocus,
                    controller: confirmPasswordController,
                    textInputAction: TextInputAction.done,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: "Confirmare parolă:",
                      errorText:
                          (differentPasswords) ? "Parolele nu coincid" : null,
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(0),
                ),
          FutureBuilder(
            future: readKey(),
            builder: (context, snapshot) {
              var apiKeyTextField = Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                        final directory =
                            await getApplicationDocumentsDirectory();
                        final apiFile = File('${directory.path}/warehouse.key');
                        apiFile
                            .writeAsBytes(utf8.encode(apiKeyController.text));
                        Navigator.pop(context, true);
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
        ],
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        child: RaisedButton.icon(
          onPressed: (!needToRegister)
              ? () async {
                  var host = await readHost();
                  var port = await readPort();
                  if (host == null || port == null) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Setați adresa IP și portul mai întâi!"),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    isEmptyLogin = loginController.text == null ||
                        loginController.text.isEmpty;
                    isEmptyPassword = passwordController.text == null ||
                        passwordController.text.isEmpty;
                  });
                  if (isEmptyLogin || isEmptyPassword) return;
                  final requestHeaders = {
                    'Content-type': 'application/json',
                    'Accept': 'application/json',
                  };
                  final data = jsonEncode({
                    "email": loginController.text,
                    "password": passwordController.text,
                  });
                  var response = await post(
                    'http://$host:$port/api/login',
                    body: data,
                    headers: requestHeaders,
                  );
                  if (response.statusCode == 200) {
                    final directory = await getApplicationDocumentsDirectory();
                    final apiFile = File('${directory.path}/warehouse.key');
                    var apiKey = jsonDecode(response.body)['data']['api_token'];
                    apiFile.writeAsBytes(utf8.encode(apiKey));
                    Navigator.pop(context, true);
                    return;
                  } else {
                    setState(() {
                      needToRegister = true;
                    });
                  }
                }
              : () async {
                  var host = await readHost();
                  var port = await readPort();
                  setState(() {
                    isEmptyName = nameController.text == null ||
                        nameController.text.isEmpty;
                    isEmptyLogin = loginController.text == null ||
                        loginController.text.isEmpty;
                    isEmptyPassword = passwordController.text == null ||
                        passwordController.text.isEmpty;
                    differentPasswords = passwordController.text !=
                        confirmPasswordController.text;
                  });
                  if (isEmptyName ||
                      isEmptyLogin ||
                      isEmptyPassword ||
                      differentPasswords) return;
                  final requestHeaders = {
                    'Content-type': 'application/json',
                    'Accept': 'application/json',
                  };
                  final data = jsonEncode({
                    "name": nameController.text,
                    "email": loginController.text,
                    "password": passwordController.text,
                    "password_confirmation": confirmPasswordController.text,
                  });
                  var response = await post(
                    'http://$host:$port/api/register',
                    body: data,
                    headers: requestHeaders,
                  );
                  if (response.statusCode == 201) {
                    final directory = await getApplicationDocumentsDirectory();
                    final apiFile = File('${directory.path}/warehouse.key');
                    var apiKey = jsonDecode(response.body)['data']['api_token'];
                    apiFile.writeAsBytes(utf8.encode(apiKey));
                    Navigator.pop(context, true);
                    return;
                  }
                  Navigator.pop(context, false);
                },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          label: Text((!needToRegister) ? "Autentificare" : "Înregistrare"),
          icon: Icon(Icons.done),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
