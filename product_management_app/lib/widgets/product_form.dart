import 'package:flutter/material.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';

Future<bool> showProductFormDialog({
  required BuildContext context,
  required ProductProvider provider,
  Product? initialProduct,
  String? initialBarcode,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return ProductFormDialog(
        provider: provider,
        initialProduct: initialProduct,
        initialBarcode: initialBarcode,
      );
    },
  );

  return result ?? false;
}

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({
    super.key,
    required this.provider,
    this.initialProduct,
    this.initialBarcode,
  });

  final ProductProvider provider;
  final Product? initialProduct;
  final String? initialBarcode;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  late final TextEditingController _barcodeController;
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _taxRateController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final product = widget.initialProduct;

    _barcodeController = TextEditingController(
      text: product?.barcode ?? widget.initialBarcode ?? '',
    );
    _nameController = TextEditingController(text: product?.name ?? '');
    _categoryController = TextEditingController(text: product?.category ?? '');
    _unitPriceController = TextEditingController(
      text: product != null ? product.unitPrice.toStringAsFixed(2) : '',
    );
    _taxRateController = TextEditingController(
      text: product != null ? product.taxRate.toString() : '',
    );
    _priceController = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(2) : '',
    );
    _stockController = TextEditingController(
      text: product?.stock?.toString() ?? '',
    );

    _unitPriceController.addListener(_recalculatePrice);
    _taxRateController.addListener(_recalculatePrice);

    WidgetsBinding.instance.addPostFrameCallback((_) => _recalculatePrice());
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _unitPriceController.removeListener(_recalculatePrice);
    _taxRateController.removeListener(_recalculatePrice);
    _unitPriceController.dispose();
    _taxRateController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _recalculatePrice() {
    final rawUnit = _unitPriceController.text.replaceAll(',', '.');
    final rawTax = _taxRateController.text;
    final unitPrice = double.tryParse(rawUnit);
    final taxRate = int.tryParse(rawTax);
    if (unitPrice != null && taxRate != null) {
      final price = unitPrice * (1 + (taxRate / 100));
      final formatted = price.toStringAsFixed(2);
      _priceController.value = _priceController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else {
      _priceController.value = _priceController.value.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final barcode = _barcodeController.text.trim();
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final unitPrice = double.parse(_unitPriceController.text.replaceAll(',', '.'));
    final taxRate = int.parse(_taxRateController.text);
    final computedPrice = unitPrice * (1 + (taxRate / 100));
    final stockText = _stockController.text.trim();
    final stock = stockText.isEmpty ? null : int.parse(stockText);

    final product = Product(
      barcode: barcode,
      name: name,
      category: category,
      unitPrice: unitPrice,
      taxRate: taxRate,
      price: computedPrice,
      stock: stock,
    );

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    final isNewProduct = widget.initialProduct == null;
    final success = isNewProduct
        ? await widget.provider.addProduct(product)
        : await widget.provider.updateProduct(product);

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _formError = widget.provider.errorMessage ?? 'İşlem sırasında hata oluştu.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialProduct != null;

    return AlertDialog(
      title: Text(isEditing ? 'Ürünü Düzenle' : 'Ürün Ekle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Barkod Numarası',
                  border: OutlineInputBorder(),
                ),
                readOnly: isEditing,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Barkod zorunludur.';
                  }
                  if (value.length < 3) {
                    return 'Barkod en az 3 karakter olmalıdır.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ürün Adı',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ürün adı zorunludur.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kategori zorunludur.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unitPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Birim Fiyat',
                        border: OutlineInputBorder(),
                        suffixText: '₺',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Birim fiyat zorunludur.';
                        }
                        final normalized = value.replaceAll(',', '.');
                        final parsed = double.tryParse(normalized);
                        if (parsed == null || parsed <= 0) {
                          return 'Geçerli bir pozitif değer girin.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _taxRateController,
                      decoration: const InputDecoration(
                        labelText: 'Vergi Oranı (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vergi oranı zorunludur.';
                        }
                        final parsed = int.tryParse(value);
                        if (parsed == null || parsed < 0) {
                          return 'Geçerli bir oran girin.';
                        }
                        if (parsed > 100) {
                          return 'Vergi oranı 100\'den büyük olamaz.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Vergili Fiyat',
                  border: OutlineInputBorder(),
                  suffixText: '₺',
                ),
                readOnly: true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stok (Opsiyonel)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed < 0) {
                    return 'Stok negatif olamaz.';
                  }
                  return null;
                },
              ),
              if (_formError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _formError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Güncelle' : 'Kaydet'),
        ),
      ],
    );
  }
}
