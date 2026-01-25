import 'dart:convert';
import 'dart:typed_data';

import '../../camera/domain/capture_result.dart';

/// Sync status for field reports
enum SyncStatus { pending, syncing, synced, failed }

/// Represents a field report with sync status
class FieldReport {
  /// Local unique identifier
  final String id;

  /// Captured image bytes (with watermark)
  final Uint8List imageBytes;

  /// GPS latitude
  final double latitude;

  /// GPS longitude
  final double longitude;

  /// When the photo was captured (UTC)
  final DateTime capturedAt;

  /// User ID who captured
  final String userId;

  /// SHA-256 hash for verification
  final String dataHash;

  /// Current sync status
  final SyncStatus syncStatus;

  /// Supabase record ID after sync
  final String? remoteId;

  /// Supabase Storage photo URL after sync
  final String? photoUrl;

  /// Error message if sync failed
  final String? errorMessage;

  const FieldReport({
    required this.id,
    required this.imageBytes,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    required this.userId,
    required this.dataHash,
    required this.syncStatus,
    this.remoteId,
    this.photoUrl,
    this.errorMessage,
  });

  /// Create from CaptureResult with initial pending status
  factory FieldReport.fromCaptureResult(CaptureResult result, String id) {
    return FieldReport(
      id: id,
      imageBytes: result.imageBytes,
      latitude: result.latitude,
      longitude: result.longitude,
      capturedAt: result.capturedAt,
      userId: result.userId,
      dataHash: result.dataHash,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Create a copy with updated fields
  FieldReport copyWith({
    String? id,
    Uint8List? imageBytes,
    double? latitude,
    double? longitude,
    DateTime? capturedAt,
    String? userId,
    String? dataHash,
    SyncStatus? syncStatus,
    String? remoteId,
    String? photoUrl,
    String? errorMessage,
  }) {
    return FieldReport(
      id: id ?? this.id,
      imageBytes: imageBytes ?? this.imageBytes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capturedAt: capturedAt ?? this.capturedAt,
      userId: userId ?? this.userId,
      dataHash: dataHash ?? this.dataHash,
      syncStatus: syncStatus ?? this.syncStatus,
      remoteId: remoteId ?? this.remoteId,
      photoUrl: photoUrl ?? this.photoUrl,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Convert to JSON for Hive storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageBytes': base64Encode(imageBytes),
      'latitude': latitude,
      'longitude': longitude,
      'capturedAt': capturedAt.toIso8601String(),
      'userId': userId,
      'dataHash': dataHash,
      'syncStatus': syncStatus.name,
      'remoteId': remoteId,
      'photoUrl': photoUrl,
      'errorMessage': errorMessage,
    };
  }

  /// Create from JSON (Hive storage)
  factory FieldReport.fromJson(Map<String, dynamic> json) {
    return FieldReport(
      id: json['id'] as String,
      imageBytes: base64Decode(json['imageBytes'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      userId: json['userId'] as String,
      dataHash: json['dataHash'] as String,
      syncStatus: SyncStatus.values.byName(json['syncStatus'] as String),
      remoteId: json['remoteId'] as String?,
      photoUrl: json['photoUrl'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  @override
  String toString() {
    return 'FieldReport(id: $id, status: $syncStatus, lat: $latitude, long: $longitude)';
  }
}
