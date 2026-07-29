import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    super.id,
    required super.name,
    required super.price,
    required super.stock,
    required super.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      stock: entity.stock,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap({bool withId = true}) {
    final map = <String, dynamic>{
      'name': name,
      'price': price,
      'stock': stock,
      'created_at': createdAt.toIso8601String(),
    };
    if (withId && id != null) map['id'] = id;
    return map;
  }
}
