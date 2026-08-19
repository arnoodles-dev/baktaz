import 'package:baktaz_flutter/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_test/bloc_signals_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../fixtures/client_fixtures.dart';
import '../utils/generated_mocks.mocks.dart';

void main() {
  group(AuthCubit, () {
    late MockIAuthRepository authRepository;
    late MockICrashlyticsService crashlyticsService;
    late MockFailureHandler failureHandler;
    late AuthCubit authCubit;

    setUp(() {
      authRepository = MockIAuthRepository();
      crashlyticsService = MockICrashlyticsService();
      failureHandler = MockFailureHandler();
      authCubit = AuthCubit(authRepository, crashlyticsService, failureHandler);

      provideDummy<TaskResult<Unit>>(TaskResult<Unit>.right(unit));
    });

    tearDown(() async {
      await authCubit.close();
      reset(authRepository);
      reset(crashlyticsService);
      reset(failureHandler);
    });

    group('initialize', () {
      blocSignalTest<AuthCubit, AuthState>(
        'should emit authenticated state when onboarding is done and valid authInfo exists',
        build: () {
          when(authRepository.authInfo).thenReturn(mockAuthSuccess);
          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.initialize(),
        expect: () => <AuthState>[AuthState.authenticated(authInfo: mockAuthSuccess)],
        verify: (_) {
          verify(authRepository.authInfo).called(1);
          verify(crashlyticsService.setUserId(mockAuthSuccess.authUserId.uuid)).called(1);
        },
      );

      blocSignalTest<AuthCubit, AuthState>(
        'should emit unauthenticated state when authInfo is null or token is expired',
        build: () {
          when(authRepository.authInfo).thenReturn(null);
          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.initialize(),
        expect: () => const <AuthState>[AuthState.unauthenticated()],
        verify: (_) {
          verify(authRepository.authInfo).called(1);
          verifyNever(crashlyticsService.setUserId(any));
        },
      );

      blocSignalTest<AuthCubit, AuthState>(
        'should emit unauthenticated state when onboarding is not done',
        build: () => authCubit,
        act: (AuthCubit cubit) => cubit.initialize(isOnboardingDone: false),
        expect: () => const <AuthState>[AuthState.unauthenticated()],
        verify: (_) {
          verifyNever(authRepository.authInfo);
        },
      );

      blocSignalTest<AuthCubit, AuthState>(
        'should handle exception during initialization',
        build: () {
          final Exception exception = Exception('Initialization failed');
          when(authRepository.authInfo).thenThrow(exception);
          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.initialize(),
        expect: () => const <AuthState>[],
        verify: (_) {
          verify(failureHandler.handleException(any, any)).called(1);
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );
    });

    group('authenticate', () {
      blocSignalTest<AuthCubit, AuthState>(
        'should set crashlytics user ID and emit authenticated state',
        build: () => authCubit,
        act: (AuthCubit cubit) => cubit.authenticate(mockAuthSuccess),
        expect: () => <AuthState>[AuthState.authenticated(authInfo: mockAuthSuccess)],
        verify: (_) {
          verify(crashlyticsService.setUserId(mockAuthSuccess.authUserId.uuid)).called(1);
        },
      );

      blocSignalTest<AuthCubit, AuthState>(
        'should handle exception during authentication',
        build: () {
          when(crashlyticsService.setUserId(any)).thenThrow(Exception('Crashlytics error'));
          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.authenticate(mockAuthSuccess),
        expect: () => const <AuthState>[],
        verify: (_) {
          verify(failureHandler.handleException(any, any)).called(1);
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );
    });

    group('terminateSession', () {
      blocSignalTest<AuthCubit, AuthState>(
        'should emit unauthenticated state when logout succeeds',
        build: () {
          when(authRepository.logout()).thenReturn(TaskResult<Unit>.right(unit));
          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.terminateSession(),
        expect: () => const <AuthState>[AuthState.unauthenticated()],
        verify: (_) {
          verify(authRepository.logout()).called(1);
        },
      );

      blocSignalTest<AuthCubit, AuthState>(
        'should handle failure when logout fails',
        build: () {
          const Failure failure = Failure.authentication('Logout failed');
          when(authRepository.logout()).thenReturn(TaskResult<Unit>.left(failure));
          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.terminateSession(),
        expect: () => const <AuthState>[],
        verify: (_) {
          verify(authRepository.logout()).called(1);
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );

      blocSignalTest<AuthCubit, AuthState>(
        'should not execute logout when isLogout is false',
        build: () => authCubit,
        act: (AuthCubit cubit) => cubit.terminateSession(isLogout: false),
        expect: () => const <AuthState>[],
        verify: (_) {
          verifyNever(authRepository.logout());
        },
      );

      blocSignalTest<AuthCubit, AuthState>(
        'should handle exception during session termination',
        build: () {
          final Exception exception = Exception('Network error during terminate');
          when(authRepository.logout()).thenThrow(exception);
          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.terminateSession(),
        expect: () => const <AuthState>[],
        verify: (_) {
          verify(failureHandler.handleException(any, any)).called(1);
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );
    });
  });
}
