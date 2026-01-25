import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../camera/domain/capture_result.dart';
import '../domain/field_report.dart';
import 'local_report_storage.dart';
import 'remote_report_service.dart';

part 'report_repository.g.dart';

/// Repository for managing field reports (local + remote)
class ReportRepository {
  final LocalReportStorage _localStorage;
  final RemoteReportService _remoteService;
  final Uuid _uuid = const Uuid();

  ReportRepository({required LocalReportStorage localStorage, required RemoteReportService remoteService})
    : _localStorage = localStorage,
      _remoteService = remoteService;

  /// Save a capture result and sync to Supabase
  /// Returns the created FieldReport
  Future<FieldReport> saveAndSync(CaptureResult captureResult) async {
    // Generate local ID
    final id = _uuid.v4();

    // Create report with pending status
    var report = FieldReport.fromCaptureResult(captureResult, id);

    // Save locally first (offline-first)
    await _localStorage.saveReport(report);
    debugPrint('📦 Report saved locally: $id');

    // Try to sync to Supabase
    try {
      report = report.copyWith(syncStatus: SyncStatus.syncing);
      await _localStorage.updateReport(report);

      final syncedReport = await _remoteService.syncReport(report);
      await _localStorage.updateReport(syncedReport);
      debugPrint('☁️ Report synced to Supabase: ${syncedReport.remoteId}');
      return syncedReport;
    } catch (e) {
      debugPrint('❌ Sync failed: $e');
      final failedReport = report.copyWith(syncStatus: SyncStatus.failed, errorMessage: e.toString());
      await _localStorage.updateReport(failedReport);
      return failedReport;
    }
  }

  /// Get all reports for the current user
  Future<List<FieldReport>> getReports(String userId) async {
    return _localStorage.getAllReports(userId);
  }

  /// Retry syncing a failed report
  Future<FieldReport> retrySyncReport(String reportId) async {
    final report = await _localStorage.getReport(reportId);
    if (report == null) {
      throw Exception('Report not found: $reportId');
    }

    try {
      var updatedReport = report.copyWith(syncStatus: SyncStatus.syncing);
      await _localStorage.updateReport(updatedReport);

      final syncedReport = await _remoteService.syncReport(report);
      await _localStorage.updateReport(syncedReport);
      debugPrint('☁️ Retry successful: ${syncedReport.remoteId}');
      return syncedReport;
    } catch (e) {
      debugPrint('❌ Retry failed: $e');
      final failedReport = report.copyWith(syncStatus: SyncStatus.failed, errorMessage: e.toString());
      await _localStorage.updateReport(failedReport);
      return failedReport;
    }
  }

  /// Delete a report
  Future<void> deleteReport(String reportId) async {
    await _localStorage.deleteReport(reportId);
  }
}

@riverpod
ReportRepository reportRepository(Ref ref) {
  return ReportRepository(
    localStorage: ref.watch(localReportStorageProvider),
    remoteService: ref.watch(remoteReportServiceProvider),
  );
}
