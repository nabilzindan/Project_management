import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_local_datasource.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._localDataSource);

  final OrderLocalDataSource _localDataSource;

  @override
  Future<List<OrderEntity>> getOrders() => _localDataSource.getOrders();

  @override
  Future<OrderEntity?> getOrderById(int id) => _localDataSource.getOrderById(id);

  @override
  Future<List<OrderEntity>> getOrdersByDateRange(DateTime start, DateTime end) =>
      _localDataSource.getOrdersByDateRange(start, end);

  @override
  Future<int> createOrder(OrderEntity order, List<OrderItemEntity> items) {
    final orderModel = OrderModel(
      customerName: order.customerName,
      totalPrice: order.totalPrice,
      orderDate: order.orderDate,
    );
    final itemModels = items.map(OrderItemModel.fromEntity).toList();
    return _localDataSource.createOrder(orderModel, itemModels);
  }
}
