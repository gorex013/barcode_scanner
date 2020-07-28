import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';




class ScanDialog extends StatefulWidget {
  final title;
  final barcode;
  final doneButton;
  static _scan() async {
    return FlutterBarcodeScanner.scanBarcode(
        "#ff4297", "Anulează", true, ScanMode.DEFAULT);
  }
  ScanDialog(this.title, this.doneButton, this.barcode);

  @override
  State<StatefulWidget> createState() => _ScanDialog();
}

class _ScanDialog extends State<ScanDialog> {
  @override
  Widget build(BuildContext context) {
    var scanController = TextEditingController();
    scanController.text = widget.barcode;
    var quantityController = TextEditingController();
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 6,
          vertical: MediaQuery.of(context).size.height / 4),
      title: widget.title,
      content: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: "Barcode: "),
            controller: scanController,
            focusNode: FocusNode(),
            enableInteractiveSelection: false,
            showCursor: false,
            onTap: () async {
              var result = await ScanDialog._scan();
              if (result == '-1') return;
              scanController.text = result;
            },
          ),
          TextField(
            decoration: InputDecoration(
              labelText: "Cantitate: ",
              hintText: "Cantitate de produs ... ",
            ),
            controller: quantityController,
            focusNode: FocusNode(),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
      actions: <Widget>[
        widget.doneButton,
      ],
    );
  }
}
