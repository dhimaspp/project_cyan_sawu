# Spec: Secure Camera

## Overview
The Secure Camera capability ensures that field report photos are captured directly from the device camera with anti-spoofing protections, preventing the use of pre-existing or manipulated images.

## ADDED Requirements

### Requirement: Camera-Only Capture
The system SHALL only accept photos captured directly from the device camera. Gallery/file picker access SHALL be disabled.

#### Scenario: User opens camera screen
- **Given** the user is authenticated
- **When** the user navigates to the camera screen
- **Then** a full-screen camera preview is displayed
- **And** there is NO button or option to select from gallery
- **And** there is a shutter button to capture a photo

#### Scenario: User captures a photo
- **Given** the camera preview is active
- **And** GPS location is available
- **When** the user taps the shutter button
- **Then** a photo is captured from the live camera feed
- **And** the photo is not sourced from any external file

---

### Requirement: Mock Location Detection
The system SHALL detect and reject captures when GPS spoofing (mock location) is active on Android devices.

#### Scenario: Mock location is enabled
- **Given** the user has enabled mock location in Android Developer Options
- **When** the user attempts to capture a photo
- **Then** the capture is blocked
- **And** an error message is displayed: "GPS spoofing detected. Disable mock location to continue."

#### Scenario: Mock location is disabled
- **Given** mock location is not enabled
- **When** the user captures a photo
- **Then** the capture proceeds normally
- **And** `is_mock_location` is recorded as `false`

---

### Requirement: High-Accuracy GPS
The system SHALL obtain GPS coordinates with the highest available accuracy at the moment of capture.

#### Scenario: GPS is available
- **Given** location permission is granted
- **And** GPS signal is available
- **When** a photo is captured
- **Then** latitude and longitude are recorded with at least 6 decimal places
- **And** the location accuracy mode is set to "best"

#### Scenario: GPS is unavailable
- **Given** GPS signal is not available
- **When** the user attempts to capture
- **Then** the shutter button is disabled
- **And** a message is displayed: "Waiting for GPS signal..."

---

### Requirement: Watermark Overlay
The system SHALL burn a visible watermark onto each captured image containing location, time, and user identification.

#### Scenario: Photo is captured
- **Given** GPS and timestamp are available
- **When** the photo is saved
- **Then** the image contains a visible text overlay
- **And** the overlay includes: latitude, longitude, UTC timestamp, and truncated user ID
- **And** the overlay is positioned at the bottom of the image
- **And** the overlay uses high-contrast styling (white text with black stroke)

---

### Requirement: Permission Handling
The system SHALL request and handle camera and location permissions gracefully.

#### Scenario: Permissions not granted
- **Given** camera or location permission is denied
- **When** the user opens the camera screen
- **Then** a prompt is shown explaining why permissions are needed
- **And** a button is provided to open system settings

#### Scenario: Permissions granted
- **Given** camera and location permissions are granted
- **When** the user opens the camera screen
- **Then** the camera preview initializes successfully

## Cross-References
- See: `cryptographic-proof` capability for hash generation requirements
