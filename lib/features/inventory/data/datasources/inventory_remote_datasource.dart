import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/warehouse_entity.dart';

class InventoryRemoteDataSource {
  final SupabaseClient _client;
  InventoryRemoteDataSource(this._client);

  Future<List<WarehouseEntity>> getOrCreateWarehouses(String companyId) async {
    final rows = await _client
        .from('warehouses')
        .select('id, name, is_default')
        .eq('company_id', companyId)
        .eq('is_active', true)
        .order('name');

    if (rows.isNotEmpty) {
      return rows
          .map<WarehouseEntity>((r) => WarehouseEntity(
                id: r['id'] as String,
                name: r['name'] as String,
                isDefault: r['is_default'] as bool? ?? false,
              ))
          .toList();
    }

    // No warehouse yet for this company — create one automatically so
    // Inventory works without a separate setup step.
    final created = await _client
        .from('warehouses')
        .insert({
          'company_id': companyId,
          'name': 'Main Warehouse',
          'is_default': true,
        })
        .select('id, name, is_default')
        .single();

    return [
      WarehouseEntity(
        id: created['id'] as String,
        name: created['name'] as String,
        isDefault: true,
      ),
    ];
  }

  /// Writes to BOTH tables, in order:
  /// 1. stock_movements — the permanent, append-only ledger. This row is
  ///    never edited or deleted; it's the audit trail.
  /// 2. stock_levels — the fast-read cache of "how much is there right
  ///    now". We read-then-write here (not a Postgres upsert) because our
  ///    unique constraint includes the nullable batch_id column, and
  ///    Postgres treats NULL != NULL for uniqueness — an ON CONFLICT
  ///    upsert would silently insert duplicate rows instead of updating.
  Future<void> addStock({
    required String companyId,
    required String productId,
    required String warehouseId,
    required double quantity,
    required String movementType,
    String? notes,
  }) async {
    await _client.from('stock_movements').insert({
      'company_id': companyId,
      'product_id': productId,
      'warehouse_id': warehouseId,
      'movement_type': movementType,
      'quantity': quantity,
      'notes': notes,
    });

    final existing = await _client
        .from('stock_levels')
        .select('id, quantity')
        .eq('product_id', productId)
        .eq('warehouse_id', warehouseId)
        .filter('batch_id', 'is', null)
        .maybeSingle();

    if (existing == null) {
      await _client.from('stock_levels').insert({
        'company_id': companyId,
        'product_id': productId,
        'warehouse_id': warehouseId,
        'quantity': quantity,
      });
    } else {
      final currentQty = (existing['quantity'] as num).toDouble();
      await _client
          .from('stock_levels')
          .update({'quantity': currentQty + quantity})
          .eq('id', existing['id'] as String);
    }
  }
}