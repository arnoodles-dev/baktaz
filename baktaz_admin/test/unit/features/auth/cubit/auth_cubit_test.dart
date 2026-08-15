import 'package:baktaz_admin/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../../../utils/generated_mocks.mocks.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(AuthCubit, () {
    late MockIAuthRepository authRepository;
    late MockFailureHandler failureHandler;
    late AuthCubit authCubit;

    setUp(() {
      authRepository = MockIAuthRepository();
      failureHandler = MockFailureHandler();
      authCubit = AuthCubit(authRepository, failureHandler);

      // Register dummy values to prevent Mockito's MissingDummyValueError under randomized ordering.
      provideDummy(TaskEither<Failure, Account>.right(mockAccount));
      provideDummy(TaskEither<Failure, Unit>.right(unit));
    });

    tearDown(() async {
      await authCubit.close();
      reset(authRepository);
      reset(failureHandler);
    });

    group('initialize', () {
      blocTest<AuthCubit, AuthState>(
        'should emit unauthenticated state when not authenticated',
        build: () {
          when(authRepository.isAuthenticated).thenReturn(false);
          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.initialize(),
        expect: () => const <AuthState>[AuthState.initial(), AuthState.unauthenticated()],
        verify: (_) {
          verify(authRepository.isAuthenticated).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit unauthenticated state when authenticated but user fetch fails',
        build: () {
          when(authRepository.isAuthenticated).thenReturn(true);
          when(
            authRepository.getCurrentAccount(),
          ).thenReturn(TaskEither<Failure, Account>.left(const Failure.authentication('Authentication Failed')));

          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.initialize(),
        expect: () => const <AuthState>[AuthState.initial(), AuthState.unauthenticated()],
        verify: (_) {
          verify(authRepository.isAuthenticated).called(1);
          verify(authRepository.getCurrentAccount()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit authenticated state when user is successfully fetched',
        build: () {
          when(authRepository.isAuthenticated).thenReturn(true);
          when(authRepository.getCurrentAccount()).thenReturn(TaskEither<Failure, Account>.right(mockAccount));

          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.initialize(),
        expect: () => <AuthState>[const AuthState.initial(), AuthState.authenticated(account: mockAccount)],
        verify: (_) {
          verify(authRepository.isAuthenticated).called(1);
          verify(authRepository.getCurrentAccount()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should handle server error during initialization',
        build: () {
          when(authRepository.isAuthenticated).thenReturn(true);
          when(authRepository.getCurrentAccount()).thenReturn(
            TaskEither<Failure, Account>.left(const Failure.server(StatusCode.http500, 'Internal server error')),
          );
          when(failureHandler.handleFailure(any)).thenReturn(null);

          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.initialize(),
        expect: () => <AuthState>[const AuthState.initial(), const AuthState.unauthenticated()],
        verify: (_) {
          verify(authRepository.isAuthenticated).called(1);
          verify(authRepository.getCurrentAccount()).called(1);
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should handle unexpected exception during initialization',
        build: () {
          when(authRepository.isAuthenticated).thenThrow(Exception('Unexpected error'));

          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.initialize(),
        expect: () => <AuthState>[const AuthState.initial(), const AuthState.unauthenticated()],
        verify: (_) {
          verify(authRepository.isAuthenticated).called(1);
          verifyNever(authRepository.getCurrentAccount());
        },
      );
    });

    group('getUser', () {
      blocTest<AuthCubit, AuthState>(
        'should emit authenticated state when user is successfully fetched',
        build: () {
          when(authRepository.getCurrentAccount()).thenReturn(TaskEither<Failure, Account>.right(mockAccount));

          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.getUser(),
        expect: () => <AuthState>[const AuthState.loading(), AuthState.authenticated(account: mockAccount)],
        verify: (_) {
          verify(authRepository.getCurrentAccount()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit loading state and handle failure when user fetch returns unauthorized',
        build: () {
          when(
            authRepository.getCurrentAccount(),
          ).thenReturn(TaskEither<Failure, Account>.left(const Failure.server(StatusCode.http401, 'unauthorized')));
          when(failureHandler.handleFailure(any)).thenReturn(null);

          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.getUser(),
        expect: () => const <AuthState>[AuthState.loading()],
        verify: (_) {
          verify(authRepository.getCurrentAccount()).called(1);
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should handle unexpected exception during user fetch',
        build: () {
          final Exception exception = Exception('Unexpected error');
          when(authRepository.getCurrentAccount()).thenThrow(exception);
          when(failureHandler.handleException(any, any)).thenReturn(null);

          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.getUser(),
        expect: () => <AuthState>[const AuthState.loading()],
        verify: (_) {
          verify(authRepository.getCurrentAccount()).called(1);
          verify(failureHandler.handleException(any, any)).called(1);
        },
      );
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'should emit unauthenticated state when logout is successful',
        build: () {
          provideDummy(TaskEither<Failure, Unit>.right(unit));
          when(authRepository.logout()).thenReturn(TaskEither<Failure, Unit>.right(unit));

          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.logout(),
        expect: () => const <AuthState>[AuthState.loading(), AuthState.unauthenticated()],
        verify: (_) {
          verify(authRepository.logout()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit unauthenticated state and handle failure when logout fails',
        build: () {
          provideDummy(TaskEither<Failure, Unit>.left(Failure.unexpected(Exception('Unexpected error').toString())));
          when(
            authRepository.logout(),
          ).thenReturn(TaskEither<Failure, Unit>.left(Failure.unexpected(Exception('Unexpected error').toString())));
          when(failureHandler.handleFailure(any)).thenReturn(null);
          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.logout(),
        expect: () => <AuthState>[const AuthState.loading(), const AuthState.unauthenticated()],
        verify: (_) {
          verify(authRepository.logout()).called(1);
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit unauthenticated state and handle exception when logout throws exception',
        build: () {
          final Exception exception = Exception('Unexpected error');
          when(authRepository.logout()).thenThrow(exception);
          when(failureHandler.handleException(any, any)).thenReturn(null);

          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.logout(),
        expect: () => <AuthState>[const AuthState.loading(), const AuthState.unauthenticated()],
        verify: (_) {
          verify(authRepository.logout()).called(1);
          verify(failureHandler.handleException(any, any)).called(1);
        },
      );
    });

    group('authenticate', () {
      blocTest<AuthCubit, AuthState>(
        'should emit authenticated state when authentication is successful',
        build: () {
          when(authRepository.getCurrentAccount()).thenReturn(TaskEither<Failure, Account>.right(mockAccount));
          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.authenticate(),
        expect: () => <AuthState>[const AuthState.loading(), AuthState.authenticated(account: mockAccount)],
        verify: (_) {
          verify(authRepository.getCurrentAccount()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit unauthenticated state when authentication fails',
        build: () {
          when(
            authRepository.getCurrentAccount(),
          ).thenReturn(TaskEither<Failure, Account>.left(const Failure.server(StatusCode.http401, 'unauthorized')));
          when(failureHandler.handleFailure(any)).thenReturn(null);

          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.authenticate(),
        expect: () => <AuthState>[const AuthState.loading(), const AuthState.unauthenticated()],
        verify: (_) {
          verify(authRepository.getCurrentAccount()).called(1);
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit unauthenticated state when authentication throws exception',
        build: () {
          final Exception exception = Exception('Unexpected error');
          when(authRepository.getCurrentAccount()).thenThrow(exception);
          when(failureHandler.handleException(any, any)).thenReturn(null);

          return authCubit;
        },
        act: (AuthCubit cubit) => cubit.authenticate(),
        expect: () => <AuthState>[const AuthState.loading(), const AuthState.unauthenticated()],
        verify: (_) {
          verify(authRepository.getCurrentAccount()).called(1);
          verify(failureHandler.handleException(any, any)).called(1);
        },
      );
    });
  });
}
