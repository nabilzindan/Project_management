import 'order_item_entity.dart';

class OrderEntity {
  const OrderEntity({
    this.id,
    required this.customerName,
    required this.totalPrice,
    required this.orderDate,
    this.items = const [],
  });

  final int? id;
  final String customerName;
  final double totalPrice;
  final DateTime orderDate;
  final List<OrderItemEntity> items;

  OrderEntity copyWith({
    int? id,
    String? customerName,
    double? totalPrice,
    DateTime? orderDate,
    List<OrderItemEntity>? items,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      totalPrice: totalPrice ?? this.totalPrice,
      orderDate: orderDate ?? this.orderDate,
      items: items ?? this.items,
    );
  }
}
