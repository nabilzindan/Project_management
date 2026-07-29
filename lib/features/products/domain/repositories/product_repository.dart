import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts();
  Future<List<ProductEntity>> searchProducts(String query);
  Future<ProductEntity?> getProductById(int id);
  Future<int> addProduct(ProductEntity product);
  Future<void> updateProduct(ProductEntity product);
  Future<void> deleteProduct(int id);
}
