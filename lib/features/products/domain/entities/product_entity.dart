class ProductEntity {
  const ProductEntity({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final double price;
  final int stock;
  final DateTime createdAt;

  ProductEntity copyWith({
    int? id,
    String? name,
    double? price,
    int? stock,
    DateTime? createdAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
