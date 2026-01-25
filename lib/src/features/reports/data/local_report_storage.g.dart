// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_report_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localReportStorage)
final localReportStorageProvider = LocalReportStorageProvider._();

final class LocalReportStorageProvider
    extends
        $FunctionalProvider<
          LocalReportStorage,
          LocalReportStorage,
          LocalReportStorage
        >
    with $Provider<LocalReportStorage> {
  LocalReportStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localReportStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localReportStorageHash();

  @$internal
  @override
  $ProviderElement<LocalReportStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalReportStorage create(Ref ref) {
    return localReportStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalReportStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalReportStorage>(value),
    );
  }
}

String _$localReportStorageHash() =>
    r'93c873e126d4f8363536080a71c2b45bc13cb343';
