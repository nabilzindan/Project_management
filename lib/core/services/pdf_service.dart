import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/orders/domain/entities/order_entity.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';

/// Bertanggung jawab membangun dokumen PDF kwitansi dari sebuah [OrderEntity].
class PdfService {
  PdfService._();

  static Future<Uint8List> generateReceipt(OrderEntity order) async {
    final doc = pw.Document();
    final transactionNumber = Formatters.transactionNumber(order.id ?? 0, order.orderDate);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 8),
              _buildInfoSection(transactionNumber, order),
              pw.SizedBox(height: 16),
              _buildItemsTable(order),
              pw.SizedBox(height: 16),
              _buildTotalSection(order),
              pw.SizedBox(height: 32),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          AppConstants.storeName,
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(AppConstants.storeAddress, style: const pw.TextStyle(fontSize: 10)),
        pw.Text('Telp: ${AppConstants.storePhone}', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  static pw.Widget _buildInfoSection(String transactionNumber, OrderEntity order) {
    pw.Widget row(String label, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          children: [
            pw.SizedBox(width: 110, child: pw.Text(label, style: const pw.TextStyle(fontSize: 11))),
            pw.Text(': ', style: const pw.TextStyle(fontSize: 11)),
            pw.Text(value,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        row('No. Transaksi', transactionNumber),
        row('Tanggal', Formatters.dateTime(order.orderDate)),
        row('Nama Pelanggan', order.customerName),
      ],
    );
  }

  static pw.Widget _buildItemsTable(OrderEntity order) {
    final headers = ['Produk', 'Jumlah', 'Harga Satuan', 'Subtotal'];
    final rows = order.items
        .map((item) => [
              item.productName,
              item.quantity.toString(),
              Formatters.currency(item.price),
              Formatters.currency(item.subtotal),
            ])
        .toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    );
  }

  static pw.Widget _buildTotalSection(OrderEntity order) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: pw.BoxDecoration(
          color: PdfColors.blueGrey50,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text('TOTAL PEMBAYARAN  ',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text(
              Formatters.currency(order.totalPrice),
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Center(
      child: pw.Text(
        AppConstants.thankYouMessage,
        style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic),
      ),
    );
  }
}
