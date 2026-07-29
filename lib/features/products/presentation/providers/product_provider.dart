import 'package:flutter/foundation.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/product_usecases.dart';

enum ProductViewState { idle, loading, error }

class ProductProvider extends ChangeNotifier {
  ProductProvider({
    required GetProductsUseCase getProducts,
    required SearchProductsUseCase searchProducts,
    required AddProductUseCase addProduct,
    required UpdateProductUseCase updateProduct,
    required DeleteProductUseCase deleteProduct,
  })  : _getProducts = getProducts,
        _searchProducts = searchProducts,
        _addProduct = addProduct,
        _updateProduct = updateProduct,
        _deleteProduct = deleteProduct;

  final GetProductsUseCase _getProducts;
  final SearchProductsUseCase _searchProducts;
  final AddProductUseCase _addProduct;
  final UpdateProductUseCase _updateProduct;
  final DeleteProductUseCase _deleteProduct;

  List<ProductEntity> _products = [];
  List<ProductEntity> get products => _products;

  ProductViewState _state = ProductViewState.idle;
  ProductViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    _setState(ProductViewState.loading);
    try {
      _products = await _getProducts();
      _setState(ProductViewState.idle);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ProductViewState.error);
    }
  }

  Future<void> search(String query) async {
    _setState(ProductViewState.loading);
    try {
      _products = await _searchProducts(query);
      _setState(ProductViewState.idle);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ProductViewState.error);
    }
  }

  /// Melempar [ValidationException] jika input tidak valid agar bisa ditangkap UI.
  Future<void> addProduct(ProductEntity product) async {
    await _addProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(ProductEntity product) async {
    await _updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _deleteProduct(id);
    await loadProducts();
  }

  void _setState(ProductViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
