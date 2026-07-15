import '../../../../core/errors/failures.dart';
import '../../domain/entities/warehouse_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource _remote;
  final String companyId;

  InventoryRepositoryImpl(this._remote, this.companyId);

  @override
  Future<Result<List<WarehouseEntity>>> getOrCreateWarehouses() async {
    try {
      return Result.success(
          await _remote.getOrCreateWarehouses(companyId));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addStock({
    required String productId,
    required String warehouseId,
    required double quantity,
    required String movementType,
    String? notes,
  }) async {
    try {
      await _remote.addStock(
        companyId: companyId,
        productId: productId,
        warehouseId: warehouseId,
        quantity: quantity,
        movementType: movementType,
        notes: notes,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}