import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/camera_repository.dart';
import '../domain/capture_result.dart';

part 'camera_controller.g.dart';

@riverpod
class CameraController extends _$CameraController {
  CaptureResult? _lastCaptureResult;

  @override
  FutureOr<void> build() {}

  /// Gets the last capture result (if any)
  CaptureResult? get lastCaptureResult => _lastCaptureResult;

  /// Captures a photo with full verification flow
  Future<void> capture() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final cameraRepo = ref.read(cameraRepositoryProvider);

      // Get current user ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final result = await cameraRepo.capture(userId: userId);
      _lastCaptureResult = result;

      // TODO: In Phase 3, this will be queued for upload
      // For now, just store the result
    });
  }
}
