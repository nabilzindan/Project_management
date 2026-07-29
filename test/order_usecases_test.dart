import 'package:flutter_test/flutter_test.dart';
import 'package:pos_toko/features/orders/domain/entities/order_entity.dart';
import 'package:pos_toko/features/orders/domain/entities/order_item_entity.dart';
import 'package:pos_toko/features/orders/domain/repositories/order_repository.dart';
import 'package:pos_toko/features/orders/domain/usecases/order_usecases.dart';
import 'package:pos_toko/features/products/domain/entities/product_entity.dart';
import 'package:pos_toko/features/products/domain/repositories/product_repository.dart';

class FakeOrderRepository implements OrderRepository {
  final List<OrderEntity> _storage = [];
  int _nextId = 1;

  @override
  Future<int> createOrder(OrderEntity order, List<OrderItemEntity> items) async {
    final id = _nextId++;
    _storage.add(order.copyWith(id: id, items: items));
    return id;
  }

  @override
  Future<OrderEntity?> getOrderById(int id) async {
    try {
      return _storage.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<OrderEntity>> getOrders() async => List.of(_storage);

  @override
  Future<List<OrderEntity>> getOrdersByDateRange(DateTime start, DateTime end) async {
    return _storage
        .where((o) => o.orderDate.isAfter(start) && o.orderDate.isBefore(end))
        .toList();
  }
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository(this.products);
  final List<ProductEntity> products;

  @override
  Future<int> addProduct(ProductEntity product) async => 0;

  @override
  Future<void> deleteProduct(int id) async {}

  @override
  Future<ProductEntity?> getProductById(int id) async {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ProductEntity>> getProducts() async => products;

  @override
  Future<List<ProductEntity>> searchProducts(String query) async => products;

  @override
  Future<void> updateProduct(ProductEntity product) async {}
}

void main() {
  late FakeOrderRepository orderRepository;
  late FakeProductRepository productRepository;
  late CreateOrderUseCase createOrder;

  setUp(() {
    orderRepository = FakeOrderRepository();
    productRepository = FakeProductRepository([
      ProductEntity(id: 1, name: 'Kopi Susu', price: 15000, stock: 5, createdAt: DateTime.now()),
    ]);
    createOrder = CreateOrderUseCase(orderRepository, productRepository);
  });

  group('CreateOrderUseCase - Validasi', () {
    test('berhasil membuat pesanan dengan data valid', () async {
      final id = await createOrder(
        customerName: 'Budi',
        items: [
          const OrderItemEntity(productId: 1, productName: 'Kopi Susu', quantity: 2, price: 15000),
        ],
      );
      expect(id, 1);
      final orders = await orderRepository.getOrders();
      expect(orders.first.totalPrice, 30000);
    });

    test('menolak pesanan tanpa produk', () async {
      expect(
        () => createOrder(customerName: 'Budi', items: []),
        throwsA(isA<OrderValidationException>()),
      );
    });

    test('menolak pesanan jika jumlah melebihi stok', () async {
      expect(
        () => createOrder(
          customerName: 'Budi',
          items: [
            const OrderItemEntity(
                productId: 1, productName: 'Kopi Susu', quantity: 10, price: 15000),
          ],
        ),
        throwsA(isA<OrderValidationException>()),
      );
    });

    test('menolak pesanan dengan nama pelanggan kosong', () async {
      expect(
        () => createOrder(
          customerName: '',
          items: [
            const OrderItemEntity(productId: 1, productName: 'Kopi Susu', quantity: 1, price: 15000),
          ],
        ),
        throwsA(isA<OrderValidationException>()),
      );
    });
  });
}
