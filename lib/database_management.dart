import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final _databaseName = "app_db.db";
  static final _databaseVersion = 1;

  AppDatabase._privateConstructor();

  static final AppDatabase instance = AppDatabase._privateConstructor();

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  Future _onCreate(Database db, int version) async {
    await Product.onCreate(db);
    await Transaction.onCreate(db);
  }

  Future<bool> deleteDb() async {
    bool databaseDeleted = false;

    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, _databaseName);
      await deleteDatabase(path).whenComplete(() {
        databaseDeleted = true;
      }).catchError((onError) {
        databaseDeleted = false;
      });
    } on DatabaseException catch (error) {
      print(error);
    } catch (error) {
      print(error);
    }
    return databaseDeleted;
  }
}

class Product {
  static final table = 'product';
  static final id = 'id';
  static final barcode = 'barcode';
  static final name = 'name';
  static final registrationDate = 'registration_date';

  static onCreate(db) async {
    await db.execute('''
          CREATE TABLE $table (
            $id INTEGER PRIMARY KEY AUTOINCREMENT,
            $barcode TEXT NOT NULL UNIQUE,
            $name TEXT NOT NULL,
            $registrationDate DATETIME NOT NULL
          );
          ''');
  }

  static query(
      {bool distinct,
      List<String> columns,
      String where,
      List<dynamic> whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) async {
    Database db = await AppDatabase.instance.database;
    return db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  static insert(Map<String, dynamic> row) async {
    var database = await AppDatabase.instance.database;
    return database.insert(table, row);
  }

  static update(Map<String, dynamic> row) async {
    Database db = await AppDatabase.instance.database;
    int anId = row[id];
    return await db.update(table, row, where: '$id = ?', whereArgs: [anId]);
  }
}

class Transaction {
  static final table = 'transactions';

  static final id = 'id';
  static final productId = 'product_id';
  static final quantity = 'quantity';
  static final transactionDate = 'transaction_date';

  static onCreate(db) async {
    await db.execute('''
          CREATE TABLE $table (
            $id INTEGER PRIMARY KEY AUTOINCREMENT,
            $productId INTEGER NOT NULL,
            $quantity INTEGER NOT NULL,
            $transactionDate DATETIME NOT NULL,
            FOREIGN KEY ($productId) REFERENCES ${Product.table}(${Product.id})
          );
          ''');
  }

  static query(
      {bool distinct,
      List<String> columns,
      String where,
      List<dynamic> whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) async {
    Database db = await AppDatabase.instance.database;
    return db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  static queryImport() async {
    Database db = await AppDatabase.instance.database;
    return db.rawQuery('SELECT '
        'b.${Product.barcode} AS ${Product.barcode}, '
        't.${Transaction.quantity} AS ${Transaction.quantity}, '
        't.${Transaction.transactionDate} AS ${Transaction.transactionDate} '
        'FROM ${Product.table} b JOIN ${Transaction.table} t '
        'ON b.${Product.id} = t.${Transaction.productId} WHERE t.${Transaction.quantity} > 0');
  }

  static insert(Map<String, dynamic> row) async {
    var database = await AppDatabase.instance.database;
    return database.insert(table, row);
  }

  static update(Map<String, dynamic> row) async {
    Database db = await AppDatabase.instance.database;
    int anId = row[id];
    return await db.update(table, row, where: '$id = ?', whereArgs: [anId]);
  }

  static queryExport() async {
    Database db = await AppDatabase.instance.database;
    return db.rawQuery('SELECT '
        'b.${Product.barcode} AS ${Product.barcode}, '
        't.${Transaction.quantity} AS ${Transaction.quantity}, '
        't.${Transaction.transactionDate} AS ${Transaction.transactionDate} '
        'FROM ${Product.table} b JOIN ${Transaction.table} t '
        'ON b.${Product.id} = t.${Transaction.productId} WHERE t.${Transaction.quantity} < 0');
  }

  static queryStock({int id, String barcode}) async {
    Database db = await AppDatabase.instance.database;
    if (id == null && barcode != null){
      id = Sqflite.firstIntValue(await db.query(Product.table, columns:[Product.id],where: '${Product.barcode} = $barcode'));
    } else if(id == null && barcode == null || id != null && barcode != null){
      throw ArgumentError("Either `id` or `barcode` should be given!");
    } else
    return db.rawQuery('SELECT '
        'SUM(${Transaction.quantity}) AS stock FROM ${Transaction.table}');
  }
}
