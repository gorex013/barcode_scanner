import 'package:barcode_scanner/database_management/remote_database_management.dart';
import 'package:flutter/material.dart';

class ProductList extends StatelessWidget {
  final host;
  final port;
  final apiKey;

  const ProductList({Key key, this.host, this.port, this.apiKey}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    var history;
    var product = Product(host, port, apiKey);
    var transaction = Transaction(host, port, apiKey);
    return FutureBuilder(
      future: product.query(),
      builder: (context, snapshot) {
        List<Widget> children = [];
        if (snapshot.hasData) {
          history = snapshot.data;
        } else if (snapshot.hasError) {
          children = <Widget>[
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Eroare : ${snapshot.error}'),
            )
          ];
        } else {
          children = <Widget>[
            SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Se încarcă produsele înregistrate...'),
            )
          ];
        }
        return (history == null)
            ? Center(
                child: Column(
                  children: children,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
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
                      var stock = await transaction.queryStock(id: productId);
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
