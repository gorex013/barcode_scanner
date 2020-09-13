import 'package:barcode_scanner/database_management/database_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScanDialog extends StatefulWidget {
  final title;
  final transactionInsert;
  final mapperFunction;
  final availableStockFunction;
  final outFlag;

  static _scan() async {
    return FlutterBarcodeScanner.scanBarcode(
        "#ff4297", "Anulează", true, ScanMode.DEFAULT);
  }

  ScanDialog(this.title,
      this.transactionInsert, this.mapperFunction,
      {this.availableStockFunction, this.outFlag = false});

  @override
  State<StatefulWidget> createState() => _ScanDialog();
}

class _ScanDialog extends State<ScanDialog> {
  var scanController = TextEditingController();
  var quantityController = TextEditingController();
  var quantityFocusNode = FocusNode();
  var registered = true;
  var emptyQuantity;
  var exceedQuantity;
  var negativeQuantity;
  var scanned;

  @override
  Widget build(BuildContext context) {
    var product = Product();
    var finishButton = RaisedButton.icon(
      onPressed: () async {
        if (scanController.text.isEmpty) {
          setState(() {
            scanned = false;
          });
          return;
        }
        var barcodeID = await product.queryId(scanController.text);
        if (barcodeID == null) {
          setState(() {
            scanned = true;
            registered = false;
          });
          return;
        }
        barcodeID = barcodeID[0][Product.id];
        if (quantityController.text.isEmpty) {
          setState(() {
            scanned = true;
            registered = true;
            emptyQuantity = true;
          });
          return;
        }
        var number = int.tryParse(quantityController.text, radix: 10);
        if (number <= 0) {
          setState(() {
            emptyQuantity = false;
            negativeQuantity = true;
            exceedQuantity = false;
          });
          return;
        }
        if (widget.outFlag) {
          var maxStock;
          if (widget.availableStockFunction != null) {
            maxStock = await widget.availableStockFunction(id: barcodeID);
          }
          if (maxStock == null) maxStock = 0;
          if (number > maxStock) {
            setState(() {
              emptyQuantity = false;
              exceedQuantity = true;
              negativeQuantity = false;
            });
            return;
          }
        }
        widget.transactionInsert(
          widget.mapperFunction(barcodeID,
              int.parse(quantityController.text) * ((widget.outFlag) ? -1 : 1)),
        );
        Navigator.pop(context, true);
      },
      icon: Icon(Icons.done),
      label: Text("Terminat"),
    );
    var registerButton = RaisedButton.icon(
      onPressed: () async {
        var _unregistred = await Navigator.pushNamed(
            context, '/fast-register-product',
            arguments: scanController.text);
        setState(() {
          registered = _unregistred;
        },);
      },
      icon: Icon(Icons.add),
      label: Text("Înregistrează"),
    );
    return SimpleDialog(
      title: widget.title,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                    hintText: "Apasă pentru scanare",
                    errorText: (scanned == null)
                        ? null
                        : (!scanned)
                            ? "Scanați barcod"
                            : (!registered) ? "Înregistrați produsul" : null),
                controller: scanController,
                onTap: () async {
                  var result = await ScanDialog._scan();
                  if (result == '-1') {
                    setState(() {
                      scanned = false;
                      scanController.text = "";
                    });
                    return;
                  }
                  var queryResult = await product.queryId(result);
                  var _registered = queryResult.length != 0;
                  setState(() {
                    scanController.text = result;
                    scanned = true;
                    registered = _registered;
                  });
                  quantityFocusNode.requestFocus();
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Cantitate: ",
                  hintText: "Cantitate de produs ... ",
                  errorText: (emptyQuantity == null)
                      ? null
                      : (emptyQuantity)
                          ? "Completați cantitatea"
                          : (exceedQuantity)
                              ? "Cantitate excesivă"
                              : (negativeQuantity)
                                  ? "Valoarea cantității nu poate fi negativă sau zero"
                                  : null,
                ),
                controller: quantityController,
                focusNode: quantityFocusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  quantityFocusNode.unfocus();
                },
              ),
            ],
          ),
        ),
        Row(
          children: [
            RaisedButton.icon(
              label: Text("Anulare"),
              onPressed: () {
                Navigator.pop(context, false);
              },
              icon: Icon(Icons.cancel),
            ),
            (!registered) ? registerButton : finishButton
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      ],
    );
  }
}
