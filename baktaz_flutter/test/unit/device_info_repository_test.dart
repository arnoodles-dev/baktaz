import 'package:baktaz_flutter/core/data/repository/device_info_repository.dart';
import 'package:baktaz_flutter/core/domain/interface/i_device_info_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(DeviceInfoRepository, () {
    late MockPackageInfo packageInfo;
    late MockDeviceInfoPlugin deviceInfoPlugin;
    late MockTalker talker;
    late IDeviceInfoRepository repository;

    setUp(() {
      packageInfo = MockPackageInfo();
      deviceInfoPlugin = MockDeviceInfoPlugin();
      talker = MockTalker();
      repository = DeviceInfoRepository(packageInfo, deviceInfoPlugin, talker);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      reset(packageInfo);
      reset(deviceInfoPlugin);
      reset(talker);
    });

    group('getAppVersion', () {
      test('returns package version on success', () {
        when(packageInfo.version).thenReturn('1.2.3');

        final Result<String> result = repository.getAppVersion();

        expect(result, equals(right<Failure, String>('1.2.3')));
      });

      test('returns failure when exception thrown', () {
        when(packageInfo.version).thenThrow(Exception('version error'));

        final Result<String> result = repository.getAppVersion();

        expect(result.isLeft(), isTrue);
        verify(talker.handle(any, any)).called(1);
      });
    });

    group('getBuildNumber', () {
      test('returns package build number on success', () {
        when(packageInfo.buildNumber).thenReturn('42');

        final Result<String> result = repository.getBuildNumber();

        expect(result, equals(right<Failure, String>('42')));
      });

      test('returns failure when exception thrown', () {
        when(packageInfo.buildNumber).thenThrow(Exception('build error'));

        final Result<String> result = repository.getBuildNumber();

        expect(result.isLeft(), isTrue);
        verify(talker.handle(any, any)).called(1);
      });
    });

    group('getPhoneModel', () {
      test('returns Unknown on unsupported platform', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

        final Result<String> result = await repository.getPhoneModel().run();

        expect(result, equals(right<Failure, String>('Unknown')));
        verifyZeroInteractions(deviceInfoPlugin);
      });

      test('returns failure when Android device info throws', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        when(deviceInfoPlugin.androidInfo).thenThrow(Exception('device error'));

        final Result<String> result = await repository.getPhoneModel().run();

        expect(result.isLeft(), isTrue);
        verify(talker.handle(any, any)).called(1);
      });
    });

    group('getPhoneOSVersion', () {
      test('returns Unknown tuple on unsupported platform', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

        final Result<(String, String)> result = await repository.getPhoneOSVersion().run();

        expect(result, equals(const Right<Failure, (String, String)>(('Unknown', 'Unknown'))));
        verifyZeroInteractions(deviceInfoPlugin);
      });

      test('returns failure when Android OS version throws', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        when(deviceInfoPlugin.androidInfo).thenThrow(Exception('os version error'));

        final Result<(String, String)> result = await repository.getPhoneOSVersion().run();

        expect(result.isLeft(), isTrue);
        verify(talker.handle(any, any)).called(1);
      });
    });
  });
}
