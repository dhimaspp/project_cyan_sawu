// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cameraRepository)
final cameraRepositoryProvider = CameraRepositoryProvider._();

final class CameraRepositoryProvider
    extends
        $FunctionalProvider<
          CameraRepository,
          CameraRepository,
          CameraRepository
        >
    with $Provider<CameraRepository> {
  CameraRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cameraRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraRepositoryHash();

  @$internal
  @override
  $ProviderElement<CameraRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CameraRepository create(Ref ref) {
    return cameraRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CameraRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CameraRepository>(value),
    );
  }
}

String _$cameraRepositoryHash() => r'4de9b0c7376aa7329fc73b7f032ab0df9713e48e';
