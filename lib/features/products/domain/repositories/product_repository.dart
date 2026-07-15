import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Result<List<ProductEntity>>> getProducts({
    String? searchQuery,
    String? categoryId,
    int page = 0,
    int pageSize = 25,
  });

  Future<Result<ProductEntity>> getProductById(String id);

  Future<Result<List<ProductEntity>>> getLowStockProducts();

  Future<Result<ProductEntity>> createProduct(
      ProductEntity product, String companyId);

  Future<Result<void>> updateProduct(ProductEntity product);

  Future<Result<void>> archiveProduct(String id); // soft delete, see PRD §schema notes
}