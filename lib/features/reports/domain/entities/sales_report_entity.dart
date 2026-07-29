import '../../../orders/domain/entities/order_entity.dart';

class SalesReportEntity {
  const SalesReportEntity({
    required this.date,
    required this.totalTransactions,
    required this.totalRevenue,
    required this.totalItemsSold,
    required this.transactions,
  });

  final DateTime date;
  final int totalTransactions;
  final double totalRevenue;
  final int totalItemsSold;
  final List<OrderEntity> transactions;

  factory SalesReportEntity.fromOrders(DateTime date, List<OrderEntity> orders) {
    final totalItemsSold = orders.fold<int>(
      0,
      (sum, order) => sum + order.items.fold<int>(0, (s, item) => s + item.quantity),
    );
    final totalRevenue = orders.fold<double>(0, (sum, order) => sum + order.totalPrice);

    return SalesReportEntity(
      date: date,
      totalTransactions: orders.length,
      totalRevenue: totalRevenue,
      totalItemsSold: totalItemsSold,
      transactions: orders,
    );
  }
}
