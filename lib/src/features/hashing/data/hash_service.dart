import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hash_service.g.dart';

/// Service for generating SHA-256 hashes for cryptographic proof
class HashService {
  /// Generates a SHA-256 hash from capture data
  ///
  /// Input format: {userId}{timestampMs}{lat}{long}{base64Image}
  /// Output: 64-character lowercase hexadecimal string
  String generateHash({
    required String userId,
    required int timestampMs,
    required double latitude,
    required double longitude,
    required Uint8List imageBytes,
  }) {
    // Encode image to base64
    final base64Image = base64Encode(imageBytes);

    // Build plaintext in specified format
    final plaintext = '$userId$timestampMs$latitude$longitude$base64Image';

    // Generate SHA-256 hash
    final bytes = utf8.encode(plaintext);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// Validates that a hash matches the expected format
  /// Returns true if hash is a 64-character lowercase hex string
  bool isValidHash(String hash) {
    if (hash.length != 64) return false;
    return RegExp(r'^[a-f0-9]{64}$').hasMatch(hash);
  }
}

@riverpod
HashService hashService(Ref ref) {
  return HashService();
}
