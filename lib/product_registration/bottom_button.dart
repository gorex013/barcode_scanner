import 'package:barcode_scanner/product_registration/product_dialog.dart';
import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 20,
      child: RaisedButton.icon(
        onPressed: () => Navigator.pop(
          context,
          showDialog(
            context: context,
            builder: (context) => ProductDialog(),
            barrierDismissible: false,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        label: Text("Înregistrare"),
        icon: Icon(Icons.settings_overscan),
      ),
    );
  }
}
