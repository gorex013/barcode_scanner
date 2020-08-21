import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class Product {
  static final table = 'products';
  static final id = 'id';
  static final barcode = 'barcode';
  static final name = 'name';
  static final registrationDate = 'registration_date';

  readKey() async {
    final directory = await getApplicationDocumentsDirectory();
    final apiFile = File('${directory.path}/warehouse.key');
    if (!await apiFile.exists()) {
      return null;
    }
    var apiKey = utf8.decode(await apiFile.readAsBytes());
    if (apiKey.isEmpty) return null;
    return apiKey;
  }

  readHost() async {
    final directory = await getApplicationDocumentsDirectory();
    final hostFile = File('${directory.path}/host.data');
    if (!await hostFile.exists()) {
      return null;
    }
    var host = utf8.decode(await hostFile.readAsBytes());
    if (host.isEmpty) return null;
    return host;
  }

  readPort() async {
    final directory = await getApplicationDocumentsDirectory();
    final portFile = File('${directory.path}/port.data');
    if (!await portFile.exists()) {
      return null;
    }
    var host = utf8.decode(await portFile.readAsBytes());
    if (host.isEmpty) return null;
    return host;
  }

  query() async {
    var apiKey = await readKey();
    var host = await readHost();
    var port = await readPort();
    var source = await get('http://$host:$port/api/products?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  insert(Map<String, dynamic> row) async {
    var apiKey = await readKey();
    var host = await readHost();
    var port = await readPort();
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
    var apiKey = await readKey();
    var host = await readHost();
    var port = await readPort();
    var source =
        await get('http://$host:$port/api/barcode/$barcode?api_token=$apiKey');
    return jsonDecode(source.body);
  }
}

class Transaction {
  static final table = 'transactions';

  static final id = 'id';
  static final productId = 'product_id';
  static final quantity = 'quantity';
  static final transactionDate = 'transaction_date';

  readKey() async {
    final directory = await getApplicationDocumentsDirectory();
    final apiFile = File('${directory.path}/warehouse.key');
    if (!await apiFile.exists()) {
      return null;
    }
    var apiKey = utf8.decode(await apiFile.readAsBytes());
    if (apiKey.isEmpty) return null;
    return apiKey;
  }

  readHost() async {
    final directory = await getApplicationDocumentsDirectory();
    final hostFile = File('${directory.path}/host.data');
    if (!await hostFile.exists()) {
      return null;
    }
    var host = utf8.decode(await hostFile.readAsBytes());
    if (host.isEmpty) return null;
    return host;
  }

  readPort() async {
    final directory = await getApplicationDocumentsDirectory();
    final portFile = File('${directory.path}/port.data');
    if (!await portFile.exists()) {
      return null;
    }
    var host = utf8.decode(await portFile.readAsBytes());
    if (host.isEmpty) return null;
    return host;
  }

  query() async {
    var apiKey = await readKey();
    var host = await readHost();
    var port = await readPort();
    var source =
        await get('http://$host:$port/api/transaction?api_token=$apiKey');
    return jsonDecode(source.body);
  }
  queryAll() async {
    var apiKey = await readKey();
    var host = await readHost();
    var port = await readPort();
    var source =
        await get('http://$host:$port/api/all_transaction?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  // for import quantity > 0
  queryImport() async {
    var apiKey = await readKey();
    var host = await readHost();
    var port = await readPort();
    var source = await get(
        'http://$host:$port/api/import_transaction?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  // for export quantity < 0
  queryExport() async {
    var apiKey = await readKey();
    var host = await readHost();
    var port = await readPort();
    var source = await get(
        'http://$host:$port/api/export_transaction?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  // stock is sum(quantity)
  queryStock({int id, String barcode}) async {
    var apiKey = await readKey();
    var host = await readHost();
    var port = await readPort();
    var source =
        await get('http://$host:$port/api/stock/$id?api_token=$apiKey');
    return jsonDecode(source.body);
  }

  insert(Map<String, dynamic> row) async {
    var apiKey = await readKey();
    var host = await readHost();
    var port = await readPort();
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
