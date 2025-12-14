import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/product_provider.dart';
import 'data/product_repository.dart';
import 'screens/product_list_screen.dart';

void main() {
  runApp(const ProductManagementApp());
}

class ProductManagementApp extends StatelessWidget {
  const ProductManagementApp({super.key, this.repository});

  final ProductRepository? repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(repository: repository)..loadProducts(),
      child: MaterialApp(
        title: 'Ürün Yönetimi',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const ProductListScreen(),
      ),
    );
  }
}
