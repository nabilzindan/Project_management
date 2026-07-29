import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../products/data/datasources/product_local_datasource.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

abstract class OrderLocalDataSource {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel?> getOrderById(int id);
  Future<int> createOrder(OrderModel order, List<OrderItemModel> items);
  Future<List<OrderModel>> getOrdersByDateRange(DateTime start, DateTime end);
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  OrderLocalDataSourceImpl(this._dbHelper, this._productLocalDataSource);

  final DatabaseHelper _dbHelper;
  final ProductLocalDataSource _productLocalDataSource;

  /// Query dasar untuk mengambil order beserta nama produk pada setiap item
  /// melalui JOIN antara order_items dan products.
  static const String _itemsJoinQuery = '''
    SELECT oi.*, p.name AS product_name
    FROM ${AppConstants.tableOrderItems} oi
    INNER JOIN ${AppConstants.tableProducts} p ON p.id = oi.product_id
    WHERE oi.order_id = ?
  ''';

  @override
  Future<List<OrderModel>> getOrders() async {
    final db = await _dbHelper.database;
    final result = await db.query(AppConstants.tableOrders, orderBy: 'order_date DESC');
    return Future.wait(result.map((row) => _attachItems(db, row)));
  }

  @override
  Future<OrderModel?> getOrderById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      AppConstants.tableOrders,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return _attachItems(db, result.first);
  }

  @override
  Future<List<OrderModel>> getOrdersByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      AppConstants.tableOrders,
      where: 'order_date >= ? AND order_date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'order_date DESC',
    );
    return Future.wait(result.map((row) => _attachItems(db, row)));
  }

  Future<OrderModel> _attachItems(DatabaseExecutor db, Map<String, dynamic> orderRow) async {
    final itemRows = await db.rawQuery(_itemsJoinQuery, [orderRow['id']]);
    final items = itemRows.map(OrderItemModel.fromMap).toList();
    return OrderModel.fromMap(orderRow, items: items);
  }

  /// Membuat pesanan baru beserta item-itemnya dan mengurangi stok produk
  /// secara atomik menggunakan transaksi database.
  @override
  Future<int> createOrder(OrderModel order, List<OrderItemModel> items) async {
    final db = await _dbHelper.database;

    return db.transaction<int>((txn) async {
      final orderId = await txn.insert(AppConstants.tableOrders, order.toMap(withId: false));

      for (final item in items) {
        final itemWithOrderId = OrderItemModel(
          orderId: orderId,
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          price: item.price,
        );

        await txn.insert(
          AppConstants.tableOrderItems,
          itemWithOrderId.toMap(withId: false),
        );

        await _productLocalDataSource.reduceStock(
          item.productId,
          item.quantity,
          executor: txn,
        );
      }

      return orderId;
    });
  }
}
