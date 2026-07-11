class ProductEntity {
  final String id;
  final String name;
  final String sku;
  final String? barcode;
  final double purchasePrice;
  final double sellingPrice;
  final double minStock;
  final double reorderLevel;
  final double currentStock; // aggregated from stock_levels across warehouses
  final String? categoryName;
  final bool isActive;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.minStock,
    required this.reorderLevel,
    required this.currentStock,
    this.categoryName,
    this.isActive = true,
  });

  bool get isLowStock => currentStock <= reorderLevel;
  bool get isOutOfStock => currentStock <= 0;
}
