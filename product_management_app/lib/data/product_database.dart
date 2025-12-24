import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const _databaseName = 'products.db';
const _databaseVersion = 2;
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
            BarcodeNo TEXT PRIMARY KEY,
            ProductName TEXT NOT NULL,
            Category TEXT NOT NULL,
            UnitPrice REAL NOT NULL,
            TaxRate INTEGER NOT NULL,
            Price REAL NOT NULL,
            StockInfo INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Eski tabloyu sil ve yenisini oluştur
          await db.execute('DROP TABLE IF EXISTS $productTable');
          await db.execute('''
            CREATE TABLE $productTable (
              BarcodeNo TEXT PRIMARY KEY,
              ProductName TEXT NOT NULL,
              Category TEXT NOT NULL,
              UnitPrice REAL NOT NULL,
              TaxRate INTEGER NOT NULL,
              Price REAL NOT NULL,
              StockInfo INTEGER
            )
          ''');
        }
      },
    );
  }
}
