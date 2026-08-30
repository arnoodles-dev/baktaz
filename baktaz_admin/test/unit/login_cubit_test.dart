import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_admin/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:baktaz_admin/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_test/bloc_signals_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(LoginCubit, () {
    late MockIAuthRepository authRepository;
    late MockILocalStorageRepository localStorageRepository;
    late MockFailureHandler failureHandler;
    late LoginCubit loginCubit;
    late String email;
    late String password;

    setUp(() async {
      authRepository = MockIAuthRepository();
      localStorageRepository = MockILocalStorageRepository();
      failureHandler = MockFailureHandler();
      email = 'admin@baktaz.com';
      password = 'password';

      // Register dummy values to prevent Mockito's MissingDummyValueError under randomized ordering.
      provideDummy(TaskEither<Failure, String?>.right(null));
      provideDummy(TaskEither<Failure, Unit>.right(unit));
      if (getIt.isRegistered<AuthCubit>()) {
        final dynamic _ = getIt.unregister<AuthCubit>();
      }
      getIt.registerFactory<AuthCubit>(MockAuthCubit.new);
    });

    tearDown(() async {
      if (getIt.isRegistered<AuthCubit>()) {
        final dynamic _ = getIt.unregister<AuthCubit>();
      }
      reset(localStorageRepository);
      reset(authRepository);
      reset(failureHandler);
    });

    group('initialize', () {
      blocSignalTest<LoginCubit, LoginState>(
        'should emit state with null email when no previous login exists',
        build: () {
          provideDummy(TaskEither<Failure, String?>.right(null));
          when(localStorageRepository.getLastLoggedInUsername()).thenReturn(TaskEither<Failure, String?>.right(null));

          return LoginCubit(authRepository, localStorageRepository, failureHandler);
        },
        act: (LoginCubit cubit) => cubit.initialize(),
        expect: () => <LoginState>[LoginState.initial().copyWith(isLoading: false)],
        verify: (_) {
          verify(localStorageRepository.getLastLoggedInUsername()).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'should emit state with saved email when previous login exists',
        build: () {
          provideDummy(TaskEither<Failure, String?>.right(email));
          when(localStorageRepository.getLastLoggedInUsername()).thenReturn(TaskEither<Failure, String?>.right(email));

          return LoginCubit(authRepository, localStorageRepository, failureHandler);
        },
        act: (LoginCubit cubit) => cubit.initialize(),
        expect: () => <LoginState>[
          LoginState.initial().copyWith(email: email),
          LoginState.initial().copyWith(isLoading: false, email: email),
        ],
        verify: (_) {
          verify(localStorageRepository.getLastLoggedInUsername()).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'should handle storage access failure during initialization',
        build: () {
          provideDummy(TaskEither<Failure, String?>.right(null));
          when(localStorageRepository.getLastLoggedInUsername())
              .thenReturn(TaskEither<Failure, String?>.left(const Failure.deviceInfo('Storage access failed')));

          return LoginCubit(authRepository, localStorageRepository, failureHandler);
        },
        act: (LoginCubit cubit) => cubit.initialize(),
        expect: () => <LoginState>[LoginState.initial().copyWith(isLoading: false)],
        verify: (_) {
          verify(localStorageRepository.getLastLoggedInUsername()).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'should handle unexpected exception during initialization',
        build: () {
          provideDummy(TaskEither<Failure, String?>.right(email));
          when(localStorageRepository.getLastLoggedInUsername()).thenThrow(Exception('Unexpected error'));

          return LoginCubit(authRepository, localStorageRepository, failureHandler);
        },
        act: (LoginCubit cubit) => cubit.initialize(),
        expect: () => <LoginState>[LoginState.initial().copyWith(isLoading: false)],
        verify: (_) {
          verify(localStorageRepository.getLastLoggedInUsername()).called(1);
        },
      );
    });

    group('onEmailChanged', () {
      setUp(() {
        provideDummy(TaskEither<Failure, String?>.right(null));
        when(localStorageRepository.getLastLoggedInUsername()).thenReturn(TaskEither<Failure, String?>.right(null));
        loginCubit = LoginCubit(authRepository, localStorageRepository, failureHandler);
      });

      blocSignalTest<LoginCubit, LoginState>(
        'should emit state with updated email',
        build: () => loginCubit,
        act: (LoginCubit cubit) => cubit.onEmailChanged('test_$email'),
        expect: () => <LoginState>[LoginState.initial().copyWith(isLoading: false, email: 'test_$email')],
      );

      blocSignalTest<LoginCubit, LoginState>(
        'should handle empty email input',
        build: () => loginCubit,
        act: (LoginCubit cubit) => cubit.onEmailChanged(''),
        expect: () => <LoginState>[LoginState.initial().copyWith(isLoading: false, email: '')],
      );

      blocSignalTest<LoginCubit, LoginState>(
        'should handle special characters in email',
        build: () => loginCubit,
        act: (LoginCubit cubit) => cubit.onEmailChanged('user@domain.com'),
        expect: () => <LoginState>[LoginState.initial().copyWith(isLoading: false, email: 'user@domain.com')],
      );
    });

    group('login', () {
      blocSignalTest<LoginCubit, LoginState>(
        'should emit loading and success states when login is successful',
        build: () {
          provideDummy(TaskEither<Failure, String?>.right(null));
          when(localStorageRepository.getLastLoggedInUsername()).thenReturn(TaskEither<Failure, String?>.right(null));

          when(
            authRepository.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
            ),
          ).thenAnswer((Invocation invocation) async {
            final void Function(AuthSuccess?) onAuthenticated =
                invocation.namedArguments[#onAuthenticated] as void Function(AuthSuccess?);
            onAuthenticated(
              AuthSuccess(
                authStrategy: 'email',
                token: 'token',
                authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
                scopeNames: <String>{},
              ),
            );
            return;
          });
          when(failureHandler.handleFailure(any)).thenReturn(null);
          return LoginCubit(authRepository, localStorageRepository, failureHandler);
        },
        act: (LoginCubit cubit) => cubit.login(email, password),
        expect: () => <LoginState>[
          LoginState.initial().copyWith(email: email),
          LoginState(isLoading: false, email: email),
        ],
        verify: (_) {
          verify(
            authRepository.login(
              email: EmailAddress(email),
              password: Password(password),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
            ),
          ).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'should emit loading and failure states when login fails',
        build: () {
          provideDummy(TaskEither<Failure, String?>.right(null));
          when(localStorageRepository.getLastLoggedInUsername()).thenReturn(TaskEither<Failure, String?>.right(null));

          const Failure failure = Failure.server(StatusCode.http500, 'INTERNAL SERVER ERROR');
          when(
            authRepository.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
            ),
          ).thenAnswer((Invocation invocation) async {
            final void Function(Failure) onError = invocation.namedArguments[#onError] as void Function(Failure);
            onError(failure);
            return;
          });
          when(failureHandler.handleFailure(any)).thenReturn(null);
          return LoginCubit(authRepository, localStorageRepository, failureHandler);
        },
        act: (LoginCubit cubit) => cubit.login(email, password),
        expect: () => <LoginState>[
          LoginState.initial().copyWith(email: email),
          LoginState(isLoading: false, email: email),
        ],
        verify: (_) {
          verify(failureHandler.handleFailure(const Failure.server(StatusCode.http500, 'INTERNAL SERVER ERROR')))
              .called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'should handle unexpected error during login',
        build: () {
          provideDummy(TaskEither<Failure, String?>.right(null));
          when(localStorageRepository.getLastLoggedInUsername()).thenReturn(TaskEither<Failure, String?>.right(null));

          when(
            authRepository.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
            ),
          ).thenThrow(Exception('Unexpected error'));
          when(failureHandler.handleFailure(any)).thenReturn(null);
          return LoginCubit(authRepository, localStorageRepository, failureHandler);
        },
        act: (LoginCubit cubit) => cubit.login(email, password),
        expect: () => <LoginState>[
          LoginState.initial().copyWith(email: email),
          LoginState(isLoading: false, email: email),
        ],
        verify: (_) {
          verify(
            authRepository.login(
              email: EmailAddress(email),
              password: Password(password),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
            ),
          ).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'should handle validation error for invalid password',
        build: () {
          provideDummy(TaskEither<Failure, String?>.right(null));
          when(localStorageRepository.getLastLoggedInUsername()).thenReturn(TaskEither<Failure, String?>.right(null));
          when(failureHandler.handleFailure(any)).thenReturn(null);
          return LoginCubit(authRepository, localStorageRepository, failureHandler);
        },
        act: (LoginCubit cubit) => cubit.login(email, 'pass'),
        expect: () => <LoginState>[
          LoginState.initial().copyWith(email: email),
          LoginState(isLoading: false, email: email),
        ],
      );

      blocSignalTest<LoginCubit, LoginState>(
        'should handle authentication failure',
        build: () {
          provideDummy(TaskEither<Failure, String?>.right(null));
          when(localStorageRepository.getLastLoggedInUsername()).thenReturn(TaskEither<Failure, String?>.right(null));
          const Failure authFailure = Failure.authentication('Invalid credentials');
          when(
            authRepository.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
            ),
          ).thenAnswer((Invocation invocation) async {
            final void Function(Failure) onError = invocation.namedArguments[#onError] as void Function(Failure);
            onError(authFailure);
            return;
          });
          when(failureHandler.handleFailure(any)).thenReturn(null);
          return LoginCubit(authRepository, localStorageRepository, failureHandler);
        },
        act: (LoginCubit cubit) => cubit.login(email, password),
        expect: () => <LoginState>[
          LoginState.initial().copyWith(email: email),
          LoginState(isLoading: false, email: email),
        ],
        verify: (_) {
          verify(failureHandler.handleFailure(const Failure.authentication('Invalid credentials'))).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'should handle network timeout during login',
        build: () {
          provideDummy(TaskEither<Failure, String?>.right(null));
          when(localStorageRepository.getLastLoggedInUsername()).thenReturn(TaskEither<Failure, String?>.right(null));

          when(
            authRepository.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
            ),
          ).thenThrow(Exception('Connection timeout'));
          when(failureHandler.handleFailure(any)).thenReturn(null);
          return LoginCubit(authRepository, localStorageRepository, failureHandler);
        },
        act: (LoginCubit cubit) => cubit.login(email, password),
        expect: () => <LoginState>[
          LoginState.initial().copyWith(email: email),
          LoginState(isLoading: false, email: email),
        ],
        verify: (_) {
          verify(failureHandler.handleException(any, any)).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'should handle null authInfo in onAuthenticated callback',
        build: () {
          provideDummy(TaskEither<Failure, String?>.right(null));
          when(localStorageRepository.getLastLoggedInUsername()).thenReturn(TaskEither<Failure, String?>.right(null));

          when(
            authRepository.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
            ),
          ).thenAnswer((Invocation invocation) async {
            final void Function(AuthSuccess?) onAuthenticated =
                invocation.namedArguments[#onAuthenticated] as void Function(AuthSuccess?);
            onAuthenticated(null);
            return;
          });
          when(failureHandler.handleFailure(any)).thenReturn(null);
          return LoginCubit(authRepository, localStorageRepository, failureHandler);
        },
        act: (LoginCubit cubit) => cubit.login(email, password),
        expect: () => <LoginState>[
          LoginState.initial().copyWith(email: email),
          LoginState(isLoading: false, email: email),
        ],
        verify: (_) {
          verify(failureHandler.handleFailure(const Failure.authentication('Authentication failed'))).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'should trigger AuthCubit authenticate when onAuthenticated receives AuthSuccess',
        build: () {
          final MockAuthCubit mockAuthCubit = MockAuthCubit();
          when(mockAuthCubit.authenticate()).thenAnswer((_) async {});
          if (getIt.isRegistered<AuthCubit>()) {
            final dynamic _ = getIt.unregister<AuthCubit>();
          }
          getIt.registerSingleton<AuthCubit>(mockAuthCubit);

          provideDummy(TaskEither<Failure, String?>.right(null));
          when(localStorageRepository.getLastLoggedInUsername()).thenReturn(TaskEither<Failure, String?>.right(null));

          when(
            authRepository.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
            ),
          ).thenAnswer((Invocation invocation) async {
            final void Function(AuthSuccess?) onAuthenticated =
                invocation.namedArguments[#onAuthenticated] as void Function(AuthSuccess?);
            onAuthenticated(
              AuthSuccess(
                authStrategy: 'email',
                token: 'token',
                authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
                scopeNames: const <String>{},
              ),
            );
          });
          return LoginCubit(authRepository, localStorageRepository, failureHandler);
        },
        act: (LoginCubit cubit) => cubit.login(email, password),
        expect: () => <LoginState>[
          LoginState.initial().copyWith(email: email),
          LoginState(isLoading: false, email: email),
        ],
        verify: (_) {
          if (getIt.isRegistered<AuthCubit>()) {
            verify(getIt<AuthCubit>().authenticate()).called(1);
            final dynamic _ = getIt.unregister<AuthCubit>();
          }
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'should handle exception in AuthCubit.authenticate during onAuthenticated',
        build: () {
          final MockAuthCubit mockAuthCubit = MockAuthCubit();
          when(mockAuthCubit.authenticate()).thenThrow(Exception('Auth error'));
          if (getIt.isRegistered<AuthCubit>()) {
            final dynamic _ = getIt.unregister<AuthCubit>();
          }
          getIt.registerSingleton<AuthCubit>(mockAuthCubit);

          provideDummy(TaskEither<Failure, String?>.right(null));
          when(localStorageRepository.getLastLoggedInUsername()).thenReturn(TaskEither<Failure, String?>.right(null));

          when(
            authRepository.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
            ),
          ).thenAnswer((Invocation invocation) async {
            final void Function(AuthSuccess?) onAuthenticated =
                invocation.namedArguments[#onAuthenticated] as void Function(AuthSuccess?);
            onAuthenticated(
              AuthSuccess(
                authStrategy: 'email',
                token: 'token',
                authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
                scopeNames: const <String>{},
              ),
            );
          });
          return LoginCubit(authRepository, localStorageRepository, failureHandler);
        },
        act: (LoginCubit cubit) => cubit.login(email, password),
        expect: () => <LoginState>[
          LoginState.initial().copyWith(email: email),
          LoginState(isLoading: false, email: email),
        ],
        verify: (_) {
          if (getIt.isRegistered<AuthCubit>()) {
            final dynamic _ = getIt.unregister<AuthCubit>();
          }
        },
      );
    });
  });
}
