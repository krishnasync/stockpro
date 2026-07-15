import '../../../../core/errors/failures.dart';
import '../entities/warehouse_entity.dart';

abstract class InventoryRepository {
  /// Returns the company's warehouses. If none exist yet, creates a
  /// default "Main Warehouse" automatically — most small businesses only
  /// need one, and this avoids forcing a setup step before Inventory works.
  Future<Result<List<WarehouseEntity>>> getOrCreateWarehouses();

  /// Records a stock movement (the permanent ledger entry) AND updates the
  /// cached current quantity in stock_levels. movementType is 'IN' for
  /// purchases/restocking or 'ADJUSTMENT' for corrections; quantity is
  /// always positive — direction comes from movementType.
  Future<Result<void>> addStock({
    required String productId,
    required String warehouseId,
    required double quantity,
    required String movementType,
    String? notes,
  });
}