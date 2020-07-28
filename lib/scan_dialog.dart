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

  bool emptyQuantity = true;
  var emptyQuantityPressed = false;

  var unscannedPressed = false;

  @override
  Widget build(BuildContext context) {
    if (unscanned) scanController.text = "Apasă aici pentru a scana barcod";
    var actionButton = RaisedButton.icon(
      onPressed: () async {
        if (unscanned) {
          setState(() {
            unscannedPressed = true;
          });
          return;
        }
        var number = int.tryParse(quantityController.text, radix: 10);
        if (emptyQuantity) {
          setState(() {
            emptyQuantity = quantityController.text == "" || number < 0;
            emptyQuantityPressed = emptyQuantity;
          });
          return;
        }
        var barcodeID = await Barcode.query(
          columns: [Barcode.id],
          where: '${Barcode.barcode} = \"${scanController.text}\"',
        );
        barcodeID = barcodeID[0][Barcode.id];
        widget.transactionInsert(
            widget.mapperFunction(barcodeID, quantityController.text));
        Navigator.pop(context);
      },
      icon: Icon(Icons.done),
      label: Text("Terminat"),
    );
    var registerButton = RaisedButton.icon(
      onPressed: () async {
        setState(() {
          Barcode.insert(
            {
              Barcode.barcode: scanController.text,
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
    return AlertDialog(
      insetPadding: EdgeInsets.only(top: 30, bottom: 270),
      title: widget.title,
      content: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
                labelText: "Barcode: ",
                errorText: (unscannedPressed)
                    ? "Scanați barcod"
                    : (unregistered) ? "Produsul nu este înregistrat" : null),
            controller: scanController,
            enableInteractiveSelection: false,
            showCursor: false,
            onTap: () async {
              var result = await ScanDialog._scan();
              if (result == '-1') {
                setState(() {
                  scanController.text = "Apasă aici pentru a scana barcod";
                  unscanned = true;
                  unscannedPressed = true;
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
                unscannedPressed = false;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(
              labelText: "Cantitate: ",
              hintText: "Cantitate de produs ... ",
              errorText:
                  (emptyQuantityPressed) ? "Completați cantitatea" : null,
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
      actions: [
        RaisedButton.icon(
          label: Text("Anulare"),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.cancel),
        ),
        (unregistered) ? registerButton : actionButton
      ],
    );
  }
}
