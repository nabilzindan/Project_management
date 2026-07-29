import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// Exception khusus untuk error validasi domain agar mudah ditangani di UI.
class ValidationException implements Exception {
  ValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

void _validateProduct({required String name, required double price, required int stock}) {
  if (name.trim().isEmpty) {
    throw ValidationException('Nama produk tidak boleh kosong.');
  }
  if (price <= 0) {
    throw ValidationException('Harga harus lebih dari 0.');
  }
  if (stock < 0) {
    throw ValidationException('Stok tidak boleh negatif.');
  }
}

class GetProductsUseCase {
  GetProductsUseCase(this._repository);
  final ProductRepository _repository;

  Future<List<ProductEntity>> call() => _repository.getProducts();
}

class SearchProductsUseCase {
  SearchProductsUseCase(this._repository);
  final ProductRepository _repository;

  Future<List<ProductEntity>> call(String query) {
    if (query.trim().isEmpty) return _repository.getProducts();
    return _repository.searchProducts(query.trim());
  }
}

class AddProductUseCase {
  AddProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<int> call(ProductEntity product) {
    _validateProduct(name: product.name, price: product.price, stock: product.stock);
    return _repository.addProduct(product);
  }
}

class UpdateProductUseCase {
  UpdateProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<void> call(ProductEntity product) {
    _validateProduct(name: product.name, price: product.price, stock: product.stock);
    return _repository.updateProduct(product);
  }
}

class DeleteProductUseCase {
  DeleteProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<void> call(int id) => _repository.deleteProduct(id);
}
