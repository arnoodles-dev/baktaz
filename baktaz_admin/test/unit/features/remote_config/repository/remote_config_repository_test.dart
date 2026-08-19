// ignore_for_file: prefer-match-file-name

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:baktaz_admin/features/remote_config/data/repository/remote_config_repository.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/config_snapshot_version.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
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
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
        ByteData? message,
      ) async {
        if (message == null) {
          return null;
        }
        final String key = utf8.decode(message.buffer.asUint8List());
        File file = File(key);
        if (!file.existsSync()) {
          file = File('baktaz_admin/$key');
        }
        if (file.existsSync()) {
          final Uint8List bytes = await file.readAsBytes();
          return ByteData.sublistView(bytes);
        }
        return null;
      });
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
        expect(failure, isA<Failure>());
      }, (_) => fail('Expected Left'));
    });

    test('getRemoteConfig handles validation failure when config contains invalid email', () async {
      // Arrange
      final Map<String, dynamic> invalidEmailJson = <String, dynamic>{
        'version': <String, dynamic>{
          'versionNumber': 'v1.0.0',
          'updateTime': '2026-05-15T10:00:00.000Z',
          'updateUser': 'not-an-email',
        },
        'parameters': <String, dynamic>{},
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
        ByteData? message,
      ) async {
        final String key = utf8.decode(message!.buffer.asUint8List());
        if (key == 'assets/json/remote_config_baktaz_13.json') {
          final Uint8List bytes = utf8.encoder.convert(jsonEncode(invalidEmailJson));
          return bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes);
        }
        return null;
      });
      repository = const RemoteConfigRepository();

      // Act
      final Either<Failure, RemoteConfig> result = await repository.getRemoteConfig().run();

      // Assert
      expect(result.isLeft(), isTrue);
    });

    test('getRemoteConfig handles validation failure when numeric parameter rollout is negative (<0)', () async {
      // Arrange
      final Map<String, dynamic> invalidRolloutJson = <String, dynamic>{
        'version': <String, dynamic>{
          'versionNumber': 'v1.0.0',
          'updateTime': '2026-05-15T10:00:00.000Z',
          'updateUser': 'admin@baktaz.com',
        },
        'parameters': <String, dynamic>{
          'bad_param': <String, dynamic>{
            'valueType': 'number',
            'defaultValue': <String, dynamic>{'value': -5},
          },
        },
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
        ByteData? message,
      ) async {
        final String key = utf8.decode(message!.buffer.asUint8List());
        if (key == 'assets/json/remote_config_baktaz_13.json') {
          final Uint8List bytes = utf8.encoder.convert(jsonEncode(invalidRolloutJson));
          return bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes);
        }
        return null;
      });
      repository = const RemoteConfigRepository();

      // Act
      final Either<Failure, RemoteConfig> result = await repository.getRemoteConfig().run();

      // Assert
      expect(result.isLeft(), isTrue);
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

    test('publishConfig handles exception during serialization', () async {
      final RemoteConfig config = RemoteConfig(
        version: ConfigSnapshotVersion(
          versionNumber: ValueString('v1.0.0', fieldName: 'versionNumber'),
          updateTime: DateTime.now(),
          updateUser: EmailAddress('admin@baktaz.com'),
        ),
        parameters: _ExceptionMap<String, RemoteConfigValue>(),
      );

      final Either<Failure, Unit> result = await repository.publishConfig(config).run();

      expect(result.isLeft(), isTrue);
      result.match((Failure failure) => expect(failure, isA<Failure>()), (_) => fail('Expected Left'));
    });
  });
}

class _ExceptionMap<K, V> extends MapBase<K, V> {
  @override
  V? operator [](Object? key) => throw Exception('Map crash');
  @override
  void operator []=(K key, V value) => throw Exception('Map crash');
  @override
  void clear() => throw Exception('Map crash');
  @override
  Iterable<K> get keys => throw Exception('Map crash');
  @override
  V? remove(Object? key) => throw Exception('Map crash');
}
