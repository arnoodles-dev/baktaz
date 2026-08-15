import 'dart:convert';

import 'package:baktaz_admin/features/remote_config/data/repository/remote_config_repository.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/config_snapshot_version.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RemoteConfigRepository repository;

  setUp(() {
    repository = const RemoteConfigRepository();
  });

  group('RemoteConfigRepository', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', null);
      rootBundle.evict('assets/json/remote_config_baktaz_13.json');
    });

    test('getRemoteConfig loads and parses config from asset', () async {
      // Arrange — use the default (real) asset bundle
      repository = const RemoteConfigRepository();

      // Act
      final Either<Failure, RemoteConfig> result = await repository.getRemoteConfig().run();

      // Assert
      result.fold((Failure l) => fail('Expected Right but got Left: $l'), (RemoteConfig config) {
        expect(config, isA<RemoteConfig>());
        expect(config.parameters, isNotEmpty);
        expect(config.version, isA<ConfigSnapshotVersion>());
      });
    });

    test('getRemoteConfig handles malformed JSON exception', () async {
      // Arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
        ByteData? message,
      ) async {
        final String key = utf8.decode(message!.buffer.asUint8List());
        if (key == 'assets/json/remote_config_baktaz_13.json') {
          final Uint8List bytes = utf8.encoder.convert('invalid json string');
          return bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes);
        }
        return null;
      });
      repository = const RemoteConfigRepository();

      // Act
      final Either<Failure, RemoteConfig> result = await repository.getRemoteConfig().run();

      // Assert
      expect(result.isLeft(), isTrue);
      result.match((Failure failure) {
        expect(failure.message, contains('FormatException:'));
      }, (_) => fail('Should have failed'));
    });

    test('getRemoteConfig handles validation failure when config contains invalid email', () async {
      // Arrange
      final Map<String, dynamic> invalidJson = <String, dynamic>{
        'parameters': <String, dynamic>{},
        'version': <String, dynamic>{
          'versionNumber': '13',
          'updateTime': '2026-07-11T12:00:00Z',
          'updateUser': 'not-an-email',
        },
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
        ByteData? message,
      ) async {
        final String key = utf8.decode(message!.buffer.asUint8List());
        if (key == 'assets/json/remote_config_baktaz_13.json') {
          final Uint8List bytes = utf8.encoder.convert(jsonEncode(invalidJson));
          return bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes);
        }
        return null;
      });
      repository = const RemoteConfigRepository();

      // Act
      final Either<Failure, RemoteConfig> result = await repository.getRemoteConfig().run();

      // Assert
      expect(result.isLeft(), isTrue);
      result.match((Failure failure) {
        expect(failure.message, contains('email must be a valid email address'));
      }, (_) => fail('Should have failed'));
    });

    test('publishConfig succeeds with valid config', () async {
      // Arrange
      final RemoteConfig? config = await repository.getRemoteConfig().run().then(
        (Either<Failure, RemoteConfig> r) => r.getRight().toNullable(),
      );
      if (config == null) fail('Failed to get config');

      // Act
      final Either<Failure, Unit> result = await repository.publishConfig(config).run();

      // Assert
      result.fold((Failure l) => fail('Expected Right but got Left: $l'), (_) {});
    });
  });
}
