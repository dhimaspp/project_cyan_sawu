import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

/// Exception thrown when mock location is detected
class MockLocationDetectedException implements Exception {
  final String message;
  const MockLocationDetectedException([this.message = 'GPS spoofing detected. Disable mock location to continue.']);

  @override
  String toString() => message;
}

/// Service for obtaining high-accuracy GPS location with anti-spoofing checks
class LocationService {
  /// Checks and requests location permission if needed
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Returns current position with high accuracy
  /// Throws [MockLocationDetectedException] if GPS spoofing is detected on Android
  Future<Position> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );

    // Check for mock location (Android only)
    if (position.isMocked) {
      throw const MockLocationDetectedException();
    }

    return position;
  }

  /// Checks if mock location is enabled without throwing
  Future<bool> isMockLocationEnabled() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      return position.isMocked;
    } catch (_) {
      return false;
    }
  }

  /// Stream of position updates for live preview
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 1),
    );
  }
}

@riverpod
LocationService locationService(Ref ref) {
  return LocationService();
}
