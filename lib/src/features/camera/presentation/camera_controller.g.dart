// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CameraController)
final cameraControllerProvider = CameraControllerProvider._();

final class CameraControllerProvider
    extends $AsyncNotifierProvider<CameraController, void> {
  CameraControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cameraControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraControllerHash();

  @$internal
  @override
  CameraController create() => CameraController();
}

String _$cameraControllerHash() => r'1b46f97f57e15ec2430d9c9a78162639e73e8933';

abstract class _$CameraController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
