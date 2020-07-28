import 'package:barcode_scanner/database_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScanDialog extends StatefulWidget {
  final title;
  final transactionInsert;
  final mapperFunction;

  static _scan() async {
    return FlutterBarcodeScanner.scanBarcode(
        "#ff4297", "Anulează", true, ScanMode.DEFAULT);
  }

  ScanDialog(this.title, this.transactionInsert, this.mapperFunction);

  @override
  State<StatefulWidget> createState() => _ScanDialog();
}

class _ScanDialog extends State<ScanDialog> {
  var scanController = TextEditingController();
  var quantityController = TextEditingController();
  var quantityFocusNode = FocusNode();
  var unregistered = false;
  var unscanned = true;

  @override
  Widget build(BuildContext context) {
    if (unscanned) scanController.text = "Apasă pentru a scana barcod";
    var actionButtons = <Widget>[
      RaisedButton.icon(
        onPressed: () async {
          if (scanController.text == "Apasă pentru a scana") {
            return;
          }
          var barcodeID = await Barcode.query(
            columns: [Barcode.id],
            where: '${Barcode.barcode} = \"${scanController.text}\"',
          );
          print(barcodeID);
          barcodeID = barcodeID[0][Barcode.id];
          widget.transactionInsert(
              widget.mapperFunction(barcodeID, quantityController.text));
          Navigator.pop(context);
        },
        icon: Icon(Icons.done),
        label: Text("Terminat"),
      ),
    ];
    var registerButton = RaisedButton.icon(
      onPressed: () async {
        setState(() {
          Barcode.insert(
            {
              Barcode.barcode:  scanController.text,
              Barcode.startDate: DateTime.now().toIso8601String()
            },
          );
          unregistered = false;
          unscanned = false;
        });
      },
      icon: Icon(Icons.add),
      label: Text("Înregistrează"),
    );
    if (unregistered) actionButtons.add(registerButton);
    return AlertDialog(
      insetPadding: EdgeInsets.only(top: 30, bottom: 270),
      title: widget.title,
      content: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
                labelText: "Barcode: ",
                errorText:
                    (unregistered) ? "Produsul nu este înregistrat" : null),
            controller: scanController,
            enableInteractiveSelection: false,
            showCursor: false,
            onTap: () async {
              var result = await ScanDialog._scan();
              if (result == '-1') {
                setState(() {
                  scanController.text = "Apasă pentru a scana barcod";
                  unscanned = true;
                });
                return;
              }
              var queryResult = await Barcode.query(
                  where: '${Barcode.barcode} = \"$result\"');
              var _unregistered = queryResult.length == 0;
              setState(() {
                scanController.text = result;
                unregistered = _unregistered;
                unscanned = false;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(
              labelText: "Cantitate: ",
              hintText: "Cantitate de produs ... ",
            ),
            controller: quantityController,
            focusNode: quantityFocusNode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (text) {
              quantityFocusNode.unfocus();
            },
            onTap: () {
              FocusScope.of(context).requestFocus(quantityFocusNode);
            },
            onEditingComplete: () {
              quantityFocusNode.unfocus();
            },
          ),
        ],
      ),
      actions: actionButtons,
    );
  }
}
