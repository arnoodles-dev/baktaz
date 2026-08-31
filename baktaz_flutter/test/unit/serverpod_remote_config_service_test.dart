import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/core/data/service/serverpod_remote_config_service.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.dart';

void main() {
  late MockServerpod mockServerpod;
  late MockClient mockClient;
  late MockIDeviceInfoRepository mockDeviceInfo;
  late MockEndpointRemoteConfig mockEndpoint;

  setUp(() {
    mockServerpod = MockServerpod();
    mockClient = MockClient();
    mockDeviceInfo = MockIDeviceInfoRepository();
    mockEndpoint = MockEndpointRemoteConfig();

    when(mockServerpod.client).thenReturn(mockClient);
    when(mockClient.remoteConfig).thenReturn(mockEndpoint);
    when(mockDeviceInfo.getAppVersion()).thenReturn(const Right<Failure, String>('2.0.0'));
  });

  group(ServerpodRemoteConfigService, () {
    test('returns fallback config when endpoint throws', () async {
      when(
        mockEndpoint.getRemoteConfig(
          appVersion: anyNamed('appVersion'),
          platform: anyNamed('platform'),
        ),
      ).thenThrow(Exception('network error'));

      final ServerpodRemoteConfigService service =
          ServerpodRemoteConfigService(mockServerpod, mockDeviceInfo);
      final Map<String, dynamic> config = await service.remoteConfig;

      expect(config, isA<Map<String, dynamic>>());
      expect(config['is_maintenance'], equals(false));
    });

    test('parses boolean values from server config', () async {
      final RemoteConfig remoteConfig = RemoteConfig(
        config: <String, RemoteConfigValue>{
          'is_maintenance': RemoteConfigValue(
            defaultValue: RemoteConfigDefaultValue(value: 'false'),
            value: 'true',
            valueType: RemoteConfigValueType.boolean,
          ),
        },
        version: PublicConfigVersion(
          versionNumber: '1.0.0',
          updateTime: DateTime(2024),
        ),
      );

      when(
        mockEndpoint.getRemoteConfig(
          appVersion: anyNamed('appVersion'),
          platform: anyNamed('platform'),
        ),
      ).thenAnswer((_) async => remoteConfig);

      final ServerpodRemoteConfigService service =
          ServerpodRemoteConfigService(mockServerpod, mockDeviceInfo);
      final Map<String, dynamic> config = await service.remoteConfig;

      expect(config['is_maintenance'], isTrue);
    });

    test('parses integer values from server config', () async {
      final RemoteConfig remoteConfig = RemoteConfig(
        config: <String, RemoteConfigValue>{
          'max_retries': RemoteConfigValue(
            defaultValue: RemoteConfigDefaultValue(value: '3'),
            value: '5',
            valueType: RemoteConfigValueType.integer,
          ),
        },
        version: PublicConfigVersion(
          versionNumber: '1.0.0',
          updateTime: DateTime(2024),
        ),
      );

      when(
        mockEndpoint.getRemoteConfig(
          appVersion: anyNamed('appVersion'),
          platform: anyNamed('platform'),
        ),
      ).thenAnswer((_) async => remoteConfig);

      final ServerpodRemoteConfigService service =
          ServerpodRemoteConfigService(mockServerpod, mockDeviceInfo);
      final Map<String, dynamic> config = await service.remoteConfig;

      expect(config['max_retries'], equals(5));
    });

    test('parses double values from server config', () async {
      final RemoteConfig remoteConfig = RemoteConfig(
        config: <String, RemoteConfigValue>{
          'score_weight': RemoteConfigValue(
            defaultValue: RemoteConfigDefaultValue(value: '0.5'),
            value: '0.75',
            valueType: RemoteConfigValueType.double,
          ),
        },
        version: PublicConfigVersion(
          versionNumber: '1.0.0',
          updateTime: DateTime(2024),
        ),
      );

      when(
        mockEndpoint.getRemoteConfig(
          appVersion: anyNamed('appVersion'),
          platform: anyNamed('platform'),
        ),
      ).thenAnswer((_) async => remoteConfig);

      final ServerpodRemoteConfigService service =
          ServerpodRemoteConfigService(mockServerpod, mockDeviceInfo);
      final Map<String, dynamic> config = await service.remoteConfig;

      expect(config['score_weight'], equals(0.75));
    });

    test('parses string values from server config', () async {
      final RemoteConfig remoteConfig = RemoteConfig(
        config: <String, RemoteConfigValue>{
          'welcome_msg': RemoteConfigValue(
            defaultValue: RemoteConfigDefaultValue(value: ''),
            value: 'Hello',
            valueType: RemoteConfigValueType.string,
          ),
        },
        version: PublicConfigVersion(
          versionNumber: '1.0.0',
          updateTime: DateTime(2024),
        ),
      );

      when(
        mockEndpoint.getRemoteConfig(
          appVersion: anyNamed('appVersion'),
          platform: anyNamed('platform'),
        ),
      ).thenAnswer((_) async => remoteConfig);

      final ServerpodRemoteConfigService service =
          ServerpodRemoteConfigService(mockServerpod, mockDeviceInfo);
      final Map<String, dynamic> config = await service.remoteConfig;

      expect(config['welcome_msg'], equals('Hello'));
    });

    test('getString returns string for existing key', () async {
      final RemoteConfig remoteConfig = RemoteConfig(
        config: <String, RemoteConfigValue>{
          'key1': RemoteConfigValue(
            defaultValue: RemoteConfigDefaultValue(value: ''),
            value: 'val1',
            valueType: RemoteConfigValueType.string,
          ),
        },
        version: PublicConfigVersion(
          versionNumber: '1.0.0',
          updateTime: DateTime(2024),
        ),
      );

      when(
        mockEndpoint.getRemoteConfig(
          appVersion: anyNamed('appVersion'),
          platform: anyNamed('platform'),
        ),
      ).thenAnswer((_) async => remoteConfig);

      final ServerpodRemoteConfigService service =
          ServerpodRemoteConfigService(mockServerpod, mockDeviceInfo);
      final String? result = await service.getString('key1');

      expect(result, equals('val1'));
    });

    test('getString returns null for missing key', () async {
      final RemoteConfig remoteConfig = RemoteConfig(
        config: <String, RemoteConfigValue>{},
        version: PublicConfigVersion(
          versionNumber: '1.0.0',
          updateTime: DateTime(2024),
        ),
      );

      when(
        mockEndpoint.getRemoteConfig(
          appVersion: anyNamed('appVersion'),
          platform: anyNamed('platform'),
        ),
      ).thenAnswer((_) async => remoteConfig);

      final ServerpodRemoteConfigService service =
          ServerpodRemoteConfigService(mockServerpod, mockDeviceInfo);
      final String? result = await service.getString('nonexistent');

      expect(result, isNull);
    });

    test('falls back to cached config on repeated errors', () async {
      when(
        mockEndpoint.getRemoteConfig(
          appVersion: anyNamed('appVersion'),
          platform: anyNamed('platform'),
        ),
      ).thenThrow(Exception('down'));

      final ServerpodRemoteConfigService service =
          ServerpodRemoteConfigService(mockServerpod, mockDeviceInfo);

      final Map<String, dynamic> first = await service.remoteConfig;
      final Map<String, dynamic> second = await service.remoteConfig;

      expect(first, equals(second));
      expect(first['is_maintenance'], equals(false));
    });
  });
}
