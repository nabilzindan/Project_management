import 'package:flutter/foundation.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/usecases/order_usecases.dart';

enum OrderViewState { idle, loading, error }

class OrderProvider extends ChangeNotifier {
  OrderProvider({
    required GetOrdersUseCase getOrders,
    required GetOrderDetailUseCase getOrderDetail,
    required CreateOrderUseCase createOrder,
  })  : _getOrders = getOrders,
        _getOrderDetail = getOrderDetail,
        _createOrder = createOrder;

  final GetOrdersUseCase _getOrders;
  final GetOrderDetailUseCase _getOrderDetail;
  final CreateOrderUseCase _createOrder;

  List<OrderEntity> _orders = [];
  List<OrderEntity> get orders => _orders;

  OrderViewState _state = OrderViewState.idle;
  OrderViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Keranjang untuk pembuatan pesanan baru ---
  final List<OrderItemEntity> _cartItems = [];
  List<OrderItemEntity> get cartItems => List.unmodifiable(_cartItems);

  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  void addToCart(OrderItemEntity item) {
    final existingIndex = _cartItems.indexWhere((e) => e.productId == item.productId);
    if (existingIndex != -1) {
      _cartItems[existingIndex] = _cartItems[existingIndex]
          .copyWith(quantity: _cartItems[existingIndex].quantity + item.quantity);
    } else {
      _cartItems.add(item);
    }
    notifyListeners();
  }

  void updateCartItemQuantity(int productId, int quantity) {
    final index = _cartItems.indexWhere((e) => e.productId == productId);
    if (index == -1) return;
    if (quantity <= 0) {
      _cartItems.removeAt(index);
    } else {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((e) => e.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<void> loadOrders() async {
    _setState(OrderViewState.loading);
    try {
      _orders = await _getOrders();
      _setState(OrderViewState.idle);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(OrderViewState.error);
    }
  }

  Future<OrderEntity?> getOrderDetail(int id) => _getOrderDetail(id);

  /// Melempar [OrderValidationException] jika validasi gagal.
  Future<int> submitOrder(String customerName) async {
    final orderId = await _createOrder(customerName: customerName, items: _cartItems);
    clearCart();
    await loadOrders();
    return orderId;
  }

  void _setState(OrderViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
