# Design: Phase 2 – Core Prover Architecture

## Overview
The Prover module is the heart of the dMRV system. It ensures that every field report photo is provably authentic by implementing three layers of protection:

1. **Capture Control**: Exclusive camera access (no gallery)
2. **Location Integrity**: Anti-spoofing checks
3. **Cryptographic Proof**: Immutable hash of image + metadata

## Architecture

### Feature Structure
```
lib/src/features/
├── camera/
│   ├── data/
│   │   ├── camera_repository.dart       # Camera lifecycle management
│   │   └── location_service.dart        # GPS + anti-spoofing
│   ├── domain/
│   │   └── capture_result.dart          # Model for captured image + metadata
│   └── presentation/
│       ├── camera_page.dart             # Full-screen camera UI
│       ├── camera_controller.dart       # Riverpod controller
│       └── widgets/
│           └── watermark_overlay.dart   # Live preview overlay
└── hashing/
    └── data/
        └── hash_service.dart            # SHA-256 implementation
```

## Component Design

### 1. Camera Repository
**Responsibility**: Manage camera lifecycle, capture images, and coordinate with location service.

**Key Methods**:
- `initialize()`: Request camera permission, initialize CameraController
- `capture()`: Take photo, get GPS, detect mock location, return CaptureResult
- `dispose()`: Clean up resources

**Anti-Spoofing Logic** (Android only):
- Check `Position.isMocked` from Geolocator
- If true, throw `MockLocationDetectedException`

### 2. Watermark Overlay
**Responsibility**: Render overlay on camera preview AND burn into final image.

**Overlay Format**:
```
LAT: -10.123456S, LONG: 123.456789E
2026-01-25T07:02:08Z
USER: abc123...
```

**Implementation**:
- Use `image` package to draw text on captured image bytes
- Font: Monospace, semi-transparent white with black stroke for visibility

### 3. Hash Service
**Responsibility**: Generate SHA-256 hash from capture data.

**Input String Format** (from PRD):
```
{user_uuid}{unix_timestamp_ms}{lat}{long}{base64_image}
```

**Output**: 64-character hexadecimal string

**Implementation**:
- Use `crypto` package (already in dependencies)
- Run in isolate to avoid blocking UI on large images

## Data Flow

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│ CameraPage  │────▶│ CameraRepo   │────▶│ GPS Service │
└─────────────┘     └──────────────┘     └─────────────┘
       │                   │
       │                   ▼
       │            ┌──────────────┐
       │            │ Watermarker  │
       │            └──────────────┘
       │                   │
       │                   ▼
       │            ┌──────────────┐
       │            │ Hash Service │
       │            └──────────────┘
       │                   │
       ▼                   ▼
┌─────────────────────────────────────┐
│          CaptureResult              │
│  - image bytes (with watermark)     │
│  - lat, long, timestamp             │
│  - data_hash (SHA-256)              │
│  - is_mock_location                 │
└─────────────────────────────────────┘
```

## Platform Considerations

### Android
- Mock location detection via `Position.isMocked`
- Camera permission: `android.permission.CAMERA`
- Location permission: `android.permission.ACCESS_FINE_LOCATION`

### iOS
- No equivalent mock location detection (iOS doesn't expose this)
- Rely on other trust signals in future phases
- Camera and location permissions in Info.plist

## Error Handling

| Error | User Experience |
|-------|-----------------|
| Camera permission denied | Show settings prompt |
| Location permission denied | Show settings prompt |
| Mock location detected | Error message, capture disabled |
| GPS unavailable | Show "Waiting for GPS..." |
| Camera initialization failed | Error with retry option |

## Testing Strategy

1. **Unit Tests**:
   - Hash generation with known inputs
   - Watermark text formatting
   - Mock location detection logic

2. **Widget Tests**:
   - Camera page renders without gallery button
   - Overlay displays correct format

3. **Integration Tests**:
   - Full capture flow (requires device/emulator)
