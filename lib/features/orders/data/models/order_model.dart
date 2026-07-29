import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    super.id,
    required super.customerName,
    required super.totalPrice,
    required super.orderDate,
    super.items,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, {List<OrderItemModel> items = const []}) {
    return OrderModel(
      id: map['id'] as int?,
      customerName: map['customer_name'] as String,
      totalPrice: (map['total_price'] as num).toDouble(),
      orderDate: DateTime.parse(map['order_date'] as String),
      items: items,
    );
  }

  Map<String, dynamic> toMap({bool withId = true}) {
    final map = <String, dynamic>{
      'customer_name': customerName,
      'total_price': totalPrice,
      'order_date': orderDate.toIso8601String(),
    };
    if (withId && id != null) map['id'] = id;
    return map;
  }
}
