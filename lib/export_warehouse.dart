import 'package:flutter/material.dart';

class ExportWarehouse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExportWarehouse();
}

class _ExportWarehouse extends State<ExportWarehouse> {
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
      body: Center(
        child: Text('Export'),
      ),
    );
  }
}
