class Product {
  Product({
    required this.barcode,
    required this.name,
    required this.category,
    required this.unitPrice,
    required this.taxRate,
    required this.price,
    this.stock,
  });

  final String barcode;
  final String name;
  final String category;
  final double unitPrice;
  final int taxRate;
  final double price;
  final int? stock;

  Product copyWith({
    String? barcode,
    String? name,
    String? category,
    double? unitPrice,
    int? taxRate,
    double? price,
    int? stock,
  }) {
    return Product(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      category: category ?? this.category,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'category': category,
      'unit_price': unitPrice,
      'tax_rate': taxRate,
      'price': price,
      'stock': stock,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      barcode: map['barcode'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      unitPrice: (map['unit_price'] as num).toDouble(),
      taxRate: map['tax_rate'] as int,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int?,
    );
  }
}
