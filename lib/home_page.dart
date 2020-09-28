import 'dart:convert';
import 'dart:io';

import 'package:barcode_scanner/database_management/database_management.dart';
import 'package:barcode_scanner/product_registration/product_dialog.dart';
import 'package:barcode_scanner/scan_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String host;
  String port;
  String networkError;
  var reload = true;

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
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.wifi) {
      setState(() {
        networkError = "Nu sunteti connectat la rețeaua locală";
      });
      return;
    }
    if (host == null || port == null || host.isEmpty || port.isEmpty) {
      setState(() {
        networkError = "Introduceți IP și port în setări";
        reload = true;
      });
      return;
    }
    try {
      await Socket.connect(host, int.tryParse(port));
      setState(() {
        networkError = "";
        reload = false;
      });
    } catch (Exception) {
      setState(() {
        networkError =
            "Nu există conexiune către IP și port introduse. Verificați setările.";
        reload = true;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (host == null) readHost();
    if (port == null) readPort();
    if (reload) networkCheck();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manager depozit',
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.sync),
              onPressed: () async {
                networkCheck();
                var db = Operation.instance;
                var rows = await db.query();
                var k = 0;
                for (var i = 0; i < rows.length; ++i) {
                  final id = rows[i][Operation.id];
                  final response = await post("http://$host:$port/raw_data",
                      body: {'json': rows[i][Operation.json]});
                  if (response.statusCode == 200) {
                    await db.delete(id);
                    ++k;
                  }
                }

                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Stare sincronizare"),
                        content: Text(
                          (rows.length != 0)
                              ? "Operațiuni $k/${rows.length}"
                              : "Nimic de sincronizat",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    });
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
    var neededHeight = 80.0;
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width - 10,
            height: neededHeight,
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
          SizedBox(
            width: MediaQuery.of(context).size.width - 10,
            height: neededHeight,
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
            width: MediaQuery.of(context).size.width - 10,
            height: neededHeight,
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ),
    );
  }
}
