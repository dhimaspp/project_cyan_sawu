# Spec: Cryptographic Proof

## Overview
The Cryptographic Proof capability ensures data integrity by generating a SHA-256 hash of the captured image and its metadata immediately after capture (edge hashing). This hash serves as an immutable fingerprint for later verification.

## ADDED Requirements

### Requirement: Edge Hashing
The system SHALL generate a SHA-256 hash on the client device immediately after photo capture, before any network transmission.

#### Scenario: Photo is captured successfully
- **Given** a photo has been captured with valid GPS and timestamp
- **When** the capture process completes
- **Then** a SHA-256 hash is generated on-device
- **And** the hash computation happens before any upload attempt
- **And** the hash is stored as part of the capture result

---

### Requirement: Hash Input Format
The hash SHALL be computed from a specific plaintext format combining user identity, timestamp, location, and image data.

#### Scenario: Hash is generated
- **Given** the following capture data:
  - User UUID: `abc123`
  - Unix Timestamp (ms): `1737781328000`
  - Latitude: `-10.123456`
  - Longitude: `123.456789`
  - Image bytes (base64 encoded)
- **When** the hash is computed
- **Then** the input string is: `abc1231737781328000-10.123456123.456789{base64_image}`
- **And** the output is a 64-character hexadecimal string

---

### Requirement: Hash Output Format
The generated hash SHALL be a lowercase hexadecimal string of exactly 64 characters.

#### Scenario: Hash format validation
- **Given** a hash has been generated
- **When** the hash is inspected
- **Then** it matches the regex pattern `^[a-f0-9]{64}$`

---

### Requirement: Non-Blocking Hash Computation
The hash computation SHALL NOT block the main UI thread, even for large images.

#### Scenario: Large image is captured
- **Given** a high-resolution photo is captured (e.g., 12MP)
- **When** the hash is being computed
- **Then** the UI remains responsive
- **And** a loading indicator is shown
- **And** the hash computation completes without ANR (Application Not Responding)

---

### Requirement: Hash Determinism
The same input data SHALL always produce the same hash output.

#### Scenario: Repeated hash computation
- **Given** identical capture data (same image bytes, timestamp, location, user)
- **When** the hash is computed multiple times
- **Then** the output hash is identical each time

---

### Requirement: Hash Included in Capture Result
The generated hash SHALL be included in the CaptureResult model and eventually persisted with the field report.

#### Scenario: Capture result contains hash
- **Given** a successful capture
- **When** the CaptureResult is created
- **Then** the `dataHash` field is populated with the SHA-256 hash
- **And** the hash can be accessed for display or upload

## Cross-References
- See: `secure-camera` capability for capture flow requirements
- See: PRD Section 3.3 for hash input format specification
