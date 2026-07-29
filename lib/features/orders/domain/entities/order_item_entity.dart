class OrderItemEntity {
  const OrderItemEntity({
    this.id,
    this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  final int? id;
  final int? orderId;
  final int productId;

  /// Nama produk disimpan di entity (bukan tabel order_items) agar mudah
  /// ditampilkan di UI dan PDF tanpa perlu join berulang.
  final String productName;
  final int quantity;

  /// Harga satuan produk pada saat transaksi dilakukan.
  final double price;

  double get subtotal => price * quantity;

  OrderItemEntity copyWith({
    int? id,
    int? orderId,
    int? productId,
    String? productName,
    int? quantity,
    double? price,
  }) {
    return OrderItemEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}
