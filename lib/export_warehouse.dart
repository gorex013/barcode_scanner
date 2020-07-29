import 'package:barcode_scanner/scan_dialog.dart';
import 'package:flutter/material.dart';

import 'database_management.dart';

class ExportWarehouse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExportWarehouse();
}

class _ExportWarehouse extends State<ExportWarehouse> {
  var history;

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
        title: Text("Extragere"),
      ),
      body: FutureBuilder(
        future: ExportTransaction.queryWithBarcodes(),
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
                    var exportDate = DateTime.parse(
                        history[i][ExportTransaction.exportDate]);
                    return ListTile(
                      title: Text(
                          "${i + 1}. Barcode: ${history[i][Barcode.barcode]}\nQuantity: ${history[i][ExportTransaction.quantity]}\n"
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
                  Text('Extragere produs'),
                  ExportTransaction.insert,
                  (id, quantity) => <String, dynamic>{
                    ExportTransaction.barcodeId: id,
                    ExportTransaction.quantity: quantity,
                    ExportTransaction.exportDate:
                        DateTime.now().toIso8601String(),
                  },
                  availableStockFunction: ExportTransaction.queryAvailableStock,
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
