import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_provider.dart';
import '../widgets/order_item_tile.dart';
import 'pdf_preview_page.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<OrderEntity?> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = context.read<OrderProvider>().getOrderDetail(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: FutureBuilder<OrderEntity?>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          final order = snapshot.data;
          if (order == null) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Pesanan tidak ditemukan',
            );
          }

          final transactionNumber =
              Formatters.transactionNumber(order.id ?? 0, order.orderDate);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow('No. Transaksi', transactionNumber),
                            _infoRow('Nama Pelanggan', order.customerName),
                            _infoRow('Tanggal', Formatters.dateTime(order.orderDate)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Daftar Produk', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Column(
                          children: order.items
                              .map((item) => OrderItemTile(item: item))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Pembayaran',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              Formatters.currency(order.totalPrice),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Cetak Kwitansi PDF'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PdfPreviewPage(order: order)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey))),
          const Text(': '),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
