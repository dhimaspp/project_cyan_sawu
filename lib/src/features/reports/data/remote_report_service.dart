import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/field_report.dart';

part 'remote_report_service.g.dart';

/// Service for syncing reports to Supabase
class RemoteReportService {
  final SupabaseClient _supabase;

  static const String _bucketName = 'evidence-photos';
  static const String _tableName = 'field_reports';

  RemoteReportService(this._supabase);

  /// Upload photo to Supabase Storage
  /// Returns the public URL of the uploaded photo
  Future<String> uploadPhoto({required Uint8List imageBytes, required String userId, required String reportId}) async {
    final path = '$userId/$reportId.jpg';

    await _supabase.storage
        .from(_bucketName)
        .uploadBinary(path, imageBytes, fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true));

    // Get public URL
    final publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(path);
    return publicUrl;
  }

  /// Create a report record in Supabase
  /// Returns the remote ID (UUID) of the created record
  Future<String> createReport({required FieldReport report, required String photoUrl}) async {
    final response =
        await _supabase
            .from(_tableName)
            .insert({
              'user_id': report.userId,
              'photo_url': photoUrl,
              'gps_lat': report.latitude,
              'gps_long': report.longitude,
              'captured_at': report.capturedAt.toIso8601String(),
              'data_hash': report.dataHash,
              'status': 'pending', // Initial status, admin will verify later
            })
            .select('id')
            .single();

    return response['id'] as String;
  }

  /// Full sync: upload photo + create record
  /// Returns updated FieldReport with remoteId and photoUrl
  Future<FieldReport> syncReport(FieldReport report) async {
    // Step 1: Upload photo
    final photoUrl = await uploadPhoto(imageBytes: report.imageBytes, userId: report.userId, reportId: report.id);

    // Step 2: Create database record
    final remoteId = await createReport(report: report, photoUrl: photoUrl);

    // Return updated report
    return report.copyWith(syncStatus: SyncStatus.synced, remoteId: remoteId, photoUrl: photoUrl);
  }
}

@riverpod
RemoteReportService remoteReportService(Ref ref) {
  return RemoteReportService(Supabase.instance.client);
}
