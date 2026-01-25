// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watermark_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(watermarkService)
final watermarkServiceProvider = WatermarkServiceProvider._();

final class WatermarkServiceProvider
    extends
        $FunctionalProvider<
          WatermarkService,
          WatermarkService,
          WatermarkService
        >
    with $Provider<WatermarkService> {
  WatermarkServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watermarkServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watermarkServiceHash();

  @$internal
  @override
  $ProviderElement<WatermarkService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WatermarkService create(Ref ref) {
    return watermarkService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatermarkService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatermarkService>(value),
    );
  }
}

String _$watermarkServiceHash() => r'd29a078ced8b64814f067bb4737aedff96015268';
