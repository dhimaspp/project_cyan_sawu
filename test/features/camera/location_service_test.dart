import 'package:flutter_test/flutter_test.dart';
import 'package:project_cyan_sawu/src/features/camera/data/location_service.dart';

void main() {
  group('MockLocationDetectedException', () {
    test('has default message', () {
      const exception = MockLocationDetectedException();
      expect(exception.message, contains('GPS spoofing detected'));
    });

    test('can have custom message', () {
      const exception = MockLocationDetectedException('Custom error');
      expect(exception.message, 'Custom error');
    });

    test('toString returns message', () {
      const exception = MockLocationDetectedException('Test message');
      expect(exception.toString(), 'Test message');
    });
  });

  // Note: Full LocationService testing requires mocking Geolocator
  // which is typically done with mockito and platform channel mocking.
  // These tests verify the exception behavior which can be tested standalone.
}
