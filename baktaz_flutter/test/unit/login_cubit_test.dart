import 'dart:async';

import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/entity/enum/login_provider.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:bloc_signals_test/bloc_signals_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
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

      provideDummy<TaskResult<Unit>>(TaskResult<Unit>.right(unit));
      provideDummy<TaskResult<AuthSuccess?>>(TaskResult<AuthSuccess?>.right(mockAuthSuccess));
      provideDummy<TaskResult<OtpVerificationResult>>(
        TaskResult<OtpVerificationResult>.right(OtpVerificationResult(isNewUser: false)),
      );
      provideDummy<TaskResult<AuthSuccess>>(TaskResult<AuthSuccess>.right(mockAuthSuccess));
    });

    tearDown(() {
      reset(authRepository);
      reset(analyticsService);
      reset(failureHandler);
    });

    group('loginWithProvider', () {
      blocSignalTest<LoginCubit, LoginState>(
        'emits success when auth returns valid authInfo for Google',
        build: () {
          when(authRepository.loginWithGoogle()).thenReturn(TaskResult<AuthSuccess?>.right(mockAuthSuccess));
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.loginWithProvider(LoginProvider.google),
        expect: () => <LoginState>[const LoginState.idle(isLoading: true), LoginState.success(mockAuthSuccess)],
        verify: (_) {
          verify(analyticsService.logLogin(LoginProvider.google.name)).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'calls handleFailure and emits nothing on Google login failure',
        build: () {
          when(authRepository.loginWithGoogle())
              .thenReturn(TaskResult<AuthSuccess?>.left(const Failure.authentication('Google sign-in failed')));
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.loginWithProvider(LoginProvider.google),
        expect: () => <LoginState>[const LoginState.idle(isLoading: true), const LoginState.idle()],
        verify: (_) {
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'emits blocked when account is blocked',
        build: () {
          when(
            authRepository.loginWithGoogle(),
          ).thenReturn(TaskResult<AuthSuccess?>.left(const Failure.authentication('Account blocked', blocked: true)));
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.loginWithProvider(LoginProvider.google),
        expect: () => <LoginState>[const LoginState.idle(isLoading: true), const LoginState.blocked()],
        verify: (_) {
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'calls handleException on onException',
        build: () {
          when(authRepository.loginWithFacebook()).thenThrow(Exception('unexpected'));
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
          when(authRepository.loginWithFacebook()).thenReturn(TaskResult<AuthSuccess?>.right(mockAuthSuccess));
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.loginWithProvider(LoginProvider.facebook),
        expect: () => <LoginState>[const LoginState.idle(isLoading: true), LoginState.success(mockAuthSuccess)],
        verify: (_) {
          verify(analyticsService.logLogin(LoginProvider.facebook.name)).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'handles email provider with valid email',
        build: () {
          when(authRepository.sendOtp(email: 'user@example.com')).thenReturn(TaskResult<Unit>.right(unit));
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.loginWithProvider(LoginProvider.email, email: 'user@example.com'),
        expect: () => <LoginState>[
          const LoginState.idle(isLoading: true),
          const LoginState.codeSent('user@example.com'),
        ],
        verify: (_) {
          verify(authRepository.sendOtp(email: 'user@example.com')).called(1);
        },
      );
    });

    group('verifyOtp', () {
      final OtpVerificationResult verificationResult = OtpVerificationResult(
        isNewUser: false,
        authInfo: mockAuthSuccess,
      );

      blocSignalTest<LoginCubit, LoginState>(
        'emits verifying, verified, and success when OTP verification succeeds with authInfo',
        build: () {
          when(authRepository.verifyOtp(email: 'user@example.com', code: '123456'))
              .thenReturn(TaskResult<OtpVerificationResult>.right(verificationResult));
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.verifyOtp(email: 'user@example.com', code: '123456'),
        expect: () => <LoginState>[
          const LoginState.verifying(email: 'user@example.com'),
          LoginState.verified(verificationResult),
          LoginState.success(mockAuthSuccess),
        ],
        verify: (_) {
          verify(analyticsService.logLogin(LoginProvider.email.name)).called(1);
        },
      );

      blocSignalTest<LoginCubit, LoginState>(
        'emits verifying then nothing on verifyOtp failure',
        build: () {
          when(authRepository.verifyOtp(email: 'user@example.com', code: '000000'))
              .thenReturn(TaskResult<OtpVerificationResult>.left(const Failure.authentication('Invalid code')));
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.verifyOtp(email: 'user@example.com', code: '000000'),
        expect: () => <LoginState>[const LoginState.verifying(email: 'user@example.com')],
      );
    });

    group('completeRegistration', () {
      final RegistrationForm form = RegistrationForm(
        email: 'user@example.com',
        name: 'John',
        gender: 'male',
        registrationToken: 'token',
      );
      blocSignalTest<LoginCubit, LoginState>(
        'emits registrationCompleted and success on completeRegistration success',
        build: () {
          when(authRepository.completeRegistration(form)).thenReturn(TaskResult<AuthSuccess>.right(mockAuthSuccess));
          return loginCubit;
        },
        act: (LoginCubit cubit) => cubit.completeRegistration(form),
        expect: () => <LoginState>[
          LoginState.registrationCompleted(mockAuthSuccess),
          LoginState.success(mockAuthSuccess),
        ],
        verify: (_) {
          verify(analyticsService.logLogin(LoginProvider.email.name)).called(1);
        },
      );
    });

    group('Pattern B — presentationStream failure events', () {
      test('emits LoginStateOtpError via presentationStream on auth error', () async {
        when(authRepository.loginWithGoogle())
            .thenReturn(TaskResult<AuthSuccess?>.left(const Failure.authentication('sign-in failed')));

        final List<LoginStateSideEffect> events = <LoginStateSideEffect>[];
        final StreamSubscription<LoginStateSideEffect> sub = loginCubit.presentationStream.listen(events.add);

        await loginCubit.loginWithProvider(LoginProvider.google);
        await Future<void>.delayed(Duration.zero);

        expect(events, hasLength(1));
        expect(events.first, isA<LoginStateOtpError>());
        expect((events.first as LoginStateOtpError).message, 'sign-in failed');

        await sub.cancel();
      });

      test('emits LoginStateOtpError with fallback message when Failure has no message', () async {
        when(authRepository.loginWithGoogle())
            .thenReturn(TaskResult<AuthSuccess?>.left(const Failure.authentication(null)));

        final List<LoginStateSideEffect> events = <LoginStateSideEffect>[];
        final StreamSubscription<LoginStateSideEffect> sub = loginCubit.presentationStream.listen(events.add);

        await loginCubit.loginWithProvider(LoginProvider.google);
        await Future<void>.delayed(Duration.zero);

        expect(events, hasLength(1));
        expect((events.first as LoginStateOtpError).message, 'Authentication failed');

        await sub.cancel();
      });

      test('emitted states do not include LoginState.failed', () async {
        when(authRepository.loginWithGoogle())
            .thenReturn(TaskResult<AuthSuccess?>.left(const Failure.authentication('fail')));

        final List<LoginState> states = <LoginState>[];
        final StreamSubscription<LoginState> sub = loginCubit.stream.listen(states.add);

        await loginCubit.loginWithProvider(LoginProvider.google);
        await Future<void>.delayed(Duration.zero);

        for (final LoginState s in states) {
          expect(s, isA<LoginStateIdle>(), reason: 'only idle states allowed, got $s');
        }

        await sub.cancel();
      });

      test('blocked path does NOT emit presentation event', () async {
        when(authRepository.loginWithGoogle())
            .thenReturn(TaskResult<AuthSuccess?>.left(const Failure.authentication('blocked', blocked: true)));

        final List<LoginStateSideEffect> events = <LoginStateSideEffect>[];
        final StreamSubscription<LoginStateSideEffect> sub = loginCubit.presentationStream.listen(events.add);

        await loginCubit.loginWithProvider(LoginProvider.google);
        await Future<void>.delayed(Duration.zero);

        expect(events, isEmpty);

        await sub.cancel();
      });
    });
  });
}
