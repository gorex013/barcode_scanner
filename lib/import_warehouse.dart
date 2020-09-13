import 'package:barcode_scanner/scan_dialog.dart';
import 'package:flutter/material.dart';
import 'database_management/database_management.dart';

class ImportWarehouse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ImportWarehouse();
}

class _ImportWarehouse extends State<ImportWarehouse> {
  var history;

  @override
  Widget build(BuildContext context) {
    var transaction = Transaction();
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
        future: transaction.queryImport(),
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
                    var importDate =
                        DateTime.parse(history[i][Transaction.transactionDate]);
                    return ListTile(
                      title: Text("${i + 1}.  ${history[i][Product.name]} depozitat ${history[i][Transaction.quantity]} unități"),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Detalii"),
                          content: Text(
                            "Cantitate: ${history[i][Transaction.quantity]}\n"
                            "Data tranzacției: "
                            "${importDate.day.toString().padLeft(2, '0')}/"
                            "${importDate.month.toString().padLeft(2, '0')}/"
                            "${importDate.year} "
                            "${importDate.hour.toString().padLeft(2, '0')}:"
                            "${importDate.minute.toString().padLeft(2, '0')}\n"
                            "Barcod produs: ${history[i][Product.barcode]}",
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      bottomNavigationBar: SizedBox(
        width: MediaQuery.of(context).size.width - 10,
        child: RaisedButton.icon(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          label: Text("Depozitare"),
          icon: Icon(Icons.arrow_downward),
          onPressed: () async {
            showDialog(
              context: context,
              builder: (context) {
                return ScanDialog(
                  Text('Depozitare produs'),
                  transaction.insert,
                  (id, quantity) => <String, dynamic>{
                    Transaction.productId: id,
                    Transaction.quantity: quantity,
                    Transaction.transactionDate:
                        DateTime.now().toIso8601String(),
                  },
                );
              },
              barrierDismissible: false,
            );
          },
        ),
      ),
    );
  }
}
