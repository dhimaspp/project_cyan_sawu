// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_report_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remoteReportService)
final remoteReportServiceProvider = RemoteReportServiceProvider._();

final class RemoteReportServiceProvider
    extends
        $FunctionalProvider<
          RemoteReportService,
          RemoteReportService,
          RemoteReportService
        >
    with $Provider<RemoteReportService> {
  RemoteReportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteReportServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteReportServiceHash();

  @$internal
  @override
  $ProviderElement<RemoteReportService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteReportService create(Ref ref) {
    return remoteReportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteReportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteReportService>(value),
    );
  }
}

String _$remoteReportServiceHash() =>
    r'1d4996930d10117536a4c4427530eeb2ffe69a70';
