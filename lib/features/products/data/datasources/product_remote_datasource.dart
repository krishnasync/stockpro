import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/product_entity.dart';

class ProductRemoteDataSource {
  final SupabaseClient _client;
  ProductRemoteDataSource(this._client);

  Future<List<ProductEntity>> getProducts({
    String? searchQuery,
    String? categoryId,
    int page = 0,
    int pageSize = 25,
  }) async {
    // Sums stock_levels.quantity per product across warehouses via a
    // Postgres view (recommended: create `product_stock_summary` view in
    // Phase 4 migration) rather than doing the aggregation client-side.
    var query = _client.from('product_stock_summary').select('''
          id, name, sku, barcode, purchase_price, selling_price,
          min_stock, reorder_level, current_stock, is_active,
          categories ( name )
        ''');

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('name', '%$searchQuery%');
    }
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    final rows = await query
        .order('name')
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return rows.map<ProductEntity>(_mapRow).toList();
  }

  Future<ProductEntity> getProductById(String id) async {
    final row = await _client
        .from('product_stock_summary')
        .select('''
          id, name, sku, barcode, purchase_price, selling_price,
          min_stock, reorder_level, current_stock, is_active,
          categories ( name )
        ''')
        .eq('id', id)
        .single();
    return _mapRow(row);
  }

  Future<List<ProductEntity>> getLowStockProducts() async {
    final rows = await _client
        .from('product_stock_summary')
        .select('''
          id, name, sku, barcode, purchase_price, selling_price,
          min_stock, reorder_level, current_stock, is_active,
          categories ( name )
        ''')
        .filter('current_stock', 'lte', 'reorder_level')
        .order('current_stock');
    return rows.map<ProductEntity>(_mapRow).toList();
  }

  Future<ProductEntity> createProduct(Map<String, dynamic> payload) async {
    final row =
        await _client.from('products').insert(payload).select().single();
    return getProductById(row['id'] as String);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> payload) async {
    await _client.from('products').update(payload).eq('id', id);
  }

  Future<void> archiveProduct(String id) async {
    await _client.from('products').update({'is_active': false}).eq('id', id);
  }

  ProductEntity _mapRow(Map<String, dynamic> row) {
    return ProductEntity(
      id: row['id'] as String,
      name: row['name'] as String,
      sku: row['sku'] as String,
      barcode: row['barcode'] as String?,
      purchasePrice: (row['purchase_price'] as num).toDouble(),
      sellingPrice: (row['selling_price'] as num).toDouble(),
      minStock: (row['min_stock'] as num? ?? 0).toDouble(),
      reorderLevel: (row['reorder_level'] as num? ?? 0).toDouble(),
      currentStock: (row['current_stock'] as num? ?? 0).toDouble(),
      categoryName: row['categories']?['name'] as String?,
      isActive: row['is_active'] as bool? ?? true,
    );
  }
}
