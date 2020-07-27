import 'package:barcode_scanner/add_product_quantity_dialog.dart';
import 'package:barcode_scanner/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var history;
  final dbHelper = Barcode.instance;

  void _scan() async {
    var _result = await FlutterBarcodeScanner.scanBarcode(
        "#ff4297", "Cancel", true, ScanMode.DEFAULT);
    bool exists = await dbHelper.queryExists(_result);
    if (exists){
      showDialog(context: context, builder: (context) => AlertDialog(
        content: Text("Produsul $_result există deja în baza de date."),
      ));
      return;
    }
    if (_result != '-1')
    setState(() {
        dbHelper.insert(
          {
            Barcode.barcode: _result,
            Barcode.startDate: DateTime.now().toIso8601String()
          },
        );
        _getBarcodes();
    });
  }
  _getBarcodes()async{
    history = dbHelper.queryAllRows();
  }
  @override
  void initState() {
    super.initState();
    _getBarcodes();
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
          Text("Adaugă produs"),
        ],
      ),
    );
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
          future: dbHelper.queryAllRows(),
          builder: (context, snapshot) {
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
                  child: Text('Error: ${snapshot.error}'),
                )
              ];
            } else {
              history = snapshot.data;
            }
            return (history == null)
                ? Column(
                    children: children,
                  )
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, i) {
                      var dateTime = DateTime.parse(history[i]['start_date']);
                      return ListTile(
                        title: Text(
                            "${i + 1}. Barcode: ${history[i]['barcode']}\n"
                            "Date: ${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}"),
                      );
                    },
                  );
          },
        ),
        bottomNavigationBar: addInventoryButton,
        floatingActionButton: Row(
          children: [
            RaisedButton.icon(
              label: Text("Adaugă la depozit"),
              icon: Icon(Icons.arrow_downward),
              onPressed: () async {
                var barcodes = await dbHelper.queryAllRows();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AddQuantityDialog(
                      barcodes: barcodes,
                    );
                  },
                );
              },
            ),
            RaisedButton.icon(
              label: Text("Extrage din depozit"),
              onPressed: () async {
                var barcodes = await dbHelper.queryAllRows();
                showDialog(
                  context: context,
                  builder: (context) {
                    return ExtractQuantityDialog(
                      barcodes: barcodes,
                    );
                  },
                );
              },
              icon: Icon(Icons.arrow_upward),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
