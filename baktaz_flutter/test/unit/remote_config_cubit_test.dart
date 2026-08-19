import 'package:baktaz_flutter/core/data/dto/remote_app_config.dto.dart';
import 'package:baktaz_flutter/core/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(RemoteConfigCubit, () {
    late MockIRemoteConfigService remoteConfigService;
    late MockIDeviceInfoRepository deviceRepository;
    late MockFailureHandler failureHandler;

    setUp(() {
      remoteConfigService = MockIRemoteConfigService();
      deviceRepository = MockIDeviceInfoRepository();
      failureHandler = MockFailureHandler();
    });

    tearDown(() {
      reset(remoteConfigService);
      reset(deviceRepository);
      reset(failureHandler);
    });

    RemoteConfigCubit createCubit() => RemoteConfigCubit(remoteConfigService, deviceRepository, failureHandler);

    Future<RemoteConfigCubit> createInitializedCubit() async {
      when(remoteConfigService.initializeConfig(any))
          .thenAnswer((_) async => const Stream<dynamic>.empty().listen(null));
      final RemoteConfigCubit cubit = createCubit();
      await cubit.initialize();
      return cubit;
    }

    group('initialize', () {
      test('starts with empty map as initial state', () async {
        final RemoteConfigCubit cubit = await createInitializedCubit();
        expect(cubit.stateValue, equals(<String, dynamic>{}));
        await cubit.close();
      });

      test('subscribes to remote config updates on initialize', () async {
        final RemoteConfigCubit cubit = await createInitializedCubit();

        verify(remoteConfigService.initializeConfig(any)).called(1);
        await cubit.close();
      });

      test('emits remote config values when remoteConfig getter is called', () async {
        const Map<String, dynamic> config = <String, dynamic>{'is_maintenance': 'true', 'key': 'value'};
        when(remoteConfigService.remoteConfig).thenAnswer((_) async => config);

        final RemoteConfigCubit cubit = await createInitializedCubit();
        await cubit.remoteConfig;

        expect(cubit.stateValue, equals(config));
        await cubit.close();
      });

      test('emits fallback config when remote config throws', () async {
        when(remoteConfigService.remoteConfig).thenThrow(Exception('remote error'));

        final RemoteConfigCubit cubit = await createInitializedCubit();
        await cubit.remoteConfig;

        expect(cubit.stateValue, equals(RemoteAppConfigDTO.fallback().toJson()));
        await cubit.close();
      });
    });

    group('isMaintenance', () {
      test('returns false when state is empty', () async {
        final RemoteConfigCubit cubit = await createInitializedCubit();
        expect(cubit.isMaintenance, isFalse);
        await cubit.close();
      });

      test('returns true when is_maintenance is "true"', () async {
        when(remoteConfigService.remoteConfig).thenAnswer((_) async => <String, dynamic>{'is_maintenance': 'true'});

        final RemoteConfigCubit cubit = await createInitializedCubit();
        await cubit.remoteConfig;

        expect(cubit.isMaintenance, isTrue);
        await cubit.close();
      });

      test('returns false when is_maintenance is "false"', () async {
        when(remoteConfigService.remoteConfig).thenAnswer((_) async => <String, dynamic>{'is_maintenance': 'false'});

        final RemoteConfigCubit cubit = await createInitializedCubit();
        await cubit.remoteConfig;

        expect(cubit.isMaintenance, isFalse);
        await cubit.close();
      });

      test('returns false when is_maintenance key is missing', () async {
        when(remoteConfigService.remoteConfig).thenAnswer((_) async => <String, dynamic>{'other_key': 'value'});

        final RemoteConfigCubit cubit = await createInitializedCubit();
        await cubit.remoteConfig;

        expect(cubit.isMaintenance, isFalse);
        await cubit.close();
      });
    });

    group('isForceUpdate', () {
      setUp(() {
        when(deviceRepository.getAppVersion()).thenReturn(right<Failure, String>('1.0.0'));
      });

      test('returns false when state is empty', () async {
        final RemoteConfigCubit cubit = await createInitializedCubit();
        expect(cubit.isForceUpdate, isFalse);
        await cubit.close();
      });

      test('returns false when min_supported_version <= current version', () async {
        when(remoteConfigService.remoteConfig)
            .thenAnswer((_) async => <String, dynamic>{'min_supported_version': '1.0.0'});

        final RemoteConfigCubit cubit = await createInitializedCubit();
        await cubit.remoteConfig;

        expect(cubit.isForceUpdate, isFalse);
        await cubit.close();
      });

      test('returns true when min_supported_version > current version', () async {
        when(remoteConfigService.remoteConfig)
            .thenAnswer((_) async => <String, dynamic>{'min_supported_version': '2.0.0'});

        final RemoteConfigCubit cubit = await createInitializedCubit();
        await cubit.remoteConfig;

        expect(cubit.isForceUpdate, isTrue);
        await cubit.close();
      });

      test('handles exception in min_supported_version', () async {
        when(remoteConfigService.remoteConfig)
            .thenAnswer((_) async => <String, dynamic>{'min_supported_version': 'invalid'});

        final RemoteConfigCubit cubit = await createInitializedCubit();
        await cubit.remoteConfig;
        final bool result = cubit.isForceUpdate;

        expect(result, isFalse);
        await cubit.close();
      });

      test('delegates failure to failureHandler when app version read fails', () async {
        when(deviceRepository.getAppVersion())
            .thenReturn(const Left<Failure, String>(Failure.deviceInfo('version error')));
        when(remoteConfigService.remoteConfig)
            .thenAnswer((_) async => <String, dynamic>{'min_supported_version': '1.0.0'});

        final RemoteConfigCubit cubit = await createInitializedCubit();
        await cubit.remoteConfig;

        final bool result = cubit.isForceUpdate;
        expect(result, isFalse);
        verify(failureHandler.handleFailure(any)).called(1);
        await cubit.close();
      });
    });

    group('storeLink', () {
      test('returns null when state is empty', () async {
        final RemoteConfigCubit cubit = await createInitializedCubit();
        expect(cubit.storeLink, isNull);
        await cubit.close();
      });

      test('returns android_store_url on Android (test host default platform)', () async {
        when(remoteConfigService.remoteConfig).thenAnswer(
          (_) async => <String, dynamic>{
            'android_store_url': 'https://play.google.com/app',
            'ios_store_url': 'https://apps.apple.com/app',
          },
        );

        final RemoteConfigCubit cubit = await createInitializedCubit();
        await cubit.remoteConfig;

        // defaultTargetPlatform in tests resolves to Android → android URL
        expect(cubit.storeLink, equals('https://play.google.com/app'));
        await cubit.close();
      });

      test('returns fallback android store url when remote config throws', () async {
        when(remoteConfigService.remoteConfig).thenThrow(Exception('store error'));

        final RemoteConfigCubit cubit = await createInitializedCubit();
        await cubit.remoteConfig;

        expect(cubit.storeLink, equals('https://play.google.com/'));
        await cubit.close();
      });
    });
  });
}
