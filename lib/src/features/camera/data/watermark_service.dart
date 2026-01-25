import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'watermark_service.g.dart';

/// Service for applying watermarks to captured images
class WatermarkService {
  /// Applies a watermark overlay to the image containing location, time, and user info
  ///
  /// Overlay format:
  /// LAT: -10.123456S, LONG: 123.456789E
  /// 2026-01-25T07:02:08Z
  /// USER: abc123...
  Uint8List applyWatermark({
    required Uint8List imageBytes,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required String userId,
  }) {
    // Decode the image
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Format coordinates with direction indicators
    final latDirection = latitude >= 0 ? 'N' : 'S';
    final longDirection = longitude >= 0 ? 'E' : 'W';
    final latFormatted = '${latitude.abs().toStringAsFixed(6)}$latDirection';
    final longFormatted = '${longitude.abs().toStringAsFixed(6)}$longDirection';

    // Format timestamp as ISO 8601 UTC
    final timestampFormatted = timestamp.toUtc().toIso8601String();

    // Truncate user ID for display
    final userIdTruncated = userId.length > 8 ? '${userId.substring(0, 8)}...' : userId;

    // Build watermark text lines
    final line1 = 'LAT: $latFormatted, LONG: $longFormatted';
    final line2 = timestampFormatted;
    final line3 = 'USER: $userIdTruncated';

    // Calculate text position (bottom of image)
    final padding = 20;
    final lineHeight = 24;
    final startY = image.height - padding - (lineHeight * 3);

    // Draw text with black stroke for visibility
    final textColor = img.ColorRgba8(255, 255, 255, 230); // White, semi-transparent
    final strokeColor = img.ColorRgba8(0, 0, 0, 200); // Black stroke

    // Draw stroke (offset by 1-2 pixels in each direction)
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        if (dx != 0 || dy != 0) {
          img.drawString(image, line1, font: img.arial24, x: padding + dx, y: startY + dy, color: strokeColor);
          img.drawString(
            image,
            line2,
            font: img.arial24,
            x: padding + dx,
            y: startY + lineHeight + dy,
            color: strokeColor,
          );
          img.drawString(
            image,
            line3,
            font: img.arial24,
            x: padding + dx,
            y: startY + lineHeight * 2 + dy,
            color: strokeColor,
          );
        }
      }
    }

    // Draw main text
    img.drawString(image, line1, font: img.arial24, x: padding, y: startY, color: textColor);
    img.drawString(image, line2, font: img.arial24, x: padding, y: startY + lineHeight, color: textColor);
    img.drawString(image, line3, font: img.arial24, x: padding, y: startY + lineHeight * 2, color: textColor);

    // Encode back to JPEG
    final encodedBytes = img.encodeJpg(image, quality: 90);
    return Uint8List.fromList(encodedBytes);
  }

  /// Formats the watermark text for preview overlay (without burning into image)
  String formatWatermarkText({
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required String userId,
  }) {
    final latDirection = latitude >= 0 ? 'N' : 'S';
    final longDirection = longitude >= 0 ? 'E' : 'W';
    final latFormatted = '${latitude.abs().toStringAsFixed(6)}$latDirection';
    final longFormatted = '${longitude.abs().toStringAsFixed(6)}$longDirection';
    final timestampFormatted = timestamp.toUtc().toIso8601String();
    final userIdTruncated = userId.length > 8 ? '${userId.substring(0, 8)}...' : userId;

    return 'LAT: $latFormatted, LONG: $longFormatted\n$timestampFormatted\nUSER: $userIdTruncated';
  }
}

@riverpod
WatermarkService watermarkService(Ref ref) {
  return WatermarkService();
}
