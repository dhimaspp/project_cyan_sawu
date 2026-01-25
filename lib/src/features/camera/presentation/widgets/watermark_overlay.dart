import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/location_service.dart';
import '../../data/watermark_service.dart';

/// Live watermark overlay that shows on the camera preview
/// Updates GPS and time every second
class WatermarkOverlay extends ConsumerStatefulWidget {
  const WatermarkOverlay({super.key});

  @override
  ConsumerState<WatermarkOverlay> createState() => _WatermarkOverlayState();
}

class _WatermarkOverlayState extends ConsumerState<WatermarkOverlay> {
  Timer? _timer;
  Position? _lastPosition;
  DateTime _currentTime = DateTime.now().toUtc();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startUpdates() {
    // Update time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateTime.now().toUtc();
      });
    });

    // Get initial position
    _updatePosition();
  }

  Future<void> _updatePosition() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentLocation();
      setState(() {
        _lastPosition = position;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildOverlayContainer(
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 8),
            Text('Waiting for GPS...', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      );
    }

    if (_error != null || _lastPosition == null) {
      return _buildOverlayContainer(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 16),
            const SizedBox(width: 8),
            Text(_error ?? 'GPS unavailable', style: const TextStyle(color: Colors.orange, fontSize: 12)),
          ],
        ),
      );
    }

    // Get watermark text
    final watermarkService = ref.read(watermarkServiceProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'unknown';

    final watermarkText = watermarkService.formatWatermarkText(
      latitude: _lastPosition!.latitude,
      longitude: _lastPosition!.longitude,
      timestamp: _currentTime,
      userId: userId,
    );

    return _buildOverlayContainer(
      child: Text(
        watermarkText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'monospace',
          shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black)],
        ),
      ),
    );
  }

  Widget _buildOverlayContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
      child: child,
    );
  }
}
