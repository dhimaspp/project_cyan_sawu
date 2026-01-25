# Spec: Report List

## Overview
Report list capability defines how users view their captured reports and their sync status.

## ADDED Requirements

### Requirement: Reports Page Access
The system SHALL provide access to the Reports page from the HomePage.

#### Scenario: User navigates to reports
- **Given** the user is on HomePage
- **When** the user taps "View Reports"
- **Then** the ReportsPage is displayed

---

### Requirement: Report List Display
The system SHALL display all local reports in a list format.

#### Scenario: Reports exist
- **Given** the user has captured reports
- **When** the ReportsPage is displayed
- **Then** all reports are shown in a list
- **And** reports are ordered by capture date (newest first)

#### Scenario: No reports exist
- **Given** the user has not captured any reports
- **When** the ReportsPage is displayed
- **Then** an empty state message is shown
- **And** a prompt to capture the first report is displayed

---

### Requirement: Report Item Information
Each report item in the list SHALL display key information.

#### Scenario: Report item is displayed
- **Given** a report exists in the list
- **When** the list is rendered
- **Then** each item shows:
  - Photo thumbnail
  - Capture date and time
  - GPS coordinates (or location name if available)
  - Sync status indicator

---

### Requirement: Sync Status Visualization
The system SHALL visually indicate the sync status of each report.

#### Scenario: Report is synced
- **Given** a report has `syncStatus = synced`
- **When** the report is displayed
- **Then** a green checkmark icon is shown
- **And** status text shows "Synced"

#### Scenario: Report is pending
- **Given** a report has `syncStatus = pending`
- **When** the report is displayed
- **Then** an orange clock icon is shown
- **And** status text shows "Pending"

#### Scenario: Report sync failed
- **Given** a report has `syncStatus = failed`
- **When** the report is displayed
- **Then** a red error icon is shown
- **And** status text shows "Failed"
- **And** tapping shows error details or retry option

---

### Requirement: Pull to Refresh
The system SHALL support pull-to-refresh to reload the report list.

#### Scenario: User pulls to refresh
- **Given** the user is on ReportsPage
- **When** the user pulls down to refresh
- **Then** the report list is reloaded from local storage
- **And** any pending syncs are attempted

## Cross-References
- See: `report-storage` capability for persistence requirements
