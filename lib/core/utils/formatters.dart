import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String currency(num value) => _currencyFormat.format(value);

  static String date(DateTime date) => DateFormat('dd MMM yyyy', 'id_ID').format(date);

  static String dateTime(DateTime date) =>
      DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);

  static String transactionNumber(int id, DateTime date) {
    final datePart = DateFormat('yyyyMMdd').format(date);
    return 'TRX-$datePart-${id.toString().padLeft(4, '0')}';
  }
}
