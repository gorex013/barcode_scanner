import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.amber,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Barcode scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> history;

  void _scan() async {
    var _result = await FlutterBarcodeScanner.scanBarcode(
        "#ff4297", "Cancel", true, ScanMode.DEFAULT);
    setState(() {
      history.add("Barcode: " + _result);
    });
  }

  @override
  void initState() {
    super.initState();
    history = [];
  }

  @override
  Widget build(BuildContext context) {
    var addInventoryButton = RaisedButton(
      padding: EdgeInsets.symmetric(horizontal: 100),
      onPressed: () {
        _scan();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Icon(Icons.settings_overscan),
          Text("Inventariere"),
        ],
      ),
      color: Theme.of(context).primaryColorDark,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) => ListTile(
          title: Text("${index + 1}. ${history[index]}"),
        ),
      ),
      bottomNavigationBar: addInventoryButton,
    );
  }
}
