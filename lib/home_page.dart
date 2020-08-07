import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manager depozit',
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              })
        ],
      ),
      body: HomeBody(),
    );
  }
}

class HomeBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeBody();
}

class _HomeBody extends State<HomeBody> {
  var localConnection;
  var internetConnection;

  void checkConnection() async {
    var _localConnection =
        await Connectivity().checkConnectivity() != ConnectivityResult.none;
    var _internetConnection;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _internetConnection = true;
      } else {
        _internetConnection = false;
      }
    } on SocketException catch (_) {
      _internetConnection = false;
    }

    setState(() {
      localConnection = _localConnection;
      internetConnection = _internetConnection;
    });
  }

  @override
  Widget build(BuildContext context) {
    checkConnection();
    return Scaffold(
      bottomNavigationBar: SizedBox(
        width: MediaQuery.of(context).size.width - 10,
        child: RaisedButton.icon(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          label: Text("Înregistrare produs"),
          icon: Icon(Icons.settings_overscan),
          onPressed: () => connected(context, '/register-product'),
        ),
      ),
      floatingActionButton: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 10,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              label: Text("Depozitare produse"),
              icon: Icon(Icons.arrow_downward),
              onPressed: () => connected(context, '/import-warehouse'),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 10,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              label: Text("Extragere produse"),
              onPressed: () => connected(context, '/export-warehouse'),
              icon: Icon(Icons.arrow_upward),
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void connected(context, route) {
    checkConnection();
    if (internetConnection)
      Navigator.pushNamed(context, route);
    else
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text((localConnection)
              ? "Aveți doar connexiune locală!"
              : "Nu aveți conexiune!"),
          action: SnackBarAction(
            onPressed: () {},
            label: "Verifică conexiunea",
          ),
        ),
      );
  }
}
