import 'package:barcode_scanner/database_management.dart';
import 'package:flutter/material.dart';

class FastProductDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProductDialog();
}

class _ProductDialog extends State<FastProductDialog> {
  var nameController = TextEditingController();
  var emptyNamePressed = false;
  var nameFocusNode = FocusNode();

  var barcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (nameController.text.length == 0) nameFocusNode.requestFocus();
    barcodeController.text = ModalRoute.of(context).settings.arguments;
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
                ),
                controller: barcodeController,
                enableInteractiveSelection: false,
                showCursor: false,
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
                Navigator.pop(context, true);
              },
              icon: Icon(Icons.cancel),
            ),
            RaisedButton.icon(
              onPressed: () async {
                if (nameController.text.length > 0) {
                  Product.insert({
                    Product.name: nameController.text,
                    Product.barcode: barcodeController.text,
                    Product.registrationDate: DateTime.now().toIso8601String()
                  });
                  Navigator.pop(context, false);
                } else
                  setState(() {
                    emptyNamePressed = true;
                  });
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
