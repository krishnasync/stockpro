import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/inventory_remote_datasource.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/warehouse_entity.dart';
import '../../domain/repositories/inventory_repository.dart';

final inventoryRemoteDataSourceProvider =
    Provider<InventoryRemoteDataSource>((ref) {
  return InventoryRemoteDataSource(ref.watch(supabaseClientProvider));
});

/// Depends on the current user's companyId, so this provider only makes
/// sense once someone is logged in — screens that use it should already
/// be behind the auth-gated router.
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final companyId = ref.watch(currentUserProvider).value?.companyId;
  return InventoryRepositoryImpl(
    ref.watch(inventoryRemoteDataSourceProvider),
    companyId ?? '',
  );
});

final warehousesProvider =
    FutureProvider.autoDispose<List<WarehouseEntity>>((ref) async {
  final result =
      await ref.read(inventoryRepositoryProvider).getOrCreateWarehouses();
  return result.when(
    success: (warehouses) => warehouses,
    failure: (f) => throw f,
  );
});