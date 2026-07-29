import '../entities/sales_report_entity.dart';
import '../repositories/report_repository.dart';

class GetDailyReportUseCase {
  GetDailyReportUseCase(this._repository);
  final ReportRepository _repository;

  Future<SalesReportEntity> call(DateTime date) => _repository.getDailyReport(date);
}
