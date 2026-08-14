import 'package:baktaz_admin/features/remote_config/domain/entity/config_snapshot_version.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_config.freezed.dart';

/// Root entity representing a full remote configuration snapshot.
@freezed
sealed class RemoteConfig with _$RemoteConfig {
  const factory RemoteConfig({
    required Map<String, RemoteConfigValue> parameters,
    required ConfigSnapshotVersion version,
  }) = _RemoteConfig;

  const RemoteConfig._();

  Option<Failure> get validate {
    final Option<Failure> versionValidation = version.validate;
    if (versionValidation.isSome()) return versionValidation;

    for (final RemoteConfigValue value in parameters.values) {
      final Option<Failure> valueValidation = value.validate;
      if (valueValidation.isSome()) return valueValidation;
    }

    return none();
  }
}
