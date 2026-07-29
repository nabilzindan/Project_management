import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../orders/presentation/pages/order_form_page.dart';
import '../../../orders/presentation/pages/order_list_page.dart';
import '../../../products/presentation/pages/product_list_page.dart';
import '../../../reports/presentation/pages/report_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = <_DashboardMenuItem>[
      _DashboardMenuItem(
        icon: Icons.inventory_2_outlined,
        label: 'Daftar Produk',
        color: Colors.indigo,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProductListPage()),
        ),
      ),
      _DashboardMenuItem(
        icon: Icons.add_shopping_cart_outlined,
        label: 'Buat Pesanan',
        color: Colors.teal,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrderFormPage()),
        ),
      ),
      _DashboardMenuItem(
        icon: Icons.receipt_long_outlined,
        label: 'Daftar Pesanan',
        color: Colors.orange,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrderListPage()),
        ),
      ),
      _DashboardMenuItem(
        icon: Icons.bar_chart_outlined,
        label: 'Laporan Penjualan',
        color: Colors.purple,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReportPage()),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.storeName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Kelola produk, pesanan, dan laporan penjualan toko Anda.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                itemCount: menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) => menuItems[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardMenuItem extends StatelessWidget {
  const _DashboardMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
