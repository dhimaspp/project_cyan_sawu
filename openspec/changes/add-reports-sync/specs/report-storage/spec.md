# Spec: Report Storage

## Overview
Report storage capability defines how field reports are persisted locally and synced to Supabase.

## ADDED Requirements

### Requirement: Local Report Persistence
The system SHALL save all captured reports to local storage (Hive) immediately after capture.

#### Scenario: Report is captured
- **Given** the user captures a photo successfully
- **When** the capture process completes
- **Then** the report is saved to local Hive storage
- **And** the report has a unique local ID
- **And** the report has `syncStatus = pending`

#### Scenario: App is restarted
- **Given** reports have been captured previously
- **When** the app is restarted
- **Then** all local reports are still available
- **And** no data is lost

---

### Requirement: Supabase Photo Upload
The system SHALL upload captured photos to Supabase Storage.

#### Scenario: Photo is synced
- **Given** a report with pending sync status
- **And** the device has network connectivity
- **When** the sync process runs
- **Then** the photo is uploaded to `evidence-photos` bucket
- **And** the path follows format `{userId}/{reportId}.jpg`
- **And** a public URL is returned

---

### Requirement: Supabase Report Record
The system SHALL create a record in the `field_reports` table after photo upload.

#### Scenario: Report record is created
- **Given** a photo has been uploaded successfully
- **When** the record is inserted
- **Then** all required fields are populated:
  - `user_id`, `photo_url`, `gps_lat`, `gps_long`
  - `captured_at`, `data_hash`, `status = 'pending'`
- **And** the local report is updated with `remoteId`

---

### Requirement: Sync Status Tracking
The system SHALL track and display sync status for each report.

#### Scenario: Sync succeeds
- **Given** a report is synced successfully
- **When** the sync completes
- **Then** `syncStatus = synced`
- **And** `remoteId` is populated with Supabase UUID

#### Scenario: Sync fails
- **Given** a sync attempt fails (network error, etc.)
- **When** the error occurs
- **Then** `syncStatus = failed`
- **And** `errorMessage` contains the error details
- **And** the report remains in local storage for retry

## Cross-References
- See: PRD Section 3.4 (Offline Mode Strategy)
- See: PRD Section 4.3 (field_reports table schema)
