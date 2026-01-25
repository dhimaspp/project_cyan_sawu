import 'dart:typed_data';

/// Represents the result of a camera capture with all associated metadata
class CaptureResult {
  /// The captured image bytes (with watermark applied)
  final Uint8List imageBytes;

  /// GPS latitude at time of capture
  final double latitude;

  /// GPS longitude at time of capture
  final double longitude;

  /// Timestamp when the photo was captured (UTC)
  final DateTime capturedAt;

  /// User ID who captured the photo
  final String userId;

  /// SHA-256 hash of the capture data for verification
  final String dataHash;

  /// Whether mock location was detected (should always be false for valid captures)
  final bool isMockLocation;

  const CaptureResult({
    required this.imageBytes,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    required this.userId,
    required this.dataHash,
    required this.isMockLocation,
  });

  /// Creates a copy with optional field overrides
  CaptureResult copyWith({
    Uint8List? imageBytes,
    double? latitude,
    double? longitude,
    DateTime? capturedAt,
    String? userId,
    String? dataHash,
    bool? isMockLocation,
  }) {
    return CaptureResult(
      imageBytes: imageBytes ?? this.imageBytes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capturedAt: capturedAt ?? this.capturedAt,
      userId: userId ?? this.userId,
      dataHash: dataHash ?? this.dataHash,
      isMockLocation: isMockLocation ?? this.isMockLocation,
    );
  }

  @override
  String toString() {
    return 'CaptureResult(lat: $latitude, long: $longitude, capturedAt: $capturedAt, hash: ${dataHash.substring(0, 8)}...)';
  }
}
