import '../entities/order_entity.dart';
import '../entities/order_item_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders();
  Future<OrderEntity?> getOrderById(int id);
  Future<int> createOrder(OrderEntity order, List<OrderItemEntity> items);
  Future<List<OrderEntity>> getOrdersByDateRange(DateTime start, DateTime end);
}
