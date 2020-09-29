import 'dart:convert';
import 'dart:core';

import 'package:barcode_scanner/database_management/database_management.dart';
import 'package:flutter/material.dart';

class OperationsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => OperationsViewState();
}

class OperationsViewState extends State<OperationsView> {
  var history;

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
        title: Text("Depozitare"),
      ),
      body: FutureBuilder(
        future: Operation.instance.query(),
        builder: (context, snapshot) {
          List<Widget> children = [];
          if (snapshot.hasError) {
            children = <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Eroare: ${snapshot.error}'),
              )
            ];
          } else if (snapshot.hasData) {
            history = snapshot.data;
          } else {
            children = <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Se încarcă tranzacțiile efectuate...'),
              )
            ];
          }
          return (history == null)
              ? Center(
                  child: Column(
                    children: children,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, i) {
                    var data = jsonDecode(history[i][Operation.json]);
                    if (data.containsKey('product')) {
                      return ListTile(
                        title: Text(
                          "${i + 1}. ${data['product']['name']}",
                          style: TextStyle(
                            color: Colors.indigoAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("${data['product']['name']}"),
                                  content: Text(
                                      "Cod de bare: ${data['product'][Product.barcode]}\nData înregistrării: ${data['product'][Product.registrationDate]}"),
                                );
                              });
                        },
                      );
                    } else if (data.containsKey('transactions')) {
                      return ListTile(
                        title: Text(
                          "${i + 1}. ${data['transactions'][Transaction.productId]}\n${((data['transactions'][Transaction.quantity] > 0)?"+":"-")}${data['transactions'][Transaction.quantity].abs()}",
                          style: TextStyle(
                            color:
                                (data['transactions'][Transaction.quantity] > 0)
                                    ? Colors.green
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    (data['transactions']
                                                [Transaction.quantity] >
                                            0)
                                        ? "Import"
                                        : "Export",
                                  ),
                                  content: Text(
                                      "Data tranzacției: ${data['transactions'][Transaction.transactionDate]}"),
                                );
                              });
                        },
                      );
                    } else
                      return ListTile(
                        title: Text(
                          "$data",
                        ),
                      );
                  },
                );
        },
      ),
    );
  }
}
