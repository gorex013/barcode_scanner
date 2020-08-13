import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

final host = '192.168.0.63';
final port = '8000';

readKey() async {
  final directory = await getApplicationDocumentsDirectory();
  final apiFile = File('${directory.path}/warehouse.key');
  final apiKey = utf8.decode(await apiFile.readAsBytes());
  return apiKey;
}

class Product {
  static final table = 'products';
  static final id = 'id';
  static final barcode = 'barcode';
  static final name = 'name';
  static final registrationDate = 'registration_date';

  static query() async {
    final apiKey = await readKey();
    var source = await get('http://$host:$port/api/products?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  static insert(Map<String, dynamic> row) async {
    final apiKey = await readKey();
    final requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': '$apiKey'
    };
    final data = jsonEncode(row);
    print(data);
    return await post(
      'http://$host:$port/api/products?api_token=$apiKey',
      body: data,
      headers: requestHeaders,
    );
  }

  static update(Map<String, dynamic> row) async {}

  static delete(Map<String, dynamic> row) async {}
}

class Transaction {
  static final table = 'transactions';

  static final id = 'id';
  static final productId = 'product_id';
  static final quantity = 'quantity';
  static final transactionDate = 'transaction_date';

  static query() async {
    final apiKey = await readKey();
    var source =
        await get('http://$host:$port/api/transaction?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  // for import quantity > 0
  static queryImport() async {
    final apiKey = await readKey();
    var source =
        await get('http://$host:$port/api/import_transaction?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  // for export quantity < 0
  static queryExport() async {
    final apiKey = await readKey();
    var source =
        await get('http://$host:$port/api/export_transaction?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  // stock is sum(quantity)
  static queryStock({int id, String barcode}) async {
    final apiKey = await readKey();
    var source =
        await get('http://$host:$port/api/stock/$id?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  static insert(Map<String, dynamic> row) async {
    final apiKey = await readKey();
    final requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': '$apiKey'
    };
    final data = jsonEncode(row);
    print(data);
    var response = await post(
      'http://$host:$port/api/transaction?api_token=$apiKey',
      body: data,
      headers: requestHeaders,
    );
    print(response.body);
    return response;
  }

  static update(Map<String, dynamic> row) async {}
}
