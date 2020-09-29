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
  var outOfScanner = true;
  var barcodeError = false;
  var quantityController = TextEditingController();
  var quantityError = false;
  var negativeQuantityError = false;
  var quantityFocusNode = FocusNode();

  var barcodeFocusNode = FocusNode();

  var manually = false;

  @override
  void dispose() {
    barcodeController.dispose();
    quantityController.dispose();
    barcodeFocusNode.dispose();
    quantityFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (outOfScanner && quantityController.text.isEmpty)
      quantityFocusNode.requestFocus();
    var finishButton = RaisedButton.icon(
      onPressed: () async {
        var number = int.tryParse(quantityController.text, radix: 10);
        setState(() {
          barcodeError = barcodeController.text.isEmpty;
          quantityError = quantityController.text.isEmpty;
          negativeQuantityError = number <= 0;
        });
        if (barcodeError || quantityError || negativeQuantityError) return;
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
                textInputAction:
                    (manually) ? TextInputAction.next : TextInputAction.done,
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
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[A-Z0-9]+"))
                      ],
                    )
                  : Column(
                      children: [
                        RaisedButton.icon(
                          label: Text("Scanare"),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              outOfScanner = false;
                            });
//                            quantityFocusNode.unfocus();
                            var result =
                                await FlutterBarcodeScanner.scanBarcode(
                                    "#ff4297",
                                    "Anulează",
                                    true,
                                    ScanMode.DEFAULT);
                            if (result == '-1') {
                              setState(() {
                                barcodeController.text = "";
                                outOfScanner = true;
                              });
                              return;
                            }
                            setState(() {
                              barcodeController.text = result;
                              outOfScanner = true;
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
            finishButton
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      ],
    );
  }
}
