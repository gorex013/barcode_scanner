import 'dart:convert';
import 'package:http/http.dart';

class Product {
  static final table = 'products';
  static final id = 'id';
  static final barcode = 'barcode';
  static final name = 'name';
  static final registrationDate = 'registration_date';
  final host;
  final port;
  final apiKey;

  Product(this.host, this.port, this.apiKey);
  query() async {
    var source = await get('http://$host:$port/api/products?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  insert(Map<String, dynamic> row) async {
    final requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': '$apiKey'
    };
    final data = jsonEncode(row);
    return await post(
      'http://$host:$port/api/products?api_token=$apiKey',
      body: data,
      headers: requestHeaders,
    );
  }

  update(Map<String, dynamic> row) async {}

  delete(Map<String, dynamic> row) async {}

  queryId(barcode) async {
    var source = await get('http://$host:$port/api/barcode/$barcode?api_token=$apiKey');
    return jsonDecode(source.body);
  }
}

class Transaction {
  static final table = 'transactions';

  static final id = 'id';
  static final productId = 'product_id';
  static final quantity = 'quantity';
  static final transactionDate = 'transaction_date';
  final host;
  final port;
  final apiKey;

  Transaction(this.host, this.port, this.apiKey);

  query() async {
    var source =
        await get('http://$host:$port/api/transaction?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  // for import quantity > 0
  queryImport() async {
    var source =
        await get('http://$host:$port/api/import_transaction?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  // for export quantity < 0
  queryExport() async {
    var source =
        await get('http://$host:$port/api/export_transaction?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  // stock is sum(quantity)
  queryStock({int id, String barcode}) async {
    var source =
        await get('http://$host:$port/api/stock/$id?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  insert(Map<String, dynamic> row) async {
    final requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': '$apiKey'
    };
    final data = jsonEncode(row);
    var response = await post(
      'http://$host:$port/api/transaction?api_token=$apiKey',
      body: data,
      headers: requestHeaders,
    );
    return response;
  }

  update(Map<String, dynamic> row) async {}
}
