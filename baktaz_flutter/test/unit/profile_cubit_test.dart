import 'package:baktaz_client/baktaz_client.dart' as sp;
import 'package:baktaz_flutter/features/account/domain/cubit/profile/profile_cubit.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(ProfileCubit, () {
    late MockIAccountRepository accountRepository;
    late MockIDeviceInfoRepository deviceRepository;
    late MockFailureHandler failureHandler;
    late ProfileCubit cubit;

    setUp(() {
      accountRepository = MockIAccountRepository();
      deviceRepository = MockIDeviceInfoRepository();
      failureHandler = MockFailureHandler();
      cubit = ProfileCubit(accountRepository, deviceRepository, failureHandler);
    });

    tearDown(() {
      cubit.close();
      reset(accountRepository);
      reset(deviceRepository);
      reset(failureHandler);
    });

    final Profile testProfile = Profile(fullName: ValueName('John Doe'), gender: sp.Gender.male);

    group('initialize', () {
      test('starts with loading query status', () {
        expect(cubit.stateValue.queryStatus, equals(const QueryStatus.loading()));
      });

      test('emits appVersion and buildNumber on success', () async {
        when(deviceRepository.getAppVersion()).thenReturn(right<Failure, String>('1.0.0'));
        when(deviceRepository.getBuildNumber()).thenReturn(right<Failure, String>('1'));
        when(accountRepository.getProfile()).thenAnswer((_) => TaskResult<Profile>.right(testProfile));
        await cubit.initialize();

        expect(cubit.stateValue.appVersion, equals('1.0.0'));
        expect(cubit.stateValue.buildNumber, equals('1'));
        expect(cubit.stateValue.queryStatus, equals(const QueryStatus.done()));
      });

      test('emits profile on success', () async {
        when(deviceRepository.getAppVersion()).thenReturn(right<Failure, String>('1.0.0'));
        when(deviceRepository.getBuildNumber()).thenReturn(right<Failure, String>('1'));
        when(accountRepository.getProfile()).thenAnswer((_) => TaskResult<Profile>.right(testProfile));

        await cubit.initialize();

        expect(cubit.stateValue.profile, equals(testProfile));
        verify(accountRepository.getProfile()).called(1);
      });

      test('handles buildNumber failure and delegates to failureHandler', () async {
        when(deviceRepository.getAppVersion()).thenReturn(right<Failure, String>('1.0.0'));
        when(deviceRepository.getBuildNumber()).thenReturn(const Left<Failure, String>(Failure.deviceInfo('error')));

        await cubit.initialize();

        verify(failureHandler.handleFailure(any)).called(1);
      });

      test('handles appVersion failure and delegates to failureHandler', () async {
        when(deviceRepository.getAppVersion()).thenReturn(const Left<Failure, String>(Failure.deviceInfo('error')));
        when(deviceRepository.getBuildNumber()).thenReturn(right<Failure, String>('1'));

        await cubit.initialize();

        verify(failureHandler.handleFailure(any)).called(1);
      });

      test('handles profile fetch failure and delegates to failureHandler', () async {
        when(deviceRepository.getAppVersion()).thenReturn(right<Failure, String>('1.0.0'));
        when(deviceRepository.getBuildNumber()).thenReturn(right<Failure, String>('1'));
        when(accountRepository.getProfile())
            .thenAnswer((_) => TaskResult<Profile>.left(const Failure.deviceStorage('profile error')));

        await cubit.initialize();

        verify(failureHandler.handleFailure(any)).called(1);
      });

      test('handles exception thrown by deviceRepository', () async {
        when(deviceRepository.getAppVersion()).thenThrow(Exception('device error'));

        await cubit.initialize();

        verify(failureHandler.handleException(any, any)).called(1);
      });
    });
  });
}
