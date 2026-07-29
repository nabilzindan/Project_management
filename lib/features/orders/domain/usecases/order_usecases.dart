import '../../../products/domain/repositories/product_repository.dart';
import '../entities/order_entity.dart';
import '../entities/order_item_entity.dart';
import '../repositories/order_repository.dart';

class OrderValidationException implements Exception {
  OrderValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

class GetOrdersUseCase {
  GetOrdersUseCase(this._repository);
  final OrderRepository _repository;

  Future<List<OrderEntity>> call() => _repository.getOrders();
}

class GetOrderDetailUseCase {
  GetOrderDetailUseCase(this._repository);
  final OrderRepository _repository;

  Future<OrderEntity?> call(int id) => _repository.getOrderById(id);
}

/// Membuat pesanan baru. Melakukan validasi:
/// - Pesanan minimal memiliki satu produk.
/// - Jumlah pembelian tidak boleh melebihi stok yang tersedia.
class CreateOrderUseCase {
  CreateOrderUseCase(this._orderRepository, this._productRepository);

  final OrderRepository _orderRepository;
  final ProductRepository _productRepository;

  Future<int> call({
    required String customerName,
    required List<OrderItemEntity> items,
  }) async {
    if (customerName.trim().isEmpty) {
      throw OrderValidationException('Nama pelanggan tidak boleh kosong.');
    }
    if (items.isEmpty) {
      throw OrderValidationException('Pesanan minimal memiliki satu produk.');
    }

    for (final item in items) {
      if (item.quantity <= 0) {
        throw OrderValidationException('Jumlah "${item.productName}" harus lebih dari 0.');
      }
      final product = await _productRepository.getProductById(item.productId);
      if (product == null) {
        throw OrderValidationException('Produk "${item.productName}" tidak ditemukan.');
      }
      if (item.quantity > product.stock) {
        throw OrderValidationException(
          'Jumlah "${item.productName}" (${item.quantity}) melebihi stok tersedia (${product.stock}).',
        );
      }
    }

    final totalPrice = items.fold<double>(0, (sum, item) => sum + item.subtotal);

    final order = OrderEntity(
      customerName: customerName.trim(),
      totalPrice: totalPrice,
      orderDate: DateTime.now(),
    );

    return _orderRepository.createOrder(order, items);
  }
}
