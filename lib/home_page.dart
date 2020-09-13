import 'package:barcode_scanner/database_management/database_management.dart';
import 'package:barcode_scanner/scan_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'product_registration/product_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manager depozit',
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () async {
                var needReload =
                    await Navigator.pushNamed(context, '/settings');
              })
        ],
      ),
      body: HomeBody(),
    );
  }
}

class HomeBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeBody();
}

class _HomeBody extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 10,
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  label: Text("Depozitare produse"),
                  icon: Icon(Icons.arrow_downward),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ScanDialog(
                          Text('Depozitare produs'),
                          Transaction().insert,
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
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 10,
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  label: Text("Extragere produse"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ScanDialog(
                          Text('Extragere produs'),
                          Transaction().insert,
                          (id, quantity) => <String, dynamic>{
                            Transaction.productId: id,
                            Transaction.quantity: quantity,
                            Transaction.transactionDate:
                                DateTime.now().toIso8601String(),
                          },
                          availableStockFunction: Transaction().queryStock,
                          outFlag: true,
                        );
                      },
                      barrierDismissible: false,
                    );
                  },
                  icon: Icon(Icons.arrow_upward),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 10,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              label: Text("Înregistrare produs"),
              icon: Icon(Icons.settings_overscan),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ProductDialog(),
                  barrierDismissible: false,
                );
              },
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}
