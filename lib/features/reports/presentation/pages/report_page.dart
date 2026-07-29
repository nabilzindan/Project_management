import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../orders/presentation/pages/order_detail_page.dart';
import '../providers/report_provider.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadDailyReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan Harian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ReportProvider>().loadDailyReport(),
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          if (provider.state == ReportViewState.loading && provider.report == null) {
            return const LoadingIndicator(message: 'Memuat laporan...');
          }
          if (provider.state == ReportViewState.error) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Terjadi kesalahan',
              subtitle: provider.errorMessage,
            );
          }

          final report = provider.report;
          if (report == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () => provider.loadDailyReport(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(Formatters.date(report.date), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.receipt_long_outlined,
                        label: 'Total Transaksi',
                        value: report.totalTransactions.toString(),
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.inventory_2_outlined,
                        label: 'Produk Terjual',
                        value: report.totalItemsSold.toString(),
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SummaryCard(
                  icon: Icons.payments_outlined,
                  label: 'Total Pendapatan',
                  value: Formatters.currency(report.totalRevenue),
                  color: Colors.green,
                  fullWidth: true,
                ),
                const SizedBox(height: 24),
                Text('Daftar Transaksi', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (report.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'Belum ada transaksi hari ini',
                    ),
                  )
                else
                  ...report.transactions.map((order) {
                    final trxNumber =
                        Formatters.transactionNumber(order.id ?? 0, order.orderDate);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(trxNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${order.customerName} · ${Formatters.dateTime(order.orderDate)}',
                        ),
                        trailing: Text(
                          Formatters.currency(order.totalPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: order.id!)),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color.withOpacity(0.9), fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: fullWidth ? 22 : 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
