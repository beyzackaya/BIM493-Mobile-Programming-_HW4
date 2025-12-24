import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../data/product_repository.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;

  final List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;
  String? _searchFilter;

  List<Product> get products {
    if (_searchFilter != null && _searchFilter!.isNotEmpty) {
      return List.unmodifiable(
        _products.where((p) => p.barcode == _searchFilter).toList(),
      );
    }
    return List.unmodifiable(_products);
  }
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      final items = await _repository.getAllProducts();
      _products
        ..clear()
        ..addAll(items);
      _selectedProduct = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Ürünler yüklenirken hata oluştu.';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<Product?> searchByBarcode(String barcode) async {
    _setLoading(true);
    try {
      final product = await _repository.getProductByBarcode(barcode);
      _selectedProduct = product;
      _searchFilter = barcode;
      _errorMessage = null;
      return product;
    } catch (e) {
      _errorMessage = 'Ürün aranırken hata oluştu.';
      return null;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product product) async {
    _setLoading(true);
    try {
      await _repository.insertProduct(product);
      _products.add(product);
      _selectedProduct = product;
      _errorMessage = null;
      return true;
    } on DatabaseException catch (dbError) {
      if (dbError.isUniqueConstraintError()) {
        _errorMessage = 'Bu barkod zaten kayıtlı.';
      } else {
        _errorMessage = 'Ürün eklenirken hata oluştu.';
      }
      return false;
    } catch (e) {
      _errorMessage = 'Ürün eklenirken hata oluştu.';
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> updateProduct(Product product) async {
    _setLoading(true);
    try {
      await _repository.updateProduct(product);
      final index = _products.indexWhere(
        (element) => element.barcode == product.barcode,
      );
      if (index != -1) {
        _products[index] = product;
      }
      _selectedProduct = product;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Ürün güncellenirken hata oluştu.';
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String barcode) async {
    _setLoading(true);
    try {
      await _repository.deleteProduct(barcode);
      _products.removeWhere((element) => element.barcode == barcode);
      if (_selectedProduct?.barcode == barcode) {
        _selectedProduct = null;
      }
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Ürün silinirken hata oluştu.';
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedProduct = null;
    notifyListeners();
  }

  void clearFilter() {
    _searchFilter = null;
    _selectedProduct = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }
}
