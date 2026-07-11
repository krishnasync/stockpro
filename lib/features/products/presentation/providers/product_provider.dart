import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

final productRemoteDataSourceProvider =
    Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource(ref.watch(supabaseClientProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(productRemoteDataSourceProvider));
});

/// Search query as its own tiny provider so typing in the search box only
/// rebuilds the list, not the whole screen.
final productSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// AsyncNotifier that reloads whenever the search query changes.
final productListProvider =
    AsyncNotifierProvider.autoDispose<ProductListViewModel, List<ProductEntity>>(
  ProductListViewModel.new,
);

class ProductListViewModel
    extends AutoDisposeAsyncNotifier<List<ProductEntity>> {
  @override
  Future<List<ProductEntity>> build() async {
    final query = ref.watch(productSearchQueryProvider);
    final result = await ref
        .read(productRepositoryProvider)
        .getProducts(searchQuery: query);
    return result.when(
      success: (products) => products,
      failure: (f) => throw f, // surfaced as AsyncError by the framework
    );
  }
}
