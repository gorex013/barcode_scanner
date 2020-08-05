import 'package:barcode_scanner/database_management.dart';
import 'package:flutter/material.dart';

class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var history;
    return FutureBuilder(
      future: Product.query(),
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
              child: Text('Error: ${snapshot.error}'),
            )
          ];
        } else {
          history = snapshot.data;
        }
        return (history == null)
            ? Column(
                children: children,
              )
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, i) {
                  var dateTime =
                      DateTime.parse(history[i][Product.registrationDate]);
                  return ListTile(
                    title: Text("${i + 1}. ${history[i][Product.name]}"),
                    onTap: () async {
                      var productId = history[i][Product.id];
                      var stock = await Transaction.queryStock(id: productId);
                      if (stock == null || stock[0] == null || stock[0]['stock'] == null) stock = 0;
                      else {
                        stock=stock[0]['stock'];
                      }
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Text(
                            "Barcode: ${history[i]['barcode']}\n"
                            "Data înregistrării: ${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}\n"
                                "Stoc: $stock unități",
                          ),
                        ),
                      );
                    },
                  );
                },
              );
      },
    );
  }
}
