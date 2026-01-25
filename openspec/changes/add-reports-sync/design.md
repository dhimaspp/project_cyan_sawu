# Design: Reports Sync Architecture

## Overview
The reports system follows an offline-first pattern where data is always saved locally first, then synced to Supabase when online.

## Data Model

### FieldReport (Local Model)
```dart
class FieldReport {
  final String id;           // Local UUID
  final Uint8List imageBytes;
  final double latitude;
  final double longitude;
  final DateTime capturedAt;
  final String userId;
  final String dataHash;
  final SyncStatus syncStatus; // pending, synced, failed
  final String? remoteId;      // Supabase UUID after sync
  final String? photoUrl;      // Supabase Storage URL after sync
  final String? errorMessage;  // If sync failed
}

enum SyncStatus { pending, syncing, synced, failed }
```

## Architecture

### Feature Structure
```
lib/src/features/
└── reports/
    ├── data/
    │   ├── report_repository.dart    # CRUD + sync logic
    │   ├── local_report_storage.dart # Hive operations
    │   └── remote_report_service.dart # Supabase operations
    ├── domain/
    │   └── field_report.dart         # Model
    └── presentation/
        └── reports_page.dart         # List UI
```

## Data Flow

### Capture → Save → Sync
```
┌──────────────┐     ┌─────────────────┐     ┌──────────────────┐
│ CameraPage   │────▶│ ReportRepository│────▶│ LocalStorage     │
│ (capture)    │     │ (save)          │     │ (Hive)           │
└──────────────┘     └─────────────────┘     └──────────────────┘
                              │
                              ▼
                     ┌─────────────────┐     ┌──────────────────┐
                     │ ReportRepository│────▶│ RemoteService    │
                     │ (sync)          │     │ (Supabase)       │
                     └─────────────────┘     └──────────────────┘
```

### Sync Process
1. Upload photo to Supabase Storage (`evidence-photos` bucket)
2. Get photo URL
3. Insert record to `field_reports` table
4. Update local record with `synced` status and `remoteId`

## Storage Details

### Hive Box: `field_reports`
- Key: Report ID (UUID)
- Value: JSON-serialized FieldReport

### Supabase Storage: `evidence-photos`
- Path: `{userId}/{reportId}.jpg`
- Public read access for transparency

### Supabase Table: `field_reports`
Uses existing schema from PRD.

## Error Handling

| Error | Behavior |
|-------|----------|
| No network | Save locally, status = `pending` |
| Upload failed | status = `failed`, store error message |
| Success | status = `synced`, store remoteId |
