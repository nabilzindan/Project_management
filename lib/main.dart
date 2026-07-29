import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/services/injector.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/orders/presentation/providers/order_provider.dart';
import 'features/products/presentation/providers/product_provider.dart';
import 'features/reports/presentation/providers/report_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  runApp(const PosTokoApp());
}

class PosTokoApp extends StatelessWidget {
  const PosTokoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final injector = Injector.instance;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            getProducts: injector.getProductsUseCase,
            searchProducts: injector.searchProductsUseCase,
            addProduct: injector.addProductUseCase,
            updateProduct: injector.updateProductUseCase,
            deleteProduct: injector.deleteProductUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(
            getOrders: injector.getOrdersUseCase,
            getOrderDetail: injector.getOrderDetailUseCase,
            createOrder: injector.createOrderUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportProvider(getDailyReport: injector.getDailyReportUseCase),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.storeName,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const DashboardPage(),
      ),
    );
  }

  ThemeData _buildTheme() {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}
