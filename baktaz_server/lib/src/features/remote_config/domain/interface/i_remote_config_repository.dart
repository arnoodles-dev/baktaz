import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Repository for building and managing the remote config evaluation engine.
///
/// The core operation is [getPublicConfig], which reads all [ConfigKey] rows
/// from the database, pairs each with its current value, and returns a
/// [RemoteConfig] composite along with the latest [ConfigSnapshotVersion].
abstract interface class IRemoteConfigRepository {
  /// Builds the public remote config by reading all [ConfigKey] rows and
  /// pairing them with the latest [ConfigSnapshotVersion].
  Future<RemoteConfig> getPublicConfig(Session session);

  /// Lists all config keys ordered by key name.
  Future<List<ConfigKey>> getConfigKeys(Session session);

  /// Creates a new config key. Throws if the key already exists (unique index).
  Future<ConfigKey> createConfigKey(
    Session session, {
    required String key,
    required RemoteConfigValueType valueType,
    required String defaultValue,
    String? description,
  });

  /// Updates a config key's default value and bumps [ConfigKey.updatedAt].
  Future<ConfigKey> updateConfigKeyDefaultValue(
    Session session, {
    required UuidValue configKeyId,
    required String defaultValue,
  });

  /// Deletes a config key by ID. Cascade-deletes associated targeting overrides.
  Future<void> deleteConfigKey(Session session, UuidValue configKeyId);

  /// Creates a new config snapshot version.
  Future<ConfigSnapshotVersion> createSnapshotVersion(
    Session session, {
    required String versionNumber,
    String? updateUserEmail,
    String? updateOrigin,
    String? updateType,
  });

  /// Returns the latest config snapshot version, or `null` if none exist.
  Future<ConfigSnapshotVersion?> getLatestSnapshotVersion(Session session);
}
