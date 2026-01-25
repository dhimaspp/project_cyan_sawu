import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart' as cam;

import '../data/location_service.dart';
import 'camera_controller.dart' as ctrl;
import 'widgets/watermark_overlay.dart';

/// Full-screen camera page for capturing field reports
///
/// CRITICAL: This page intentionally has NO gallery picker button
/// to prevent fake data uploads.
class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> with WidgetsBindingObserver {
  bool _isInitializing = true;
  String? _error;
  cam.CameraController? _cameraController;
  List<cam.CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App lifecycle handling for camera
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _error = null;
    });

    try {
      // Check location permission first
      final locationService = ref.read(locationServiceProvider);
      final hasLocationPermission = await locationService.requestPermission();

      if (!hasLocationPermission) {
        setState(() {
          _error = 'Location permission is required to capture photos. Please enable it in settings.';
          _isInitializing = false;
        });
        return;
      }

      // Get available cameras
      _cameras = await cam.availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _error = 'No cameras available on this device';
          _isInitializing = false;
        });
        return;
      }

      // Find back camera
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == cam.CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      // Initialize camera controller
      _cameraController = cam.CameraController(
        backCamera,
        cam.ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: cam.ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      debugPrint('📷 Camera initialized successfully');

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Camera initialization failed: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to initialize camera: $e';
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(ctrl.cameraControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Capture Report', style: TextStyle(color: Colors.white)),
      ),
      extendBodyBehindAppBar: true,
      body: _buildBody(cameraState),
    );
  }

  Widget _buildBody(AsyncValue<void> cameraState) {
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Initializing camera...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeCamera,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: Text('Camera not available', style: TextStyle(color: Colors.white)));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        CameraPreviewWidget(controller: _cameraController!),

        // Watermark overlay (live preview)
        const Positioned(left: 0, right: 0, bottom: 100, child: WatermarkOverlay()),

        // Capture button
        Positioned(left: 0, right: 0, bottom: 24, child: _buildCaptureButton(cameraState)),
      ],
    );
  }

  Widget _buildCaptureButton(AsyncValue<void> cameraState) {
    final isCapturing = cameraState.isLoading;

    return Center(
      child: SizedBox(
        width: 72,
        height: 72,
        child: FloatingActionButton(
          onPressed: isCapturing ? null : _onCapturePressed,
          backgroundColor: Colors.white,
          child:
              isCapturing
                  ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3))
                  : const Icon(Icons.camera, size: 36, color: Colors.black),
        ),
      ),
    );
  }

  Future<void> _onCapturePressed() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera not ready'), backgroundColor: Colors.orange));
      return;
    }

    try {
      // Capture using local controller and then process via repository
      final imageFile = await _cameraController!.takePicture();
      final imageBytes = await imageFile.readAsBytes();

      // Use the camera controller notifier for processing
      await ref.read(ctrl.cameraControllerProvider.notifier).captureWithImage(imageBytes);

      final state = ref.read(ctrl.cameraControllerProvider);
      if (state.hasError) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red));
        }
      } else if (!state.isLoading && mounted) {
        // Capture successful - show confirmation and pop
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Photo captured and saved!'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Capture failed: $e'), backgroundColor: Colors.red));
      }
    }
  }
}

/// Camera preview widget
class CameraPreviewWidget extends StatelessWidget {
  final cam.CameraController controller;

  const CameraPreviewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize?.height ?? 0,
            height: controller.value.previewSize?.width ?? 0,
            child: cam.CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}
