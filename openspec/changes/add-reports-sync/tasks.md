# Tasks: Add Reports Sync & List

## Task 1: Add Hive Dependencies ✅
**Scope**: `pubspec.yaml`

Add:
- `hive: ^2.2.3`
- `hive_flutter: ^1.1.0`

**Validation**: `flutter pub get` succeeds ✓

---

## Task 2: Initialize Hive ✅
**Scope**: `lib/main.dart`

Add Hive initialization before `runApp()`:
- `await Hive.initFlutter()` ✓
- Register adapters (not needed for JSON-based storage)

**Validation**: App starts without errors ✓

---

## Task 3: Create FieldReport Model ✅
**Scope**: `lib/src/features/reports/domain/field_report.dart`

Create `FieldReport` class with:
- All fields from CaptureResult ✓
- `id`, `syncStatus`, `remoteId`, `photoUrl`, `errorMessage` ✓
- `SyncStatus` enum ✓
- `toJson()` / `fromJson()` for Hive storage ✓

**Validation**: Model compiles ✓

---

## Task 4: Create Local Report Storage ✅
**Scope**: `lib/src/features/reports/data/local_report_storage.dart`

Create `LocalReportStorage` class:
- `saveReport(FieldReport)`: Save to Hive ✓
- `getAllReports()`: Get all reports for current user ✓
- `updateReport(FieldReport)`: Update sync status ✓
- `deleteReport(String id)`: Delete by ID ✓

**Validation**: Unit test CRUD operations ✓

---

## Task 5: Create Remote Report Service ✅
**Scope**: `lib/src/features/reports/data/remote_report_service.dart`

Create `RemoteReportService` class:
- `uploadPhoto(imageBytes, userId, reportId)`: Upload to Storage, return URL ✓
- `createReport(FieldReport, photoUrl)`: Insert to `field_reports` table ✓

**Validation**: Integration test with Supabase ✓

---

## Task 6: Create Report Repository ✅
**Scope**: `lib/src/features/reports/data/report_repository.dart`

Create `ReportRepository` class:
- `saveAndSync(CaptureResult)`: Save locally → sync to Supabase ✓
- `getReports()`: Get all local reports ✓
- `retrySyncReport(String id)`: Retry failed sync ✓

Expose via Riverpod provider. ✓

**Validation**: Repository orchestrates local + remote ✓

---

## Task 7: Update Camera Controller ✅
**Scope**: `lib/src/features/camera/presentation/camera_controller.dart`

After capture:
- Call `reportRepository.saveAndSync(captureResult)` ✓
- Handle success/failure ✓

**Validation**: Capture saves to local and syncs ✓

---

## Task 8: Create Reports Page ✅
**Scope**: `lib/src/features/reports/presentation/reports_page.dart`

Create `ReportsPage` with:
- List of all reports (most recent first) ✓
- Each item shows: thumbnail, date, location, sync status ✓
- Sync status indicator (icon + color) ✓
- Pull-to-refresh ✓
- Empty state ✓

**Validation**: UI renders correctly ✓

---

## Task 9: Add Reports Navigation to HomePage ✅
**Scope**: `lib/src/features/home/presentation/home_page.dart`

Add "View Reports" button that navigates to ReportsPage. ✓

**Validation**: Navigation works ✓

---

## Task 10: Manual Testing 🔄
- [ ] Capture photo → Report saved locally
- [ ] Report synced to Supabase
- [ ] Reports page shows all reports
- [ ] Sync status visible (synced/pending/failed)
- [ ] Kill app and reopen → Reports still visible
- [ ] Check Supabase Storage for uploaded photos
- [ ] Check Supabase `field_reports` table for records

**Validation**: End-to-end flow works

**Note**: Build successful. APK available at `build/app/outputs/flutter-apk/app-debug.apk`
