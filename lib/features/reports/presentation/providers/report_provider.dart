import 'package:flutter/foundation.dart';

import '../../domain/entities/sales_report_entity.dart';
import '../../domain/usecases/get_daily_report_usecase.dart';

enum ReportViewState { idle, loading, error }

class ReportProvider extends ChangeNotifier {
  ReportProvider({required GetDailyReportUseCase getDailyReport})
      : _getDailyReport = getDailyReport;

  final GetDailyReportUseCase _getDailyReport;

  SalesReportEntity? _report;
  SalesReportEntity? get report => _report;

  ReportViewState _state = ReportViewState.idle;
  ReportViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadDailyReport([DateTime? date]) async {
    _state = ReportViewState.loading;
    notifyListeners();
    try {
      _report = await _getDailyReport(date ?? DateTime.now());
      _state = ReportViewState.idle;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ReportViewState.error;
    }
    notifyListeners();
  }
}
