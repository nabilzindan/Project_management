import '../../../orders/domain/repositories/order_repository.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<SalesReportEntity> getDailyReport(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final orders = await _orderRepository.getOrdersByDateRange(start, end);
    return SalesReportEntity.fromOrders(start, orders);
  }
}
