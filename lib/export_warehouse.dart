import 'package:barcode_scanner/scan_dialog.dart';
import 'package:flutter/material.dart';

import 'database_management/remote_database_management.dart';

class ExportWarehouse extends StatefulWidget {
  final host;
  final port;
  final apiKey;

  const ExportWarehouse({Key key, this.host, this.port, this.apiKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExportWarehouse();
}

class _ExportWarehouse extends State<ExportWarehouse> {
  var history;

  @override
  Widget build(BuildContext context) {
    var transaction = Transaction(widget.host, widget.port, widget.apiKey);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Extragere"),
      ),
      body: FutureBuilder(
        future: transaction.queryExport(),
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
                    var exportDate =
                        DateTime.parse(history[i][Transaction.transactionDate]);
                    return ListTile(
                      title: Text(
                          "${i + 1}. Barcode: ${history[i][Product.barcode]}\nQuantity: ${history[i][Transaction.quantity]}\n"
                          "Date: ${exportDate.day}/${exportDate.month}/${exportDate.year} ${exportDate.hour}:${exportDate.minute}"),
                    );
                  },
                );
        },
      ),
      bottomNavigationBar: SizedBox(
        width: MediaQuery.of(context).size.width - 10,
        child: RaisedButton.icon(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          label: Text("Extragere"),
          icon: Icon(Icons.arrow_upward),
          onPressed: () async {
            showDialog(
              context: context,
              builder: (context) {
                return ScanDialog(
                  widget.host,
                  widget.port,
                  widget.apiKey,
                  Text('Extragere produs'),
                  transaction.insert,
                  (id, quantity) => <String, dynamic>{
                    Transaction.productId: id,
                    Transaction.quantity: quantity,
                    Transaction.transactionDate:
                        DateTime.now().toIso8601String(),
                  },
                  availableStockFunction: transaction.queryStock,
                  outFlag: true,
                );
              },
              barrierDismissible: false,
            );
          },
        ),
      ),
    );
  }
}
