import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._localDataSource);

  final ProductLocalDataSource _localDataSource;

  @override
  Future<List<ProductEntity>> getProducts() => _localDataSource.getProducts();

  @override
  Future<List<ProductEntity>> searchProducts(String query) =>
      _localDataSource.searchProducts(query);

  @override
  Future<ProductEntity?> getProductById(int id) => _localDataSource.getProductById(id);

  @override
  Future<int> addProduct(ProductEntity product) {
    return _localDataSource.insertProduct(ProductModel.fromEntity(product));
  }

  @override
  Future<void> updateProduct(ProductEntity product) {
    return _localDataSource.updateProduct(ProductModel.fromEntity(product));
  }

  @override
  Future<void> deleteProduct(int id) => _localDataSource.deleteProduct(id);
}
