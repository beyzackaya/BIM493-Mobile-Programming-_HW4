// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:product_management_app/main.dart';
import 'package:product_management_app/models/product.dart';
import 'package:product_management_app/data/product_repository.dart';

void main() {
  testWidgets('Product list screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProductManagementApp(repository: _FakeProductRepository()),
    );

    await tester.pump();

    expect(find.text('Ürün Yönetimi'), findsOneWidget);
    expect(find.text('Barkod Numarası'), findsOneWidget);
  });
}

class _FakeProductRepository extends ProductRepository {
  _FakeProductRepository() : super();

  final List<Product> _items = [];

  @override
  Future<List<Product>> getAllProducts() async {
    return List<Product>.unmodifiable(_items);
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      return _items.firstWhere((item) => item.barcode == barcode);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> insertProduct(Product product) async {
    _items.add(product);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final index = _items.indexWhere((item) => item.barcode == product.barcode);
    if (index != -1) {
      _items[index] = product;
    }
  }

  @override
  Future<void> deleteProduct(String barcode) async {
    _items.removeWhere((item) => item.barcode == barcode);
  }
}
