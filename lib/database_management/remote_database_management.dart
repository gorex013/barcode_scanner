import 'dart:convert';

import 'package:http/http.dart';

class Product {
  static final table = 'products';
  static final id = 'id';
  static final barcode = 'barcode';
  static final name = 'name';
  static final registrationDate = 'registration_date';
  static query(){}
  static insert(Map<String, dynamic> row) async {return post(jsonEncode(row),);}
  static update(Map<String, dynamic> row) async {}
  static delete(Map<String, dynamic> row) async {}
}

class Transaction {
  static final table = 'transactions';

  static final id = 'id';
  static final productId = 'product_id';
  static final quantity = 'quantity';
  static final transactionDate = 'transaction_date';
  static query() async {}

  // for import quantity > 0
  static queryImport() async {}
  // for export quantity < 0
  static queryExport() async {}
  // stock is sum(quantity)
  static queryStock({int id, String barcode}) async {}
  static insert(Map<String, dynamic> row) async {}
  static update(Map<String, dynamic> row) async {}
}