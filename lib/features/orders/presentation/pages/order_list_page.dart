import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../providers/order_provider.dart';
import 'order_detail_page.dart';
import 'order_form_page.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pesanan')),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.state == OrderViewState.loading && provider.orders.isEmpty) {
            return const LoadingIndicator(message: 'Memuat pesanan...');
          }
          if (provider.state == OrderViewState.error) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Terjadi kesalahan',
              subtitle: provider.errorMessage,
            );
          }
          if (provider.orders.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Belum ada pesanan',
              subtitle: 'Tekan tombol + untuk membuat pesanan baru',
            );
          }
          return RefreshIndicator(
            onRefresh: provider.loadOrders,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: provider.orders.length,
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      child: const Icon(Icons.receipt_outlined),
                    ),
                    title: Text(order.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(Formatters.dateTime(order.orderDate)),
                    trailing: Text(
                      Formatters.currency(order.totalPrice),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: order.id!)),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrderFormPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Buat Pesanan'),
      ),
    );
  }
}
