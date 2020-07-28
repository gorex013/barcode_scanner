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
  var scanController = TextEditingController();
  var quantityController = TextEditingController();
  var quantityFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    scanController.text = widget.barcode;
    return AlertDialog(
      insetPadding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width / 6,
          right: MediaQuery.of(context).size.width / 6,
          top: 30,
          bottom: 270),
      title: widget.title,
      content: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: "Barcode: "),
            controller: scanController,
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
            focusNode: quantityFocusNode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (text) {
              quantityFocusNode.unfocus();
            },
            onTap: (){
              FocusScope.of(context).requestFocus(quantityFocusNode);
            },
            onEditingComplete: (){
              quantityFocusNode.unfocus();
            },
          ),
        ],
      ),
      actions: <Widget>[
        widget.doneButton,
      ],
    );
  }
}
