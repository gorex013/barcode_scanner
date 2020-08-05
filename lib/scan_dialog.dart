import 'package:barcode_scanner/database_management.dart';
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

  ScanDialog(this.title, this.transactionInsert, this.mapperFunction,
      {this.availableStockFunction, this.outFlag = false});

  @override
  State<StatefulWidget> createState() => _ScanDialog();
}

class _ScanDialog extends State<ScanDialog> {
  var scanController = TextEditingController();
  var quantityController = TextEditingController();
  var quantityFocusNode = FocusNode();
  var unregistered = false;

  bool emptyQuantity = true;
  var emptyQuantityPressed = false;
  bool exceedQuantity = true;
  var exceedQuantityPressed = false;

  var unscannedPressed = false;

  @override
  Widget build(BuildContext context) {
    var finishButton = RaisedButton.icon(
      onPressed: () async {
        if (scanController.text.length == 0) {
          setState(() {});
        }
        var number = int.tryParse(quantityController.text, radix: 10);
        if (emptyQuantity) {
          setState(() {
            emptyQuantity = quantityController.text == "" || number <= 0;
            emptyQuantityPressed = emptyQuantity;
          });
          return;
        }
        var barcodeID = await Product.query(
          columns: [Product.id],
          where: '${Product.barcode} = \"${scanController.text}\"',
        );
        barcodeID = barcodeID[0][Product.id];
        var maxStock;
        if (widget.availableStockFunction != null) {
          maxStock = await widget.availableStockFunction(id: barcodeID);
          print(maxStock);
          maxStock = maxStock[0]['stock'];
        }
        if (maxStock == null) maxStock = 0;
        if (exceedQuantity) {
          setState(() {
            exceedQuantity = number > maxStock;
            exceedQuantityPressed = exceedQuantity;
          });
          return;
        }
        widget.transactionInsert(
          widget.mapperFunction(barcodeID,
              int.parse(quantityController.text) * ((widget.outFlag) ? -1 : 1)),
        );
        Navigator.pop(context);
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
          unregistered = _unregistred;
        });
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
                    errorText: (unscannedPressed)
                        ? "Scanați barcod"
                        : (unregistered) ? "Înregistrat produsul" : null),
                controller: scanController,
                enableInteractiveSelection: false,
                showCursor: false,
                onTap: () async {
                  var result = await ScanDialog._scan();
                  if (result == '-1') {
                    setState(() {
                      scanController.text = "";
                      unscannedPressed = true;
                    });
                    return;
                  }
                  var queryResult = await Product.query(
                      where: '${Product.barcode} = \"$result\"');
                  var _unregistered = queryResult.length == 0;
                  setState(() {
                    scanController.text = result;
                    unregistered = _unregistered;
                    unscannedPressed = false;
                  });
                  quantityFocusNode.requestFocus();
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Cantitate: ",
                  hintText: "Cantitate de produs ... ",
                  errorText: (emptyQuantityPressed)
                      ? "Completați cantitatea"
                      : (exceedQuantityPressed)
                          ? "Nu există așa cantitate în stock"
                          : null,
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
        ),
        Row(
          children: [
            RaisedButton.icon(
              label: Text("Anulare"),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.cancel),
            ),
            (unregistered) ? registerButton : finishButton
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      ],
    );
  }
}
