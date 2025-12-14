import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const _databaseName = 'products.db';
const _databaseVersion = 1;
const productTable = 'products';

class ProductDatabaseProvider {
  ProductDatabaseProvider._internal();

  static final ProductDatabaseProvider instance =
      ProductDatabaseProvider._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $productTable (
            barcode TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            unit_price REAL NOT NULL,
            tax_rate INTEGER NOT NULL,
            price REAL NOT NULL,
            stock INTEGER
          )
        ''');
      },
    );
  }
}
