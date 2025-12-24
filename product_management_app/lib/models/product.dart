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
      'BarcodeNo': barcode,
      'ProductName': name,
      'Category': category,
      'UnitPrice': unitPrice,
      'TaxRate': taxRate,
      'Price': price,
      'StockInfo': stock,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      barcode: map['BarcodeNo'] as String,
      name: map['ProductName'] as String,
      category: map['Category'] as String,
      unitPrice: (map['UnitPrice'] as num).toDouble(),
      taxRate: map['TaxRate'] as int,
      price: (map['Price'] as num).toDouble(),
      stock: map['StockInfo'] as int?,
    );
  }
}
