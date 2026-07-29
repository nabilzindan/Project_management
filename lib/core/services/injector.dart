import '../database/database_helper.dart';

import '../../features/products/data/datasources/product_local_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/product_usecases.dart';

import '../../features/orders/data/datasources/order_local_datasource.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/usecases/order_usecases.dart';

import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/usecases/get_daily_report_usecase.dart';

/// Injector sederhana (manual Dependency Injection) yang merangkai seluruh
/// lapisan Clean Architecture: DataSource -> Repository -> UseCase.
///
/// Dipilih pendekatan manual (tanpa get_it) agar alur dependency mudah
/// ditelusuri dan tetap ringan untuk skala aplikasi ini.
class Injector {
  Injector._internal() {
    _setup();
  }

  static final Injector instance = Injector._internal();

  late final ProductLocalDataSource productLocalDataSource;
  late final ProductRepository productRepository;
  late final GetProductsUseCase getProductsUseCase;
  late final SearchProductsUseCase searchProductsUseCase;
  late final AddProductUseCase addProductUseCase;
  late final UpdateProductUseCase updateProductUseCase;
  late final DeleteProductUseCase deleteProductUseCase;

  late final OrderLocalDataSource orderLocalDataSource;
  late final OrderRepository orderRepository;
  late final GetOrdersUseCase getOrdersUseCase;
  late final GetOrderDetailUseCase getOrderDetailUseCase;
  late final CreateOrderUseCase createOrderUseCase;

  late final ReportRepository reportRepository;
  late final GetDailyReportUseCase getDailyReportUseCase;

  void _setup() {
    final dbHelper = DatabaseHelper.instance;

    // Products
    productLocalDataSource = ProductLocalDataSourceImpl(dbHelper);
    productRepository = ProductRepositoryImpl(productLocalDataSource);
    getProductsUseCase = GetProductsUseCase(productRepository);
    searchProductsUseCase = SearchProductsUseCase(productRepository);
    addProductUseCase = AddProductUseCase(productRepository);
    updateProductUseCase = UpdateProductUseCase(productRepository);
    deleteProductUseCase = DeleteProductUseCase(productRepository);

    // Orders
    orderLocalDataSource = OrderLocalDataSourceImpl(dbHelper, productLocalDataSource);
    orderRepository = OrderRepositoryImpl(orderLocalDataSource);
    getOrdersUseCase = GetOrdersUseCase(orderRepository);
    getOrderDetailUseCase = GetOrderDetailUseCase(orderRepository);
    createOrderUseCase = CreateOrderUseCase(orderRepository, productRepository);

    // Reports
    reportRepository = ReportRepositoryImpl(orderRepository);
    getDailyReportUseCase = GetDailyReportUseCase(reportRepository);
  }
}
