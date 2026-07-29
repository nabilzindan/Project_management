import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/usecases/order_usecases.dart';
import '../providers/order_provider.dart';
import '../widgets/order_item_tile.dart';
import 'order_detail_page.dart';

class OrderFormPage extends StatefulWidget {
  const OrderFormPage({super.key});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _customerController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<OrderProvider>().clearCart();
    });
  }

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  Future<void> _showAddToCartDialog(ProductEntity product) async {
    if (product.stock <= 0) {
      AppSnackbar.error(context, 'Stok "${product.name}" habis');
      return;
    }
    final quantityController = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();

    final quantity = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(product.name),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Harga: ${Formatters.currency(product.price)}'),
              Text('Stok tersedia: ${product.stock}'),
              const SizedBox(height: 12),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final qty = int.tryParse(value ?? '');
                  if (qty == null || qty <= 0) return 'Masukkan jumlah yang valid';
                  if (qty > product.stock) return 'Melebihi stok (${product.stock})';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(int.parse(quantityController.text));
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (quantity != null && mounted) {
      context.read<OrderProvider>().addToCart(
            OrderItemEntity(
              productId: product.id!,
              productName: product.name,
              quantity: quantity,
              price: product.price,
            ),
          );
      AppSnackbar.info(context, '${product.name} ditambahkan ke pesanan');
    }
  }

  Future<void> _handleSubmit() async {
    final orderProvider = context.read<OrderProvider>();

    if (_customerController.text.trim().isEmpty) {
      AppSnackbar.error(context, 'Nama pelanggan tidak boleh kosong');
      return;
    }
    if (orderProvider.cartItems.isEmpty) {
      AppSnackbar.error(context, 'Pesanan minimal memiliki satu produk');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final orderId = await orderProvider.submitOrder(_customerController.text.trim());
      if (!mounted) return;
      AppSnackbar.success(context, 'Pesanan berhasil dibuat');
      context.read<ProductProvider>().loadProducts();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: orderId)),
      );
    } on OrderValidationException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pesanan Baru')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _customerController,
              decoration: const InputDecoration(
                labelText: 'Nama Pelanggan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Pilih Produk', style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          Expanded(
            flex: 3,
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.products.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Belum ada produk tersedia',
                  );
                }
                return ListView.builder(
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                          '${Formatters.currency(product.price)} · Stok: ${product.stock}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _showAddToCartDialog(product),
                      ),
                      onTap: () => _showAddToCartDialog(product),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 2,
            child: Consumer<OrderProvider>(
              builder: (context, provider, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Keranjang Pesanan', style: Theme.of(context).textTheme.titleMedium),
                      Expanded(
                        child: provider.cartItems.isEmpty
                            ? const Center(child: Text('Belum ada produk dipilih'))
                            : ListView.builder(
                                itemCount: provider.cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = provider.cartItems[index];
                                  return OrderItemTile(
                                    item: item,
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () =>
                                          provider.removeFromCart(item.productId),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            Formatters.currency(provider.cartTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: const Text('Buat Pesanan'),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
