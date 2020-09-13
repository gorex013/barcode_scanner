import 'package:barcode_scanner/database_management/database_management.dart';
import 'package:barcode_scanner/product_registration/product_dialog.dart';
import 'package:flutter/material.dart';

class RegisterProduct extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterProduct();
}

class _RegisterProduct extends State<RegisterProduct> {
  var needReload;

  @override
  Widget build(BuildContext context) {
    var history;
    var product = Product();
    var transaction = Transaction();
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
      body: FutureBuilder(
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
          needReload = false;
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
                              "Barcode: ${history[i][Product.barcode]}\n"
                              "Data înregistrării: "
                              "${dateTime.day.toString().padLeft(2, '0')}/"
                              "${dateTime.month.toString().padLeft(2, '0')}/"
                              "${dateTime.year} "
                              "${dateTime.hour.toString().padLeft(2, '0')}:"
                              "${dateTime.minute.toString().padLeft(2, '0')}\n"
                              "Stoc: $stock unități",
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
        },
      ),
      bottomNavigationBar: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        child: RaisedButton.icon(
          onPressed: () async {
            var _needReload = await showDialog(
              context: context,
              builder: (context) => ProductDialog(),
              barrierDismissible: false,
            );
            if (_needReload) setState(() {});
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          label: Text("Înregistrare"),
          icon: Icon(Icons.settings_overscan),
        ),
      ),
    );
  }
}
