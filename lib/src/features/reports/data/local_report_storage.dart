import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/field_report.dart';

part 'local_report_storage.g.dart';

/// Local storage for field reports using Hive
class LocalReportStorage {
  static const String _boxName = 'field_reports';

  Box<String>? _box;

  /// Opens the Hive box (call once at startup or lazily)
  Future<void> _ensureBoxOpen() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<String>(_boxName);
    }
  }

  /// Save a report to local storage
  Future<void> saveReport(FieldReport report) async {
    await _ensureBoxOpen();
    final json = jsonEncode(report.toJson());
    await _box!.put(report.id, json);
  }

  /// Get all reports for a specific user
  Future<List<FieldReport>> getAllReports(String userId) async {
    await _ensureBoxOpen();

    final reports = <FieldReport>[];
    for (final key in _box!.keys) {
      final json = _box!.get(key);
      if (json != null) {
        try {
          final report = FieldReport.fromJson(jsonDecode(json));
          if (report.userId == userId) {
            reports.add(report);
          }
        } catch (e) {
          // Skip corrupted entries
          continue;
        }
      }
    }

    // Sort by capture date, newest first
    reports.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    return reports;
  }

  /// Update an existing report (e.g., sync status change)
  Future<void> updateReport(FieldReport report) async {
    await _ensureBoxOpen();
    final json = jsonEncode(report.toJson());
    await _box!.put(report.id, json);
  }

  /// Delete a report by ID
  Future<void> deleteReport(String id) async {
    await _ensureBoxOpen();
    await _box!.delete(id);
  }

  /// Get a single report by ID
  Future<FieldReport?> getReport(String id) async {
    await _ensureBoxOpen();
    final json = _box!.get(id);
    if (json == null) return null;
    return FieldReport.fromJson(jsonDecode(json));
  }

  /// Get all pending reports (for retry)
  Future<List<FieldReport>> getPendingReports(String userId) async {
    final all = await getAllReports(userId);
    return all.where((r) => r.syncStatus == SyncStatus.pending || r.syncStatus == SyncStatus.failed).toList();
  }
}

@riverpod
LocalReportStorage localReportStorage(Ref ref) {
  return LocalReportStorage();
}
