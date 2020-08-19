import 'package:barcode_scanner/database_management/remote_database_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ProductDialog extends StatefulWidget {
  final host;
  final port;
  final apiKey;

  const ProductDialog({Key key, this.host, this.port, this.apiKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProductDialog();
}

class _ProductDialog extends State<ProductDialog> {
  var nameController = TextEditingController();
  var emptyNamePressed = false;
  var nameFocusNode = FocusNode();

  var barcodeController = TextEditingController(text: "Apasă pentru scanare");
  var barcodeFocusNode = FocusNode();
  var emptyBarcodePressed = false;

  bool barcodeEmpty = true;

  @override
  Widget build(BuildContext context) {
    var product = Product(widget.host, widget.port, widget.apiKey);
    if (nameController.text.length == 0)
      nameFocusNode.requestFocus();
    else if (barcodeEmpty) barcodeFocusNode.requestFocus();
    return SimpleDialog(
      title: Text("Înregistrare"),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: "Denumire: ",
                  hintText: "Denumire produs ... ",
                  errorText: (emptyNamePressed)
                      ? "Denumirea produsului este obligatorie"
                      : null,
                ),
                controller: nameController,
                focusNode: nameFocusNode,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onSubmitted: (text) {
                  nameFocusNode.unfocus();
                  barcodeFocusNode.requestFocus();
                },
                onTap: () {
                  nameFocusNode.requestFocus();
                },
                onEditingComplete: () {
                  setState(() {
                    emptyNamePressed = nameController.text.length == 0;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: "Barcode: ",
                    errorText: (emptyBarcodePressed) ? "Scanați barcod" : null),
                controller: barcodeController,
                focusNode: barcodeFocusNode,
                enableInteractiveSelection: false,
                showCursor: false,
                onTap: () async {
                  var result = await FlutterBarcodeScanner.scanBarcode(
                      "#ff4297", "Anulează", true, ScanMode.DEFAULT);
                  if (result == '-1') {
                    setState(() {
                      barcodeController.text = "Apasă pentru scanare";
                      barcodeEmpty = true;
                      emptyBarcodePressed = true;
                    });
                    return;
                  }
                  setState(() {
                    barcodeController.text = result;
                    barcodeEmpty = false;
                    emptyBarcodePressed = false;
                  });
                },
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ),
        Row(
          children: <Widget>[
            RaisedButton.icon(
              label: Text("Anulare"),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.cancel),
            ),
            RaisedButton.icon(
              onPressed: () async {
                product.insert({
                  Product.name: nameController.text,
                  Product.barcode: barcodeController.text,
                  Product.registrationDate: DateTime.now().toIso8601String()
                });
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/register-product');
              },
              icon: Icon(Icons.done),
              label: Text("Terminat"),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      ],
    );
  }
}
