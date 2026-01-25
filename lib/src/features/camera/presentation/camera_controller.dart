import 'dart:async';
import 'dart:typed_data';

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

  /// Processes a captured photo and saves to local/remote
  Future<void> captureWithImage(Uint8List imageBytes) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final cameraRepo = ref.read(cameraRepositoryProvider);
      final reportRepo = ref.read(reportRepositoryProvider);

      // Get current user ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Process captured photo
      final result = await cameraRepo.processCapture(userId: userId, rawImageBytes: imageBytes);
      _lastCaptureResult = result;
      debugPrint('📸 Photo processed: ${result.dataHash.substring(0, 8)}...');

      // Save to local storage and sync to Supabase
      final report = await reportRepo.saveAndSync(result);
      _lastReport = report;
      debugPrint('💾 Report saved: ${report.id}, status: ${report.syncStatus}');
    });
  }
}
