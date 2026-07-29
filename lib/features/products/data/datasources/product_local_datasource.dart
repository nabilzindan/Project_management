import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> searchProducts(String query);
  Future<ProductModel?> getProductById(int id);
  Future<int> insertProduct(ProductModel product);
  Future<int> updateProduct(ProductModel product);
  Future<int> deleteProduct(int id);
  Future<int> reduceStock(int productId, int quantity, {DatabaseExecutor? executor});
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  ProductLocalDataSourceImpl(this._dbHelper);

  final DatabaseHelper _dbHelper;

  @override
  Future<List<ProductModel>> getProducts() async {
    final db = await _dbHelper.database;
    final result = await db.query(AppConstants.tableProducts, orderBy: 'name ASC');
    return result.map(ProductModel.fromMap).toList();
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      AppConstants.tableProducts,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return result.map(ProductModel.fromMap).toList();
  }

  @override
  Future<ProductModel?> getProductById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      AppConstants.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return ProductModel.fromMap(result.first);
  }

  @override
  Future<int> insertProduct(ProductModel product) async {
    final db = await _dbHelper.database;
    return db.insert(AppConstants.tableProducts, product.toMap(withId: false));
  }

  @override
  Future<int> updateProduct(ProductModel product) async {
    final db = await _dbHelper.database;
    return db.update(
      AppConstants.tableProducts,
      product.toMap(withId: false),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  @override
  Future<int> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    return db.delete(AppConstants.tableProducts, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> reduceStock(int productId, int quantity, {DatabaseExecutor? executor}) async {
    final db = executor ?? await _dbHelper.database;
    return db.rawUpdate(
      'UPDATE ${AppConstants.tableProducts} SET stock = stock - ? WHERE id = ?',
      [quantity, productId],
    );
  }
}
