import 'package:flutter_test/flutter_test.dart';
import 'package:project_cyan_sawu/src/features/camera/data/watermark_service.dart';

void main() {
  late WatermarkService watermarkService;

  setUp(() {
    watermarkService = WatermarkService();
  });

  group('WatermarkService', () {
    group('formatWatermarkText', () {
      test('formats positive coordinates with N and E directions', () {
        final result = watermarkService.formatWatermarkText(
          latitude: 10.123456,
          longitude: 123.456789,
          timestamp: DateTime.utc(2026, 1, 25, 7, 2, 8),
          userId: 'user-abc123',
        );

        expect(result, contains('10.123456N'));
        expect(result, contains('123.456789E'));
        expect(result, contains('2026-01-25'));
        expect(result, contains('user-abc...'));
      });

      test('formats negative coordinates with S and W directions', () {
        final result = watermarkService.formatWatermarkText(
          latitude: -10.123456,
          longitude: -123.456789,
          timestamp: DateTime.utc(2026, 1, 25, 7, 2, 8),
          userId: 'user123',
        );

        expect(result, contains('10.123456S'));
        expect(result, contains('123.456789W'));
      });

      test('truncates long user IDs', () {
        final result = watermarkService.formatWatermarkText(
          latitude: 0.0,
          longitude: 0.0,
          timestamp: DateTime.utc(2026, 1, 25),
          userId: 'very-long-user-id-that-should-be-truncated',
        );

        expect(result, contains('very-lon...'));
        expect(result, isNot(contains('very-long-user-id')));
      });

      test('does not truncate short user IDs', () {
        final result = watermarkService.formatWatermarkText(
          latitude: 0.0,
          longitude: 0.0,
          timestamp: DateTime.utc(2026, 1, 25),
          userId: 'short',
        );

        expect(result, contains('USER: short'));
      });

      test('formats timestamp as ISO 8601 UTC', () {
        final result = watermarkService.formatWatermarkText(
          latitude: 0.0,
          longitude: 0.0,
          timestamp: DateTime.utc(2026, 1, 25, 14, 30, 45),
          userId: 'user',
        );

        expect(result, contains('2026-01-25T14:30:45'));
      });

      test('uses 6 decimal places for coordinates', () {
        final result = watermarkService.formatWatermarkText(
          latitude: 1.1,
          longitude: 2.2,
          timestamp: DateTime.utc(2026, 1, 25),
          userId: 'user',
        );

        expect(result, contains('1.100000N'));
        expect(result, contains('2.200000E'));
      });
    });
  });
}
