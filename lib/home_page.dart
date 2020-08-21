import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:barcode_scanner/database_management/remote_database_management.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var apiKey;
  var host;
  var port;

  readKey() async {
    final directory = await getApplicationDocumentsDirectory();
    final apiFile = File('${directory.path}/warehouse.key');
    if (!await apiFile.exists()) {
      setState(() {
        apiKey = "";
      });
      return;
    }
    var _apiKey = utf8.decode(await apiFile.readAsBytes());
    if (_apiKey.isNotEmpty)
      setState(() {
        apiKey = _apiKey;
      });
  }

  readHost() async {
    final directory = await getApplicationDocumentsDirectory();
    final hostFile = File('${directory.path}/host.data');
    if (!await hostFile.exists()) {
      setState(() {
        host = "";
      });
      return;
    }
    var _host = utf8.decode(await hostFile.readAsBytes());
    if (_host.isNotEmpty)
      setState(() {
        host = _host;
      });
  }

  readPort() async {
    final directory = await getApplicationDocumentsDirectory();
    final portFile = File('${directory.path}/port.data');
    if (!await portFile.exists()) {
      setState(() {
        port = "";
      });
      return;
    }
    var _port = utf8.decode(await portFile.readAsBytes());
    if (_port.isNotEmpty)
      setState(() {
        port = _port;
      });
  }

  @override
  Widget build(BuildContext context) {
    if (apiKey == null) readKey();
    if (host == null) readHost();
    if (port == null) readPort();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manager depozit',
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () async {
                var needReload =
                    await Navigator.pushNamed(context, '/settings');
                if (needReload) {
                  readHost();
                  readPort();
                  readKey();
                }
              })
        ],
      ),
      body: (host == null ||
              port == null ||
              host.isEmpty ||
              port.isEmpty ||
              apiKey == null ||
              apiKey.isEmpty)
          ? Center(
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Eroare : Verificați setările!'),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            )
          : HomeBody(),
    );
  }
}

class HomeBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeBody();
}

class _HomeBody extends State<HomeBody> {
  var localConnection;
  var history;

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

  void checkConnection() async {
    var host = await readHost();
    var port = await readPort();
    var _localConnection;
    if (host == null || port == null)
      _localConnection = false;
    else
      _localConnection =
          await Connectivity().checkConnectivity() == ConnectivityResult.wifi;

    setState(() {
      localConnection = _localConnection;
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
      body: FutureBuilder(
        future: Transaction().queryAll(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasError) {
            children = <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Eroare: ${snapshot.error}'),
              )
            ];
          } else if (snapshot.hasData) {
            history = snapshot.data;
          } else {
            children = <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Se încarcă tranzacțiile efectuate...'),
              )
            ];
          }
          return (history == null)
              ? Center(
                  child: Column(
                    children: children,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, i) {
                    var transactionDate =
                        DateTime.parse(history[i][Transaction.transactionDate]);
                    return ListTile(
                      title: Text(
                        "${i + 1}. ${history[i][Product.name]} ${((history[i][Transaction.quantity]>0)?'+':'') + history[i][Transaction.quantity].toString()}",
                        style: TextStyle(
                            color: (history[i][Transaction.quantity] > 0)
                                ? Colors.green
                                : Colors.red),
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Detalii"),
                          content: Text(
                            "Data tranzacției: "
                            "${transactionDate.day.toString().padLeft(2, '0')}/"
                            "${transactionDate.month.toString().padLeft(2, '0')}/"
                            "${transactionDate.year} "
                            "${transactionDate.hour.toString().padLeft(2, '0')}:"
                            "${transactionDate.minute.toString().padLeft(2, '0')}\n"
                            "Barcod produs: ${history[i][Product.barcode]}",
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
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
    if (localConnection)
      Navigator.pushNamed(context, route);
    else
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Nu aveți conexiune!"),
          action: SnackBarAction(
            onPressed: () {
              AppSettings.openWIFISettings();
            },
            label: "Verifică conexiunea",
          ),
        ),
      );
  }
}
