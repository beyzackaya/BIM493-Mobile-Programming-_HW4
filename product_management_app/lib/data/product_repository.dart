import 'package:sqflite/sqflite.dart';

import '../models/product.dart';
import 'product_database.dart';

class ProductRepository {
  ProductRepository({Database? database})
      : _databaseProvider = ProductDatabaseProvider.instance,
        _databaseOverride = database;

  final ProductDatabaseProvider _databaseProvider;
  final Database? _databaseOverride;

  Future<Database> _getDatabase() async {
    if (_databaseOverride != null) {
      return _databaseOverride;
    }
    return _databaseProvider.database;
  }

  Future<List<Product>> getAllProducts() async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(productTable);
    return maps.map(Product.fromMap).toList();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      productTable,
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );
    if (maps.isEmpty) {
      return null;
    }
    return Product.fromMap(maps.first);
  }

  Future<void> insertProduct(Product product) async {
    final db = await _getDatabase();
    await db.insert(
      productTable,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<void> updateProduct(Product product) async {
    final db = await _getDatabase();
    await db.update(
      productTable,
      product.toMap(),
      where: 'barcode = ?',
      whereArgs: [product.barcode],
    );
  }

  Future<void> deleteProduct(String barcode) async {
    final db = await _getDatabase();
    await db.delete(
      productTable,
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
  }
}
