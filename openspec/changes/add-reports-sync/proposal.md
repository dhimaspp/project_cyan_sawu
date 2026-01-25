# Proposal: Add Reports Sync & List

## Summary
Implement local storage and Supabase sync for field reports, with a Reports page accessible from HomePage to view all captured reports and their sync status.

## Motivation
Currently, captured photos are not persisted. The app needs:
1. Local storage (Hive) to save reports for offline-first operation
2. Supabase sync to upload reports when online
3. A Reports page to view history and sync status

This aligns with **Phase 3** from the PRD (Sync & Dashboard).

## Scope

### In Scope
- **FieldReport Model**: Extended from CaptureResult with sync status
- **Local Storage**: Save reports to Hive
- **Supabase Sync**: Upload photo to Storage + insert record to `field_reports` table
- **ReportsPage**: List all reports with sync status
- **HomePage Navigation**: Add button to view reports
- **Sync Status Indicators**: pending, synced, failed

### Out of Scope
- Background sync worker (simplified: sync on capture)
- Retry mechanism with exponential backoff (future enhancement)
- Map view of reports
- Admin verification flow

## Success Criteria
1. After capture, report is saved locally
2. Report is uploaded to Supabase (photo + metadata)
3. Reports page shows all local reports
4. Sync status is visible (pending/synced/failed)
5. Reports persist across app restarts

## Dependencies
- Phase 2 (Camera/CaptureResult) ✓
- add-home-navigation (HomePage) ✓
- Hive package (already in project.md, need to add to pubspec)
