import 'package:barcode_scanner/product_registration/bottom_button.dart';
import 'package:barcode_scanner/product_registration/product_list.dart';
import 'package:flutter/material.dart';

class RegisterProduct extends StatefulWidget {
  final host;
  final port;
  final apiKey;

  const RegisterProduct({Key key, this.host, this.port, this.apiKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterProduct();
}

class _RegisterProduct extends State<RegisterProduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Înregistrare produse"),
      ),
      body: ProductList(
        host: widget.host,
        port: widget.port,
        apiKey: widget.apiKey,
      ),
      bottomNavigationBar: BottomButton(),
    );
  }
}
