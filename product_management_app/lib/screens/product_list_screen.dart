import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_form.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _barcodeController = TextEditingController();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _onSearch(ProductProvider provider) async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen barkod numarası girin.')),
      );
      return;
    }

    final product = await provider.searchByBarcode(barcode);
    if (!mounted) {
      return;
    }

    if (product == null) {
      await _showProductNotFoundDialog(barcode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} bulundu.')),
      );
    }
  }

  Future<void> _showProductNotFoundDialog(String barcode) async {
    final provider = context.read<ProductProvider>();
    final shouldAdd = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ürün bulunamadı'),
            content: const Text('Yeni ürün eklemek ister misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Ekle'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldAdd && mounted) {
      _openProductForm(provider: provider, initialBarcode: barcode);
    }
  }

  Future<void> _openProductForm({
    required ProductProvider provider,
    Product? product,
    String? initialBarcode,
  }) async {
    final saved = await showProductFormDialog(
      context: context,
      provider: provider,
      initialProduct: product,
      initialBarcode: initialBarcode,
    );

    if (!mounted || !saved) {
      return;
    }

    final message = product == null ? 'Ürün eklendi.' : 'Ürün güncellendi.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDelete(
    ProductProvider provider,
    Product product,
  ) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Silme Onayı'),
            content: Text('${product.name} ürününü silmek istediğinizden emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('İptal'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sil'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldDelete) {
      final success = await provider.deleteProduct(product.barcode);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Ürün silindi.' : provider.errorMessage ?? 'Ürün silinemedi.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Yönetimi'),
      ),
      floatingActionButton: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (isSmallScreen) {
            return FloatingActionButton(
              onPressed: () => _openProductForm(provider: provider),
              child: const Icon(Icons.add),
            );
          }
          return FloatingActionButton.extended(
            onPressed: () => _openProductForm(provider: provider),
            icon: const Icon(Icons.add),
            label: const Text('Ürün Ekle'),
          );
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
        child: Consumer<ProductProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = provider.products;
            final selectedBarcode = provider.selectedProduct?.barcode;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 500) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _barcodeController,
                            decoration: const InputDecoration(
                              labelText: 'Barkod Numarası',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: provider.isLoading
                                      ? null
                                      : () => _onSearch(provider),
                                  icon: const Icon(Icons.search),
                                  label: const Text('Ara'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: provider.isLoading
                                      ? null
                                      : () {
                                          _barcodeController.clear();
                                          provider.clearFilter();
                                        },
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Temizle'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    
                    // Büyük ekranlar için yatay düzen
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _barcodeController,
                            decoration: const InputDecoration(
                              labelText: 'Barkod Numarası',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: provider.isLoading
                              ? null
                              : () => _onSearch(provider),
                          icon: const Icon(Icons.search),
                          label: const Text('Ara'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: provider.isLoading
                              ? null
                              : () {
                                  _barcodeController.clear();
                                  provider.clearFilter();
                                },
                          icon: const Icon(Icons.clear),
                          label: const Text('Temizle'),
                        ),
                      ],
                    );
                  },
                ),
                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: products.isEmpty
                      ? const Center(child: Text('Henüz ürün eklenmedi.'))
                      : _ProductTable(
                          products: products,
                          selectedBarcode: selectedBarcode,
                          onEdit: (product) =>
                              _openProductForm(provider: provider, product: product),
                          onDelete: (product) => _confirmDelete(provider, product),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductTable extends StatelessWidget {
  const _ProductTable({
    required this.products,
    required this.selectedBarcode,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Product> products;
  final String? selectedBarcode;
  final void Function(Product product) onEdit;
  final void Function(Product product) onDelete;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: isSmallScreen 
              ? MediaQuery.of(context).size.width 
              : 600,
        ),
        child: DataTable(
          columnSpacing: isSmallScreen ? 12 : 56,
          horizontalMargin: isSmallScreen ? 12 : 24,
          columns: const [
            DataColumn(label: Text('Barkod')),
            DataColumn(label: Text('Ürün Adı')),
            DataColumn(label: Text('Kategori')),
            DataColumn(label: Text('Birim Fiyat')),
            DataColumn(label: Text('Vergi (%)')),
            DataColumn(label: Text('Fiyat')),
            DataColumn(label: Text('Stok')),
            DataColumn(label: Text('İşlemler')),
          ],
          rows: products.map((product) {
            final isSelected = product.barcode == selectedBarcode;
            final highlightColor = Theme.of(context)
                .colorScheme
                .secondaryContainer
                .withValues(alpha: .4);

            return DataRow(
              color: isSelected ? WidgetStateProperty.all(highlightColor) : null,
              cells: [
                DataCell(Text(product.barcode)),
                DataCell(Text(product.name)),
                DataCell(Text(product.category)),
                DataCell(Text(product.unitPrice.toStringAsFixed(2))),
                DataCell(Text(product.taxRate.toString())),
                DataCell(Text(product.price.toStringAsFixed(2))),
                DataCell(Text(product.stock?.toString() ?? '-')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Düzenle',
                        onPressed: () => onEdit(product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Sil',
                        onPressed: () => onDelete(product),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
