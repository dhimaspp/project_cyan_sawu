import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/camera_repository.dart';
import '../domain/capture_result.dart';
import '../../reports/data/report_repository.dart';
import '../../reports/domain/field_report.dart';

part 'camera_controller.g.dart';

@riverpod
class CameraController extends _$CameraController {
  CaptureResult? _lastCaptureResult;
  FieldReport? _lastReport;

  @override
  FutureOr<void> build() {}

  /// Gets the last capture result (if any)
  CaptureResult? get lastCaptureResult => _lastCaptureResult;

  /// Gets the last created report (if any)
  FieldReport? get lastReport => _lastReport;

  /// Captures a photo with full verification flow and saves to local/remote
  Future<void> capture() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final cameraRepo = ref.read(cameraRepositoryProvider);
      final reportRepo = ref.read(reportRepositoryProvider);

      // Get current user ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Capture photo
      final result = await cameraRepo.capture(userId: userId);
      _lastCaptureResult = result;
      debugPrint('📸 Photo captured: ${result.dataHash.substring(0, 8)}...');

      // Save to local storage and sync to Supabase
      final report = await reportRepo.saveAndSync(result);
      _lastReport = report;
      debugPrint('💾 Report saved: ${report.id}, status: ${report.syncStatus}');
    });
  }
}
