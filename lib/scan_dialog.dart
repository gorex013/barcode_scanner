import 'package:barcode_scanner/database_management/database_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScanDialog extends StatefulWidget {
  final title;
  final outFlag;

  ScanDialog(this.title, {this.outFlag = false});

  @override
  State<StatefulWidget> createState() => _ScanDialog();
}

class _ScanDialog extends State<ScanDialog> {
  var barcodeController = TextEditingController();
  var barcodeError = false;
  var quantityController = TextEditingController();
  var quantityError = false;
  var registeredError = false;
  var negativeQuantityError = false;
  var quantityFocusNode = FocusNode();

  var barcodeFocusNode = FocusNode();

  var manually = false;

  @override
  Widget build(BuildContext context) {
    var finishButton = RaisedButton.icon(
      onPressed: () async {
//        var barcodeID = await product.queryId(barcodeController.text);
        var number = int.tryParse(quantityController.text, radix: 10);
        setState(() {
          barcodeError = barcodeController.text.isEmpty;
          quantityError = quantityController.text.isEmpty;
//          registeredError = barcodeID == null;
          negativeQuantityError = number <= 0;
        });
        if (barcodeError ||
            quantityError ||
            registeredError ||
            negativeQuantityError) return;
//        barcodeID = barcodeID[0][Product.id];
        await Operation.instance.insert(
          {
            Operation.json: "{"
                "\"${Transaction.table}\":"
                "{"
                "\"${Transaction.productId}\":\"${barcodeController.text}\","
                "\"${Transaction.quantity}\":${int.parse(quantityController.text) * ((widget.outFlag) ? -1 : 1)},"
                "\"${Transaction.transactionDate}\":\"${DateTime.now().toIso8601String()}\""
                "}"
                "}"
          },
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
            arguments: barcodeController.text);
        setState(
          () {
            registeredError = _unregistred;
          },
        );
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
                  labelText: "Cantitate: ",
                  hintText: "Cantitate de produs ... ",
                  errorText: (quantityError)
                      ? "Completați cantitatea"
                      : (negativeQuantityError)
                          ? "Valoarea cantității nu poate fi negativă sau zero"
                          : null,
                ),
                controller: quantityController,
                focusNode: quantityFocusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  barcodeFocusNode.requestFocus();
                },
                autofocus: true,
              ),
              Row(
                children: [
                  Checkbox(
                    value: manually,
                    onChanged: (value) {
                      setState(() {
                        if (manually)
                        manually = value;
                      });
                    },
                  ),
                  Text(
                    "Introducere manuală a codului de bare",
                  ),
                ],
              ),
              (manually)
                  ? TextField(
                      decoration: InputDecoration(
                        labelText: "Cod de bare: ",
                        hintText: "Introduceți manual ...",
                        helperText:
                            "Cod din litere mari și cifre sau doar cifre",
                        errorText: (barcodeError)
                            ? "Codul de bare este obligatoriu"
                            : null,
                      ),
                      controller: barcodeController,
                      focusNode: barcodeFocusNode,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[A-Z0-9]+"))
                      ],
                      onEditingComplete: () {
                        barcodeFocusNode.unfocus();
                      },
                    )
                  : Column(
                      children: [
                        RaisedButton.icon(
                          label: Text("Scanare"),
                          onPressed: () async {
                            var result =
                                await FlutterBarcodeScanner.scanBarcode(
                                    "#ff4297",
                                    "Anulează",
                                    true,
                                    ScanMode.DEFAULT);
                            if (result == '-1') {
                              setState(() {
                                barcodeController.text = "";
                              });
                              if (quantityController.text.isEmpty)
                                quantityFocusNode.requestFocus();
                              return;
                            }
                            setState(() {
                              barcodeController.text = result;
                            });
                          },
                          icon: Icon(Icons.settings_overscan),
                        ),
                        Text(
                          "Barcod: ${barcodeController.text}",
                          style: TextStyle(
                            color: (barcodeError) ? Colors.red : Colors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
            (registeredError) ? registerButton : finishButton
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      ],
    );
  }
}
