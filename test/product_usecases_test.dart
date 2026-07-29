import 'package:flutter_test/flutter_test.dart';
import 'package:pos_toko/features/products/domain/entities/product_entity.dart';
import 'package:pos_toko/features/products/domain/repositories/product_repository.dart';
import 'package:pos_toko/features/products/domain/usecases/product_usecases.dart';

/// Fake repository in-memory untuk keperluan pengujian tanpa database nyata.
class FakeProductRepository implements ProductRepository {
  final List<ProductEntity> _storage = [];
  int _nextId = 1;

  @override
  Future<int> addProduct(ProductEntity product) async {
    final id = _nextId++;
    _storage.add(product.copyWith(id: id));
    return id;
  }

  @override
  Future<void> deleteProduct(int id) async {
    _storage.removeWhere((p) => p.id == id);
  }

  @override
  Future<ProductEntity?> getProductById(int id) async {
    try {
      return _storage.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ProductEntity>> getProducts() async => List.of(_storage);

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    return _storage.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    final index = _storage.indexWhere((p) => p.id == product.id);
    if (index != -1) _storage[index] = product;
  }
}

void main() {
  late FakeProductRepository repository;
  late AddProductUseCase addProduct;

  setUp(() {
    repository = FakeProductRepository();
    addProduct = AddProductUseCase(repository);
  });

  group('AddProductUseCase - Validasi', () {
    test('berhasil menambah produk dengan data valid', () async {
      final id = await addProduct(
        ProductEntity(name: 'Kopi Susu', price: 15000, stock: 10, createdAt: DateTime.now()),
      );
      expect(id, 1);
      expect((await repository.getProducts()).length, 1);
    });

    test('menolak produk dengan nama kosong', () async {
      expect(
        () => addProduct(
          ProductEntity(name: '', price: 15000, stock: 10, createdAt: DateTime.now()),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('menolak produk dengan harga <= 0', () async {
      expect(
        () => addProduct(
          ProductEntity(name: 'Teh Manis', price: 0, stock: 10, createdAt: DateTime.now()),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('menolak produk dengan stok negatif', () async {
      expect(
        () => addProduct(
          ProductEntity(name: 'Roti Bakar', price: 12000, stock: -1, createdAt: DateTime.now()),
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
