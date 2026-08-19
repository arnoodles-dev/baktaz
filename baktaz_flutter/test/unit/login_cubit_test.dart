import 'package:baktaz_flutter/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/entity/enum/login_provider.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_test/bloc_signals_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../fixtures/client_fixtures.dart';
import '../utils/generated_mocks.mocks.dart';

void main() {
  group(LoginCubit, () {
    late MockIAuthRepository authRepository;
    late MockIAnalyticsService analyticsService;
    late MockFailureHandler failureHandler;
    late LoginCubit loginCubit;

    setUp(() {
      authRepository = MockIAuthRepository();
      analyticsService = MockIAnalyticsService();
      failureHandler = MockFailureHandler();
      loginCubit = LoginCubit(authRepository, analyticsService, failureHandler);
    });

    tearDown(() async {
      await loginCubit.close();
      reset(authRepository);
      reset(analyticsService);
      reset(failureHandler);
    });

    group('loginWithProvider', () {
      blocSignalTest<LoginCubit, LoginState>(
        'emits success when auth returns valid authInfo',
        build: () {
          when(
            authRepository.loginWithProvider(
              provider: anyNamed('provider'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
              mobileNumber: anyNamed('mobileNumber'),
            ),
          ).thenAnswer((Invocation invocation) async {
            final void Function(AuthSuccess?) onAuthenticated =
                invocation.namedArguments[#onAuthenticated] as void Function(AuthSuccess?);
            onAuthenticated(mockAuthSuccess);
          });
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.loginWithProvider(LoginProvider.google),
        expect: () => <LoginState>[const LoginState.idle(isLoading: true), LoginState.success(mockAuthSuccess)],
        verify: (_) {
          verify(analyticsService.logLogin(LoginProvider.google.name)).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'emits registrationRequired when auth returns null authInfo',
        build: () {
          when(
            authRepository.loginWithProvider(
              provider: anyNamed('provider'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
              mobileNumber: anyNamed('mobileNumber'),
            ),
          ).thenAnswer((Invocation invocation) async {
            final void Function(AuthSuccess?) onAuthenticated =
                invocation.namedArguments[#onAuthenticated] as void Function(AuthSuccess?);
            onAuthenticated(null);
          });
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.loginWithProvider(LoginProvider.google),
        expect: () => <LoginState>[const LoginState.idle(isLoading: true), const LoginState.registrationRequired()],
      );

      blocSignalTest<LoginCubit, LoginState>(
        'emits failed then idle when onError is called',
        build: () {
          when(
            authRepository.loginWithProvider(
              provider: anyNamed('provider'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
              mobileNumber: anyNamed('mobileNumber'),
            ),
          ).thenAnswer((Invocation invocation) async {
            final void Function(Failure) onError = invocation.namedArguments[#onError] as void Function(Failure);
            onError(const Failure.authentication('Google sign-in failed'));
          });
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.loginWithProvider(LoginProvider.google),
        expect: () => <LoginState>[
          const LoginState.idle(isLoading: true),
          const LoginState.failed(Failure.authentication('Google sign-in failed')),
          const LoginState.idle(),
        ],
        verify: (_) {
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'calls handleException on onException',
        build: () {
          when(
            authRepository.loginWithProvider(
              provider: anyNamed('provider'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
              mobileNumber: anyNamed('mobileNumber'),
            ),
          ).thenThrow(Exception('unexpected'));
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.loginWithProvider(LoginProvider.facebook),
        expect: () => <LoginState>[const LoginState.idle(isLoading: true), const LoginState.idle()],
        verify: (_) {
          verify(failureHandler.handleException(any, any)).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'handles facebook provider successfully',
        build: () {
          when(
            authRepository.loginWithProvider(
              provider: anyNamed('provider'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
              mobileNumber: anyNamed('mobileNumber'),
            ),
          ).thenAnswer((Invocation invocation) async {
            final void Function(AuthSuccess?) onAuthenticated =
                invocation.namedArguments[#onAuthenticated] as void Function(AuthSuccess?);
            onAuthenticated(mockAuthSuccess);
          });
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.loginWithProvider(LoginProvider.facebook),
        expect: () => <LoginState>[const LoginState.idle(isLoading: true), LoginState.success(mockAuthSuccess)],
        verify: (_) {
          verify(analyticsService.logLogin(LoginProvider.facebook.name)).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'handles mobile provider with valid mobile number',
        build: () {
          when(
            authRepository.loginWithProvider(
              provider: anyNamed('provider'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
              mobileNumber: anyNamed('mobileNumber'),
            ),
          ).thenAnswer((Invocation invocation) async {
            final void Function(AuthSuccess?) onAuthenticated =
                invocation.namedArguments[#onAuthenticated] as void Function(AuthSuccess?);
            onAuthenticated(mockAuthSuccess);
          });
          return loginCubit;
        },
        act: (LoginCubit cubit) =>
            cubit.loginWithProvider(LoginProvider.mobile, mobileNumber: MobileNumber('+1234567890')),
        expect: () => <LoginState>[const LoginState.idle(isLoading: true), LoginState.success(mockAuthSuccess)],
        verify: (_) {
          verify(analyticsService.logLogin(LoginProvider.mobile.name)).called(1);
        },
      );
    });

    group('loginWithMobile', () {
      blocSignalTest<LoginCubit, LoginState>(
        'delegates to authRepository.loginWithProvider with mobile',
        build: () {
          when(
            authRepository.loginWithProvider(
              provider: anyNamed('provider'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
              mobileNumber: anyNamed('mobileNumber'),
            ),
          ).thenAnswer((Invocation invocation) async {
            final void Function(AuthSuccess?) onAuthenticated =
                invocation.namedArguments[#onAuthenticated] as void Function(AuthSuccess?);
            onAuthenticated(mockAuthSuccess);
          });
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.loginWithMobile('1', '234567890'),
        expect: () => <LoginState>[LoginState.success(mockAuthSuccess)],
        verify: (_) {
          verify(
            authRepository.loginWithProvider(
              provider: LoginProvider.mobile,
              mobileNumber: anyNamed('mobileNumber'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
            ),
          ).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'emits failed then idle when mobile login has error',
        build: () {
          when(
            authRepository.loginWithProvider(
              provider: anyNamed('provider'),
              onAuthenticated: anyNamed('onAuthenticated'),
              onError: anyNamed('onError'),
              mobileNumber: anyNamed('mobileNumber'),
            ),
          ).thenAnswer((Invocation invocation) async {
            final void Function(Failure) onError = invocation.namedArguments[#onError] as void Function(Failure);
            onError(const Failure.authentication('Invalid number'));
          });
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.loginWithMobile('1', '000'),
        expect: () => <LoginState>[
          const LoginState.failed(Failure.authentication('Invalid number')),
          const LoginState.idle(),
        ],
        verify: (_) {
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );
    });
  });
}
