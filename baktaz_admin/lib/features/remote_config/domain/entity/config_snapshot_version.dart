import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_snapshot_version.freezed.dart';

/// Tracks the version metadata of a remote config snapshot.
@freezed
sealed class ConfigSnapshotVersion with _$ConfigSnapshotVersion {
  const factory ConfigSnapshotVersion({
    required ValueString versionNumber,
    required DateTime updateTime,
    required EmailAddress updateUser,
  }) = _ConfigSnapshotVersion;

  const ConfigSnapshotVersion._();

  Option<Failure> get validate => versionNumber.validate.andThen(() => updateUser.validate).fold(some, (_) => none());
}
