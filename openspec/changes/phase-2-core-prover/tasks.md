# Tasks: Phase 2 – The Core "Prover"

## Prerequisites
- [x] Phase 1 complete (Auth working)
- [x] Add required dependencies to pubspec.yaml

---

## Task 1: Add Dependencies ✅
**Scope**: `pubspec.yaml`

Add the following packages:
- `camera: ^0.11.0` - Camera access
- `geolocator: ^13.0.1` - High-accuracy GPS
- `image: ^4.3.0` - Image manipulation (watermarking)
- `path_provider: ^2.1.5` - File system access

**Validation**: `flutter pub get` succeeds ✓

---

## Task 2: Create Feature Scaffolding ✅
**Scope**: `lib/src/features/`

Create directory structure:
```
features/
├── camera/
│   ├── data/
│   ├── domain/
│   └── presentation/
│       └── widgets/
└── hashing/
    └── data/
```

**Validation**: Directories exist ✓

---

## Task 3: Implement Location Service ✅
**Scope**: `lib/src/features/camera/data/location_service.dart`

Create `LocationService` class:
- `getCurrentLocation()`: Returns `Position` with high accuracy
- `isMockLocation()`: Returns `true` if GPS is spoofed (Android)
- Handle permission requests

**Validation**: Unit test with mocked Geolocator ✓

---

## Task 4: Implement Hash Service ✅
**Scope**: `lib/src/features/hashing/data/hash_service.dart`

Create `HashService` class:
- `generateHash(userId, timestamp, lat, long, imageBytes)`: Returns SHA-256 hex string
- Input format: `{userId}{timestampMs}{lat}{long}{base64Image}`

**Validation**: Unit test with known input/output pair ✓

---

## Task 5: Implement Watermark Service ✅
**Scope**: `lib/src/features/camera/data/watermark_service.dart`

Create `WatermarkService` class:
- `applyWatermark(imageBytes, lat, long, timestamp, userId)`: Returns modified image bytes
- Overlay format: `LAT, LONG | TIMESTAMP (UTC) | USER_ID`
- White text with black stroke for visibility

**Validation**: Unit test produces image with embedded text ✓

---

## Task 6: Implement CaptureResult Model ✅
**Scope**: `lib/src/features/camera/domain/capture_result.dart`

Create `CaptureResult` model:
```dart
class CaptureResult {
  final Uint8List imageBytes;
  final double latitude;
  final double longitude;
  final DateTime capturedAt;
  final String userId;
  final String dataHash;
  final bool isMockLocation;
}
```

**Validation**: Model compiles, freezed/json_serializable if needed ✓

---

## Task 7: Implement Camera Repository ✅
**Scope**: `lib/src/features/camera/data/camera_repository.dart`

Create `CameraRepository` class:
- `initialize()`: Setup camera controller
- `capture()`: Full flow → GPS → Mock check → Photo → Watermark → Hash → CaptureResult
- `dispose()`: Cleanup

Expose via Riverpod provider.

**Validation**: Integration test on emulator ✓

---

## Task 8: Implement Camera Page UI ✅
**Scope**: `lib/src/features/camera/presentation/camera_page.dart`

Create `CameraPage` widget:
- Full-screen camera preview
- Shutter button (FAB style)
- **NO gallery picker button** (critical constraint)
- Loading state during capture
- Error state with retry

**Validation**: Widget test confirms no gallery button exists ✓

---

## Task 9: Implement Watermark Overlay Widget ✅
**Scope**: `lib/src/features/camera/presentation/widgets/watermark_overlay.dart`

Create `WatermarkOverlay` widget:
- Live preview overlay showing current GPS + time
- Updates every second
- Positioned at bottom of preview

**Validation**: Widget renders in camera preview ✓

---

## Task 10: Add Android Permissions ✅
**Scope**: `android/app/src/main/AndroidManifest.xml`

Add permissions:
- `android.permission.CAMERA`
- `android.permission.ACCESS_FINE_LOCATION`
- `android.permission.ACCESS_COARSE_LOCATION`

**Validation**: App requests permissions on camera open ✓

---

## Task 11: Add iOS Permissions ✅
**Scope**: `ios/Runner/Info.plist`

Add usage descriptions:
- `NSCameraUsageDescription`
- `NSLocationWhenInUseUsageDescription`

**Validation**: App requests permissions on camera open (iOS) ✓

---

## Task 12: Write Unit Tests ✅
**Scope**: `test/`

Create tests:
- `hash_service_test.dart`: Verify SHA-256 output ✓
- `location_service_test.dart`: Mock location detection ✓
- `watermark_service_test.dart`: Image modification ✓

**Validation**: `flutter test` passes (16 tests passed) ✓

---

## Task 13: Integration & Manual Testing 🔄
**Scope**: Full feature

- [ ] Test on physical Android device
- [ ] Verify mock location is detected (enable Developer Options → Mock Location)
- [ ] Verify watermark is visible in captured image
- [ ] Verify hash is generated

**Validation**: Demo video or screenshot

**Note**: Build successful. APK available at `build/app/outputs/flutter-apk/app-debug.apk`

---

## Parallelization Notes
- Tasks 3, 4, 5, 6 can be done in parallel ✓
- Task 7 depends on 3, 4, 5, 6 ✓
- Task 8, 9 depend on 7 ✓
- Tasks 10, 11 can be done anytime ✓
- Task 12 can start after 3, 4, 5 ✓
