import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/remote_config/data/repository/remote_config_repository.dart';
import 'package:baktaz_server/src/features/remote_config/domain/interface/i_remote_config_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:get_it/get_it.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../../../integration/test_tools/serverpod_test_tools.dart';

void main() {
  if (!GetIt.I.isRegistered<IRemoteConfigRepository>()) {
    configureDependencies();
  }
  withServerpod(
    'Given RemoteConfigRepository',
    (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
      late RemoteConfigRepository repository;

      setUp(() {
        repository = RemoteConfigRepository();
      });

      group('getPublicConfig', () {
        test('returns default version when no snapshots exist', () async {
          final Session session = sessionBuilder.build();
          final RemoteConfig config = await repository.getPublicConfig(session);

          expect(config.version.versionNumber, equals('0'));
          expect(config.config, isEmpty);
        });

        test('returns compiled config entries and latest snapshot version', () async {
          final Session session = sessionBuilder.build();

          await repository.createConfigKey(
            session,
            key: 'is_maintenance',
            valueType: RemoteConfigValueType.boolean,
            defaultValue: 'false',
            description: 'Maintenance mode flag',
          );
          await repository.createConfigKey(
            session,
            key: 'welcome_message',
            valueType: RemoteConfigValueType.string,
            defaultValue: 'Welcome to Baktaz!',
          );

          await repository.createSnapshotVersion(
            session,
            versionNumber: '1.0.0',
            updateUserEmail: 'admin@baktaz.com',
          );

          final RemoteConfig config = await repository.getPublicConfig(session);

          expect(config.version.versionNumber, equals('1.0.0'));
          expect(config.config.length, equals(2));
          expect(config.config['is_maintenance']?.value, equals('false'));
          expect(config.config['is_maintenance']?.valueType, equals(RemoteConfigValueType.boolean));
          expect(config.config['welcome_message']?.value, equals('Welcome to Baktaz!'));
        });
      });

      group('ConfigKey CRUD operations', () {
        test('createConfigKey inserts row into DB', () async {
          final Session session = sessionBuilder.build();

          final ConfigKey key = await repository.createConfigKey(
            session,
            key: 'feature_chat',
            valueType: RemoteConfigValueType.boolean,
            defaultValue: 'true',
            description: 'Enable in-app chat',
          );

          expect(key.id, isNotNull);
          expect(key.key, equals('feature_chat'));
          expect(key.valueType, equals(RemoteConfigValueType.boolean));
          expect(key.defaultValue, equals('true'));

          final List<ConfigKey> keys = await repository.getConfigKeys(session);
          expect(keys.length, equals(1));
          expect(keys.first.key, equals('feature_chat'));
        });

        test('updateConfigKeyDefaultValue updates defaultValue and sets updatedAt', () async {
          final Session session = sessionBuilder.build();

          final ConfigKey created = await repository.createConfigKey(
            session,
            key: 'max_retry',
            valueType: RemoteConfigValueType.integer,
            defaultValue: '3',
          );

          final ConfigKey updated = await repository.updateConfigKeyDefaultValue(
            session,
            configKeyId: created.id!,
            defaultValue: '5',
          );

          expect(updated.defaultValue, equals('5'));
          expect(updated.updatedAt, isNotNull);
        });

        test('updateConfigKeyDefaultValue throws ApiException for non-existent key', () async {
          final Session session = sessionBuilder.build();
          final UuidValue nonExistentId = UuidValue.fromString('00000000-0000-4000-8000-000000000999');

          expect(
            () => repository.updateConfigKeyDefaultValue(
              session,
              configKeyId: nonExistentId,
              defaultValue: '10',
            ),
            throwsA(isA<ApiException>().having((ApiException e) => e.code, 'code', ApiExceptionCode.notFound)),
          );
        });

        test('deleteConfigKey removes key from DB', () async {
          final Session session = sessionBuilder.build();

          final ConfigKey key = await repository.createConfigKey(
            session,
            key: 'temp_key',
            valueType: RemoteConfigValueType.string,
            defaultValue: 'test',
          );

          await repository.deleteConfigKey(session, key.id!);

          final List<ConfigKey> keys = await repository.getConfigKeys(session);
          expect(keys, isEmpty);
        });
      });

      group('ConfigSnapshotVersion operations', () {
        test('createSnapshotVersion and getLatestSnapshotVersion', () async {
          final Session session = sessionBuilder.build();

          await repository.createSnapshotVersion(
            session,
            versionNumber: '1.0.0',
            updateUserEmail: 'v1@test.com',
          );
          await repository.createSnapshotVersion(
            session,
            versionNumber: '2.0.0',
            updateUserEmail: 'v2@test.com',
          );

          final ConfigSnapshotVersion? latest = await repository.getLatestSnapshotVersion(session);

          expect(latest, isNotNull);
          expect(latest!.versionNumber, equals('2.0.0'));
          expect(latest.updateUserEmail, equals('v2@test.com'));
        });
      });
    },
    applyMigrations: true,
  );
}
