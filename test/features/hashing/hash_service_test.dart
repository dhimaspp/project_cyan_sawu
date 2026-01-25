import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_cyan_sawu/src/features/hashing/data/hash_service.dart';

void main() {
  late HashService hashService;

  setUp(() {
    hashService = HashService();
  });

  group('HashService', () {
    test('generateHash returns 64-character hex string', () {
      final result = hashService.generateHash(
        userId: 'test-user-123',
        timestampMs: 1737781328000,
        latitude: -10.123456,
        longitude: 123.456789,
        imageBytes: Uint8List.fromList([1, 2, 3, 4, 5]),
      );

      expect(result.length, 64);
      expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(result), isTrue);
    });

    test('generateHash is deterministic (same input = same output)', () {
      final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      final result1 = hashService.generateHash(
        userId: 'user-abc',
        timestampMs: 1000000,
        latitude: -5.5,
        longitude: 100.0,
        imageBytes: imageBytes,
      );

      final result2 = hashService.generateHash(
        userId: 'user-abc',
        timestampMs: 1000000,
        latitude: -5.5,
        longitude: 100.0,
        imageBytes: imageBytes,
      );

      expect(result1, result2);
    });

    test('generateHash produces different output for different inputs', () {
      final imageBytes = Uint8List.fromList([1, 2, 3]);

      final result1 = hashService.generateHash(
        userId: 'user-1',
        timestampMs: 1000000,
        latitude: -5.0,
        longitude: 100.0,
        imageBytes: imageBytes,
      );

      final result2 = hashService.generateHash(
        userId: 'user-2', // Different user
        timestampMs: 1000000,
        latitude: -5.0,
        longitude: 100.0,
        imageBytes: imageBytes,
      );

      expect(result1, isNot(result2));
    });

    test('generateHash follows expected input format', () {
      // Test that the hash matches what we'd expect from manual computation
      const userId = 'abc123';
      const timestampMs = 1737781328000;
      const latitude = -10.123456;
      const longitude = 123.456789;
      final imageBytes = Uint8List.fromList([0, 1, 2]);
      final base64Image = base64Encode(imageBytes);

      // Manually compute expected hash
      final plaintext = '$userId$timestampMs$latitude$longitude$base64Image';
      final expectedHash = sha256.convert(utf8.encode(plaintext)).toString();

      final result = hashService.generateHash(
        userId: userId,
        timestampMs: timestampMs,
        latitude: latitude,
        longitude: longitude,
        imageBytes: imageBytes,
      );

      expect(result, expectedHash);
    });

    test('isValidHash returns true for valid 64-char hex', () {
      const validHash = 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2';
      expect(hashService.isValidHash(validHash), isTrue);
    });

    test('isValidHash returns false for invalid hashes', () {
      expect(hashService.isValidHash('too-short'), isFalse);
      expect(hashService.isValidHash(''), isFalse);
      // Invalid chars (uppercase not allowed in our format)
      expect(hashService.isValidHash('A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2'), isFalse);
    });
  });
}
