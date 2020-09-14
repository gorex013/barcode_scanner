import 'dart:convert';
import 'dart:io';

import 'package:barcode_scanner/database_management/database_management.dart';
import 'package:barcode_scanner/scan_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import 'product_registration/product_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String host;
  String port;

  String networkError;

  readHost() async {
    final directory = await getApplicationDocumentsDirectory();
    try {
      final hostFile = File('${directory.path}/host.data');
      if (!await hostFile.exists())
        setState(() {
          this.host = "";
        });
      var host = utf8.decode(await hostFile.readAsBytes());
      if (host.isEmpty)
        setState(() {
          this.host = "";
        });
      setState(() {
        this.host = host;
      });
    } catch (Exception) {
      setState(() {
        this.host = "";
      });
    }
  }

  readPort() async {
    final directory = await getApplicationDocumentsDirectory();
    try {
      final portFile = File('${directory.path}/port.data');
      if (!await portFile.exists())
        setState(() {
          this.port = "";
        });
      var port = utf8.decode(await portFile.readAsBytes());
      if (port.isEmpty)
        setState(() {
          this.port = "";
        });
      setState(() {
        this.port = port;
      });
    } catch (Exception) {
      setState(() {
        this.port = "";
      });
    }
  }

  networkCheck() async {
    if (host == null || port == null || host.isEmpty || port.isEmpty) {
      print(host);
      print(port);
      setState(() {
        networkError = "Introduceți IP și port în setări";
      });
    }
    try {
      await Socket.connect(host, int.tryParse(port));
      setState(() {
        networkError = "";
      });
    } catch (Exception) {
      setState(() {
        networkError =
            "Nu există conexiune către IP și port introduse. Verificați setările.";
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (host == null) readHost();
    if (port == null) readPort();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manager depozit',
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.sync),
              onPressed: () async {
                var db = Operation.instance;
                var rows = await db.query();
                for (var i = 0; i < rows.length; ++i) {
                  final id = rows[i][Operation.id];
                  final response = await post(
                      "http://$host:$port/api/operations",
                      body: {'json': rows[i][Operation.json]});
                  print(response.body);
                  if (response.statusCode == 201) {
                    await db.delete(id);
                  } else {
                    setState(() {
                      networkError =
                          "Sincronizarea cu serverul principal a eșuat";
                    });
                    return;
                  }
                }
                setState(() {
                  networkError = "";
                });
              }),
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () async {
                var reload = await Navigator.pushNamed(context, '/settings');
                if (reload)
                  setState(() {
                    readHost();
                    readPort();
                    networkCheck();
                  });
              })
        ],
      ),
      body: HomeBody(),
      bottomNavigationBar: (networkError == null || networkError.isEmpty)
          ? null
          : Text(
              "Eroare: " + networkError,
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

class HomeBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeBody();
}

class _HomeBody extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Row(
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
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ScanDialog(
                          Text('Depozitare produs'),
                        );
                      },
                      barrierDismissible: false,
                    );
                  },
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
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ScanDialog(
                          Text('Extragere produs'),
                          outFlag: true,
                        );
                      },
                      barrierDismissible: false,
                    );
                  },
                  icon: Icon(Icons.arrow_upward),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 10,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              label: Text("Înregistrare produs"),
              icon: Icon(Icons.settings_overscan),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ProductDialog(),
                  barrierDismissible: false,
                );
              },
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}
