import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'barcode_database_helper.dart';

class RegisterProduct extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterProduct();
}

class _RegisterProduct extends State<RegisterProduct> {
  final dbHelper = Barcode.instance;

  var history;

  void _scan() async {
    var _result = await FlutterBarcodeScanner.scanBarcode(
        "#ff4297", "Cancel", true, ScanMode.DEFAULT);
    bool exists = await dbHelper.queryExists(_result);
    if (exists) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
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
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Înregistrare produse"),
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
      bottomNavigationBar: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        child: RaisedButton.icon(
          onPressed: () {
            _scan();
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          label: Text("Scanare"),
          icon: Icon(Icons.settings_overscan),
        ),
      ),
    );
  }
}
