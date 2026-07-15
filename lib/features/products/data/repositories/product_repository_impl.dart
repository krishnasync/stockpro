import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;
  ProductRepositoryImpl(this._remote);

  @override
  Future<Result<List<ProductEntity>>> getProducts({
    String? searchQuery,
    String? categoryId,
    int page = 0,
    int pageSize = 25,
  }) async {
    try {
      final products = await _remote.getProducts(
        searchQuery: searchQuery,
        categoryId: categoryId,
        page: page,
        pageSize: pageSize,
      );
      return Result.success(products);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<ProductEntity>> getProductById(String id) async {
    try {
      return Result.success(await _remote.getProductById(id));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ProductEntity>>> getLowStockProducts() async {
    try {
      return Result.success(await _remote.getLowStockProducts());
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<ProductEntity>> createProduct(
      ProductEntity product, String companyId) async {
    try {
      final created = await _remote.createProduct({
        'company_id': companyId,
        'name': product.name,
        'product_code': product.sku,
        'sku': product.sku,
        'barcode': product.barcode,
        'purchase_price': product.purchasePrice,
        'selling_price': product.sellingPrice,
        'min_stock': product.minStock,
        'reorder_level': product.reorderLevel,
      });
      return Result.success(created);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateProduct(ProductEntity product) async {
    try {
      await _remote.updateProduct(product.id, {
        'name': product.name,
        'purchase_price': product.purchasePrice,
        'selling_price': product.sellingPrice,
        'min_stock': product.minStock,
        'reorder_level': product.reorderLevel,
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> archiveProduct(String id) async {
    try {
      await _remote.archiveProduct(id);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}