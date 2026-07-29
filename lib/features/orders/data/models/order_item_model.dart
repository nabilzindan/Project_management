import '../../domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    super.id,
    super.orderId,
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.price,
  });

  /// Membuat model dari hasil query JOIN order_items dengan products,
  /// sehingga nama produk ikut terbawa.
  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as int?,
      orderId: map['order_id'] as int?,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String? ?? '-',
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
    );
  }

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      id: entity.id,
      orderId: entity.orderId,
      productId: entity.productId,
      productName: entity.productName,
      quantity: entity.quantity,
      price: entity.price,
    );
  }

  Map<String, dynamic> toMap({bool withId = true}) {
    final map = <String, dynamic>{
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
    if (withId && id != null) map['id'] = id;
    return map;
  }
}
