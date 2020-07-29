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
    await Barcode.onCreate(db);
    await ImportTransaction.onCreate(db);
    await ExportTransaction.onCreate(db);
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

class Barcode {
  static final table = 'barcode';
  static final id = 'id';
  static final barcode = 'barcode';
  static final startDate = 'start_date';

  static onCreate(db) async {
    await db.execute('''
          CREATE TABLE $table (
            $id INTEGER PRIMARY KEY AUTOINCREMENT,
            $barcode TEXT NOT NULL UNIQUE,
            $startDate DATETIME NOT NULL
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

class ImportTransaction {
  static final table = 'import_transaction';

  static final id = 'id';
  static final barcodeId = 'barcode_id';
  static final quantity = 'quantity';
  static final importDate = 'import_date';

  static onCreate(db) async {
    await db.execute('''
          CREATE TABLE $table (
            $id INTEGER PRIMARY KEY AUTOINCREMENT,
            $barcodeId TEXT NOT NULL,
            $quantity INTEGER NOT NULL,
            $importDate DATETIME NOT NULL,
            FOREIGN KEY ($barcodeId) REFERENCES ${Barcode.table}(${Barcode.id})
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

  static queryWithBarcodes() async {
    Database db = await AppDatabase.instance.database;
    return db.rawQuery('SELECT '
        'b.${Barcode.barcode} AS ${Barcode.barcode}, '
        'it.${ImportTransaction.quantity} AS ${ImportTransaction.quantity}, '
        'it.${ImportTransaction.importDate} AS ${ImportTransaction.importDate} '
        'FROM ${Barcode.table} b JOIN ${ImportTransaction.table} it '
        'ON b.${Barcode.id} = it.${ImportTransaction.barcodeId}');
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

class ExportTransaction {
  static final table = 'export_transaction';

  static final id = 'id';
  static final barcodeId = 'barcode_id';
  static final quantity = 'quantity';
  static final exportDate = 'export_date';

  static onCreate(db) async {
    await db.execute('''
          CREATE TABLE $table (
            $id INTEGER PRIMARY KEY AUTOINCREMENT,
            $barcodeId TEXT NOT NULL,
            $quantity INTEGER NOT NULL,
            $exportDate DATETIME NOT NULL,
            FOREIGN KEY ($barcodeId) REFERENCES ${Barcode.table}(${Barcode.id})
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

  static queryWithBarcodes() async {
    Database db = await AppDatabase.instance.database;
    return db.rawQuery('SELECT '
        'b.${Barcode.barcode} AS ${Barcode.barcode}, '
        'et.${ExportTransaction.quantity} AS ${ExportTransaction.quantity}, '
        'et.${ExportTransaction.exportDate} AS ${ExportTransaction.exportDate} '
        'FROM ${Barcode.table} b JOIN ${ExportTransaction.table} et '
        'ON b.${Barcode.id} = et.${ExportTransaction.barcodeId}');
  }

  static queryAvailableStock(id) async {
    Database db = await AppDatabase.instance.database;
    var importedStock = await db.rawQuery(
        'SELECT SUM(${ImportTransaction.quantity}) AS import_stock FROM '
        '${ImportTransaction.table} WHERE ${ImportTransaction.id}=$id');
    var exportedStock = await db.rawQuery(
        'SELECT SUM(${ExportTransaction.quantity}) AS export_stock FROM '
        '${ExportTransaction.table} WHERE ${ExportTransaction.id}=$id');
    var imported = importedStock[0]['import_stock'];
    var exported = exportedStock[0]['export_stock'];
    if (imported == null) imported = 0;
    if (exported == null) exported = 0;
    int available = imported - exported;
    return available;
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

  static delete(int anId) async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(table, where: '$id = ?', whereArgs: [anId]);
  }
}
