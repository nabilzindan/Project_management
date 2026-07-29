import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/product_usecases.dart';
import '../providers/product_provider.dart';

/// Halaman ini digunakan untuk menambah produk baru maupun mengedit produk
/// yang sudah ada, tergantung apakah [product] diisi atau tidak.
class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});

  final ProductEntity? product;

  bool get isEditing => product != null;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(0) : '',
    );
    _stockController = TextEditingController(
      text: product != null ? product.stock.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<ProductProvider>();

    final entity = ProductEntity(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.isEditing) {
        await provider.updateProduct(entity);
      } else {
        await provider.addProduct(entity);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.success(
        context,
        widget.isEditing ? 'Produk berhasil diperbarui' : 'Produk berhasil ditambahkan',
      );
    } on ValidationException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit Produk' : 'Tambah Produk')),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: 'Rp ',
                ),
                validator: (value) {
                  final price = double.tryParse(value?.trim() ?? '');
                  if (price == null) return 'Masukkan angka yang valid';
                  if (price <= 0) return 'Harga harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (value) {
                  final stock = int.tryParse(value?.trim() ?? '');
                  if (stock == null) return 'Masukkan angka yang valid';
                  if (stock < 0) return 'Stok tidak boleh negatif';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(widget.isEditing ? 'Simpan Perubahan' : 'Tambah Produk'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
