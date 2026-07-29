import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'product_form_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete(ProductEntity product) async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      title: 'Hapus Produk',
      message: 'Apakah Anda yakin ingin menghapus "${product.name}"?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<ProductProvider>().deleteProduct(product.id!);
      if (mounted) AppSnackbar.success(context, 'Produk berhasil dihapus');
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Gagal menghapus produk: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk berdasarkan nama...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => context.read<ProductProvider>().search(value),
            ),
          ),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.state == ProductViewState.loading && provider.products.isEmpty) {
            return const LoadingIndicator(message: 'Memuat produk...');
          }
          if (provider.state == ProductViewState.error) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Terjadi kesalahan',
              subtitle: provider.errorMessage,
            );
          }
          if (provider.products.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Belum ada produk',
              subtitle: 'Tekan tombol + untuk menambahkan produk baru',
            );
          }
          return RefreshIndicator(
            onRefresh: provider.loadProducts,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return ProductCard(
                  product: product,
                  onEdit: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
                  ),
                  onDelete: () => _handleDelete(product),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProductFormPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}
