import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatefulWidget {
  final host;
  final port;
  final apiKey;
  const HomePage({Key key, this.host, this.port, this.apiKey}) : super(key: key);
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
      body: HomeBody(host: widget.host,port: widget.port,),
    );
  }
}

class HomeBody extends StatefulWidget {
  final host;
  final port;

  const HomeBody({Key key, this.host, this.port}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeBody();
}

class _HomeBody extends State<HomeBody> {
  var localConnection;

  void checkConnection() async {
    var _localConnction;
    if (widget.host == null || widget.port == null)
      _localConnction = false;
    else
      _localConnction = await Connectivity().checkConnectivity() == ConnectivityResult.wifi;

    setState(() {
      localConnection = _localConnction;
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
    if (localConnection)
      Navigator.pushNamed(context, route);
    else
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Nu aveți conexiune!"),
          action: SnackBarAction(
            onPressed: () {},
            label: "Verifică conexiunea",
          ),
        ),
      );
  }
}
