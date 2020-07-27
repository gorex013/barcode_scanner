import 'package:flutter/material.dart';

import 'database_helper.dart';

class AddQuantityDialog extends StatefulWidget {
  final barcodes;

  AddQuantityDialog({this.barcodes});

  @override
  State<StatefulWidget> createState() => _AddQuantityDialog();
}

class _AddQuantityDialog extends State<AddQuantityDialog> {
  var _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.barcodes[0][Barcode.barcode];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Cantitate de produs adăugat"),
      content: Container(
        child: Column(
          children: [
            DropdownButton(
              items: List.generate(
                widget.barcodes.length,
                (i) => DropdownMenuItem(
                  child: Text("${widget.barcodes[i][Barcode.barcode]}"),
                  value: widget.barcodes[i][Barcode.barcode],
                ),
              ),
              onChanged: (value) {
                print(value);
                setState(() {
                  _currentValue = value;
                });
              },
              value: _currentValue,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "Cantitatea ...",
              ),
              keyboardType: TextInputType.number,
            ),
            FlatButton.icon(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.done),
              label: Text("Adaugă"),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
      ),
    );
  }
}

class ExtractQuantityDialog extends StatefulWidget {
  final barcodes;

  ExtractQuantityDialog({this.barcodes});

  @override
  State<StatefulWidget> createState() => _ExtractQuantityDialog();
}

class _ExtractQuantityDialog extends State<ExtractQuantityDialog> {
  var _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.barcodes[0][Barcode.barcode];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Cantitate de produs extras"),
      content: Container(
        child: Column(
          children: [
            DropdownButton(
              items: List.generate(
                widget.barcodes.length,
                (i) => DropdownMenuItem(
                  child: Text("${widget.barcodes[i][Barcode.barcode]}"),
                  value: widget.barcodes[i][Barcode.barcode],
                ),
              ),
              onChanged: (value) {
                print(value);
                setState(() {
                  _currentValue = value;
                });
              },
              value: _currentValue,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "Cantitatea ...",
              ),
              keyboardType: TextInputType.number,
            ),
            FlatButton.icon(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.done),
              label: Text("Extrage"),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
      ),
    );
  }
}
