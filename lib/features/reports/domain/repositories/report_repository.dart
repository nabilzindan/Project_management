import '../entities/sales_report_entity.dart';

abstract class ReportRepository {
  Future<SalesReportEntity> getDailyReport(DateTime date);
}
