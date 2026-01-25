// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hash_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hashService)
final hashServiceProvider = HashServiceProvider._();

final class HashServiceProvider
    extends $FunctionalProvider<HashService, HashService, HashService>
    with $Provider<HashService> {
  HashServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hashServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hashServiceHash();

  @$internal
  @override
  $ProviderElement<HashService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HashService create(Ref ref) {
    return hashService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HashService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HashService>(value),
    );
  }
}

String _$hashServiceHash() => r'56a05af56d713e4a164151b8264c25b25b3f313b';
