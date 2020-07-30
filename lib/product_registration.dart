import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'database_management.dart';

class RegisterProduct extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterProduct();
}

class _RegisterProduct extends State<RegisterProduct> {
  var history;
  var nameController = TextEditingController();
  var emptyNamePressed = false;

  var nameFocusNode = FocusNode();

//  void _scan() async {
//    var _result = await FlutterBarcodeScanner.scanBarcode(
//        "#ff4297", "Cancel", true, ScanMode.DEFAULT);
//    var queryResult = await Product.query(
//      where: '${Product.barcode} = \"$_result\"',
//    );
//    bool exists = queryResult.length != 0;
//    if (exists) {
//      showDialog(
//          context: context,
//          builder: (context) => AlertDialog(
//                content: Text("Produsul $_result există deja în baza de date."),
//              ));
//      return;
//    }
//  }

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
      body: FutureBuilder(
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
                      title: Text("${i + 1}.Name:${history[i][Product.name]}"),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Text(
                              "Barcode: ${history[i]['barcode']}\n"
                              "Date: ${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}",
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
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                title: Text("Înregistrare"),
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Denumire: ",
                          hintText: "Denumire produs ... ",
                          errorText: (emptyNamePressed)
                              ? "Denumire produs obligatorie"
                              : null,
                          contentPadding: EdgeInsets.all(10),
                        ),
                        controller: nameController,
                        focusNode: nameFocusNode,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (text) {
                          nameFocusNode.unfocus();
                        },
                        onTap: () {
                          FocusScope.of(context).requestFocus(nameFocusNode);
                        },
                        onEditingComplete: () {
                          nameFocusNode.unfocus();
                        },
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                  Row(
                    children: <Widget>[
                      RaisedButton.icon(
                        label: Text("Anulare"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.cancel),
                      ),
                      RaisedButton.icon(
                        onPressed: () async {
//                          if (unscanned) {
//                            setState(() {
//                              unscannedPressed = true;
//                            });
//                            return;
//                          }
//                          var number = int.tryParse(quantityController.text, radix: 10);
//                          if (emptyQuantity) {
//                            setState(() {
//                              emptyQuantity = quantityController.text == "" || number <= 0;
//                              emptyQuantityPressed = emptyQuantity;
//                            });
//                            return;
//                          }
//                          var barcodeID = await Product.query(
//                            columns: [Product.id],
//                            where: '${Product.barcode} = \"${scanController.text}\"',
//                          );
//                          barcodeID = barcodeID[0][Product.id];
//                          var maxStock;
//                          if (widget.availableStockFunction != null) {
//                            maxStock = await widget.availableStockFunction(barcodeID);
//                          } else {
//                            maxStock = double.maxFinite;
//                          }
//                          print(maxStock);
//                          if (exceedQuantity) {
//                            setState(() {
//                              exceedQuantity = number > maxStock;
//                              exceedQuantityPressed = exceedQuantity;
//                            });
//                            return;
//                          }
//                          widget.transactionInsert(
//                            widget.mapperFunction(barcodeID,
//                                int.parse(quantityController.text) * ((widget.outFlag) ? -1 : 1)),
//                          );
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.done),
                        label: Text("Terminat"),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  ),
                ],
              ),
              barrierDismissible: false,
            );
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
