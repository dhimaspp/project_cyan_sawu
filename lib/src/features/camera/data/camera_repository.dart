import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/capture_result.dart';
import '../../hashing/data/hash_service.dart';
import 'location_service.dart';
import 'watermark_service.dart';

part 'camera_repository.g.dart';

/// Repository for managing camera operations and capture flow
class CameraRepository {
  final LocationService _locationService;
  final WatermarkService _watermarkService;
  final HashService _hashService;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  CameraRepository({
    required LocationService locationService,
    required WatermarkService watermarkService,
    required HashService hashService,
  }) : _locationService = locationService,
       _watermarkService = watermarkService,
       _hashService = hashService;

  /// Gets the camera controller (must call initialize first)
  CameraController? get controller => _cameraController;

  /// Whether the camera is initialized and ready
  bool get isInitialized => _cameraController?.value.isInitialized ?? false;

  /// Initializes the camera with the back camera
  Future<void> initialize() async {
    _cameras = await availableCameras();

    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No cameras available');
    }

    // Find back camera
    final backCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras!.first,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _cameraController!.initialize();
  }

  /// Captures a photo with full verification flow:
  /// 1. Get GPS location (with mock detection)
  /// 2. Take photo
  /// 3. Apply watermark
  /// 4. Generate hash
  Future<CaptureResult> capture({required String userId}) async {
    if (!isInitialized) {
      throw Exception('Camera not initialized');
    }

    // Capture photo
    final XFile imageFile = await _cameraController!.takePicture();
    final Uint8List rawImageBytes = await imageFile.readAsBytes();

    return processCapture(userId: userId, rawImageBytes: rawImageBytes);
  }

  /// Processes a captured photo:
  /// 1. Get GPS location (with mock detection)
  /// 2. Apply watermark
  /// 3. Generate hash
  Future<CaptureResult> processCapture({required String userId, required Uint8List rawImageBytes}) async {
    // Step 1: Get location (throws if mock location detected)
    final position = await _locationService.getCurrentLocation();
    final capturedAt = DateTime.now().toUtc();

    // Step 2: Apply watermark
    final watermarkedBytes = _watermarkService.applyWatermark(
      imageBytes: rawImageBytes,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: capturedAt,
      userId: userId,
    );

    // Step 3: Generate hash
    final dataHash = _hashService.generateHash(
      userId: userId,
      timestampMs: capturedAt.millisecondsSinceEpoch,
      latitude: position.latitude,
      longitude: position.longitude,
      imageBytes: watermarkedBytes,
    );

    return CaptureResult(
      imageBytes: watermarkedBytes,
      latitude: position.latitude,
      longitude: position.longitude,
      capturedAt: capturedAt,
      userId: userId,
      dataHash: dataHash,
      isMockLocation: false, // If we got here, mock was not detected
    );
  }

  /// Disposes camera resources
  Future<void> dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }
}

@riverpod
CameraRepository cameraRepository(Ref ref) {
  final locationService = ref.watch(locationServiceProvider);
  final watermarkService = ref.watch(watermarkServiceProvider);
  final hashService = ref.watch(hashServiceProvider);

  final repo = CameraRepository(
    locationService: locationService,
    watermarkService: watermarkService,
    hashService: hashService,
  );

  ref.onDispose(() {
    repo.dispose();
  });

  return repo;
}
