import 'package:barcode_scanner/scan_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ImportWarehouse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ImportWarehouse();
}

class _ImportWarehouse extends State<ImportWarehouse> {
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
        title: Text("Depozitare"),
      ),
      body: Center(
        child: Text('Import'),
      ),
      bottomNavigationBar: SizedBox(
        width: MediaQuery.of(context).size.width - 10,
        child: RaisedButton.icon(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          label: Text("Depozitare"),
          icon: Icon(Icons.arrow_downward),
          onPressed: () async {
            var result = await FlutterBarcodeScanner.scanBarcode(
                "#ff4297", "Anulează", true, ScanMode.DEFAULT);
            if (result == '-1') return;
            showDialog(
              context: context,
              builder: (context) => ScanDialog(
                  Text('Depozitare produs'),
                  RaisedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.done),
                    label: Text("Terminat"),
                  ),
                  result),
              barrierDismissible: false,
            );
          },
        ),
      ),
    );
  }
}
