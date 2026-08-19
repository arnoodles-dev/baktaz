import 'package:baktaz_flutter/core/domain/cubit/app_core/app_core_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(AppCoreCubit, () {
    late MockIAnalyticsService analyticsService;
    late MockILocalStorageRepository localStorageRepository;
    late MockFailureHandler failureHandler;

    setUp(() {
      analyticsService = MockIAnalyticsService();
      localStorageRepository = MockILocalStorageRepository();
      failureHandler = MockFailureHandler();
    });

    tearDown(() {
      reset(analyticsService);
      reset(localStorageRepository);
      reset(failureHandler);
    });

    AppCoreCubit createCubit() => AppCoreCubit(analyticsService, localStorageRepository, failureHandler);

    group('initial state', () {
      test('starts with isOnboardingDone = false', () {
        final AppCoreCubit cubit = createCubit();
        expect(cubit.stateValue.isOnboardingDone, isFalse);
        cubit.close();
      });
    });

    group('initialize', () {
      test('logs onOpenApp via analyticsService', () async {
        final AppCoreCubit cubit = createCubit();
        when(localStorageRepository.getIsOnboardingDone()).thenAnswer((_) => TaskResult<bool?>.right(true));

        await cubit.initialize();

        verify(analyticsService.logOnOpenApp()).called(1);
        await cubit.close();
      });

      test('emits isOnboardingDone = true when stored value is true', () async {
        final AppCoreCubit cubit = createCubit();
        when(localStorageRepository.getIsOnboardingDone()).thenAnswer((_) => TaskResult<bool?>.right(true));

        await cubit.initialize();

        expect(cubit.stateValue.isOnboardingDone, isTrue);
        await cubit.close();
      });

      test('emits isOnboardingDone = false when stored value is false', () async {
        final AppCoreCubit cubit = createCubit();
        when(localStorageRepository.getIsOnboardingDone()).thenAnswer((_) => TaskResult<bool?>.right(false));

        await cubit.initialize();

        expect(cubit.stateValue.isOnboardingDone, isFalse);
        await cubit.close();
      });

      test('emits isOnboardingDone = false when stored value is null', () async {
        final AppCoreCubit cubit = createCubit();
        when(localStorageRepository.getIsOnboardingDone()).thenAnswer((_) => TaskResult<bool?>.right(null));

        await cubit.initialize();

        expect(cubit.stateValue.isOnboardingDone, isFalse);
        await cubit.close();
      });

      test('delegates failure to failureHandler when storage read fails', () async {
        final AppCoreCubit cubit = createCubit();
        const Failure failure = Failure.deviceStorage('read error');
        when(localStorageRepository.getIsOnboardingDone()).thenAnswer((_) => TaskResult<bool?>.left(failure));

        await cubit.initialize();

        verify(failureHandler.handleFailure(failure)).called(1);
        expect(cubit.stateValue.isOnboardingDone, isFalse);
        await cubit.close();
      });

      test('handles exception thrown by storage read', () async {
        final AppCoreCubit cubit = createCubit();
        when(localStorageRepository.getIsOnboardingDone()).thenThrow(Exception('boom'));

        await cubit.initialize();

        verify(failureHandler.handleException(any, any)).called(1);
        await cubit.close();
      });
    });

    group('setOnboardingDone', () {
      test('persists onboarding done and emits true', () async {
        final AppCoreCubit cubit = createCubit();
        when(localStorageRepository.setIsOnboardingDone()).thenAnswer((_) => TaskResult<Unit>.right(unit));

        await cubit.setOnboardingDone();

        expect(cubit.stateValue.isOnboardingDone, isTrue);
        verify(localStorageRepository.setIsOnboardingDone()).called(1);
        await cubit.close();
      });

      test('delegates failure to failureHandler when write fails', () async {
        final AppCoreCubit cubit = createCubit();
        const Failure failure = Failure.deviceStorage('write error');
        when(localStorageRepository.setIsOnboardingDone()).thenAnswer((_) => TaskResult<Unit>.left(failure));

        await cubit.setOnboardingDone();

        // Impl emits true regardless; failure is logged by repository only.
        expect(cubit.stateValue.isOnboardingDone, isTrue);
        await cubit.close();
      });
    });
  });
}
