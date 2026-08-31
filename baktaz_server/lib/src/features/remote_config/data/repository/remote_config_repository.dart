import 'package:baktaz_server/src/features/remote_config/domain/interface/i_remote_config_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';

@LazySingleton(as: IRemoteConfigRepository)
final class RemoteConfigRepository implements IRemoteConfigRepository {
  /// Builds the public [RemoteConfig] by reading every [ConfigKey] from the
  /// database, wrapping each into a [RemoteConfigValue], and pairing the map
  /// with the latest [ConfigSnapshotVersion].
  @override
  Future<RemoteConfig> getPublicConfig(Session session) async {
    final List<ConfigKey> configKeys = await ConfigKey.db.find(session);
    final ConfigSnapshotVersion? latestVersion = await _findLatestSnapshotVersion(session);

    final Map<String, RemoteConfigValue> config = <String, RemoteConfigValue>{};
    for (final ConfigKey configKey in configKeys) {
      config[configKey.key] = RemoteConfigValue(
        defaultValue: RemoteConfigDefaultValue(value: configKey.defaultValue),
        valueType: configKey.valueType,
        value: configKey.defaultValue,
      );
    }

    final PublicConfigVersion version = latestVersion != null
        ? PublicConfigVersion(
            versionNumber: latestVersion.versionNumber,
            updateTime: latestVersion.updateTime,
          )
        : PublicConfigVersion(versionNumber: '0', updateTime: DateTime.now());

    return RemoteConfig(config: config, version: version);
  }

  @override
  Future<List<ConfigKey>> getConfigKeys(Session session) async =>
      ConfigKey.db.find(session, orderBy: (ConfigKeyTable t) => t.key);

  @override
  Future<ConfigKey> createConfigKey(
    Session session, {
    required String key,
    required RemoteConfigValueType valueType,
    required String defaultValue,
    String? description,
  }) async =>
      ConfigKey.db.insertRow(
        session,
        ConfigKey(
          key: key,
          valueType: valueType,
          defaultValue: defaultValue,
          description: description,
        ),
      );

  @override
  Future<ConfigKey> updateConfigKeyDefaultValue(
    Session session, {
    required UuidValue configKeyId,
    required String defaultValue,
  }) async {
    final ConfigKey? existing = await ConfigKey.db.findById(session, configKeyId);
    if (existing == null) {
      throw ApiException(message: 'ConfigKey not found: $configKeyId', code: ApiExceptionCode.notFound);
    }
    return ConfigKey.db.updateRow(
      session,
      existing.copyWith(
        defaultValue: defaultValue,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> deleteConfigKey(Session session, UuidValue configKeyId) async {
    final ConfigKey? existing = await ConfigKey.db.findById(session, configKeyId);
    if (existing == null) {
      throw ApiException(message: 'ConfigKey not found: $configKeyId', code: ApiExceptionCode.notFound);
    }
    await ConfigKey.db.deleteRow(session, existing);
  }

  @override
  Future<ConfigSnapshotVersion> createSnapshotVersion(
    Session session, {
    required String versionNumber,
    String? updateUserEmail,
    String? updateOrigin,
    String? updateType,
  }) async =>
      ConfigSnapshotVersion.db.insertRow(
        session,
        ConfigSnapshotVersion(
          versionNumber: versionNumber,
          updateUserEmail: updateUserEmail,
          updateOrigin: updateOrigin,
          updateType: updateType,
        ),
      );

  @override
  Future<ConfigSnapshotVersion?> getLatestSnapshotVersion(Session session) async =>
      _findLatestSnapshotVersion(session);

  Future<ConfigSnapshotVersion?> _findLatestSnapshotVersion(Session session) async {
    final List<ConfigSnapshotVersion> versions = await ConfigSnapshotVersion.db.find(
      session,
      orderBy: (ConfigSnapshotVersionTable t) => t.updateTime.desc(),
      limit: 1,
    );
    return versions.isNotEmpty ? versions.first : null;
  }
}
