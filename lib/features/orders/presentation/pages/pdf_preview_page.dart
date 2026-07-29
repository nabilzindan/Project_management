import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../../../core/services/pdf_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/order_entity.dart';

class PdfPreviewPage extends StatelessWidget {
  const PdfPreviewPage({super.key, required this.order});

  final OrderEntity order;

  Future<void> _saveToDevice(BuildContext context) async {
    try {
      final bytes = await PdfService.generateReceipt(order);
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'kwitansi_${Formatters.transactionNumber(order.id ?? 0, order.orderDate)}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        AppSnackbar.success(context, 'PDF disimpan di: ${file.path}');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.error(context, 'Gagal menyimpan PDF: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = 'kwitansi_${Formatters.transactionNumber(order.id ?? 0, order.orderDate)}.pdf';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Kwitansi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            tooltip: 'Save PDF',
            onPressed: () => _saveToDevice(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => PdfService.generateReceipt(order),
        pdfFileName: fileName,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: true, // Tombol Print bawaan PdfPreview
        allowSharing: true,
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.save_alt_outlined),
            onPressed: (context, buildPdf, pageFormat) => _saveToDevice(context),
          ),
        ],
      ),
    );
  }
}
