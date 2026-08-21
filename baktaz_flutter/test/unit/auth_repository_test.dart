import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/features/auth/data/repository/auth_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../fixtures/client_fixtures.dart';
import '../utils/generated_mocks.mocks.dart';

void main() {
  group(AuthRepository, () {
    late MockServerpod serverpod;
    late MockClient client;
    late MockEndpointOtp otpEndpoint;
    late MockEndpointAuth authEndpoint;
    late MockFlutterAuthSessionManager sessionManager;
    late MockTalker talker;
    late AuthRepository authRepository;

    setUp(() {
      serverpod = MockServerpod();
      client = MockClient();
      otpEndpoint = MockEndpointOtp();
      authEndpoint = MockEndpointAuth();
      sessionManager = MockFlutterAuthSessionManager();
      talker = MockTalker();

      when(serverpod.client).thenReturn(client);
      when(client.otp).thenReturn(otpEndpoint);
      when(client.auth).thenReturn(authEndpoint);
      when(serverpod.sessionManager).thenReturn(sessionManager);

      authRepository = AuthRepository(serverpod, talker);

      provideDummy<TaskResult<Unit>>(TaskResult<Unit>.right(unit));
      provideDummy<TaskResult<AuthSuccess?>>(TaskResult<AuthSuccess?>.right(mockAuthSuccess));
      provideDummy<TaskResult<OtpVerificationResult>>(
        TaskResult<OtpVerificationResult>.right(OtpVerificationResult(isNewUser: false)),
      );
      provideDummy<TaskResult<AuthSuccess>>(TaskResult<AuthSuccess>.right(mockAuthSuccess));
    });

    tearDown(() {
      reset(serverpod);
      reset(client);
      reset(otpEndpoint);
      reset(authEndpoint);
      reset(sessionManager);
      reset(talker);
    });

    group('authInfo', () {
      test('should return sessionManager authInfo when user is signed in', () {
        when(sessionManager.authInfo).thenReturn(mockAuthSuccess);

        final AuthSuccess? result = authRepository.authInfo;

        expect(result, equals(mockAuthSuccess));
        verify(sessionManager.authInfo).called(1);
      });

      test('should return null when sessionManager authInfo is null', () {
        when(sessionManager.authInfo).thenReturn(null);

        final AuthSuccess? result = authRepository.authInfo;

        expect(result, isNull);
        verify(sessionManager.authInfo).called(1);
      });
    });

    group('sendOtp', () {
      test('should return Left(Failure) when email is empty', () async {
        final Either<Failure, Unit> result = await authRepository.sendOtp(email: '   ').run();

        expect(result.isLeft(), isTrue);
        result.fold(
          (Failure failure) =>
              expect(failure, equals(const Failure.authentication('Email is required for email login'))),
          (_) => fail('Expected Left'),
        );
      });

      test('should return Right(unit) when sendOtp succeeds', () async {
        when(otpEndpoint.sendOtp(email: 'user@example.com')).thenAnswer((_) async => true);

        final Either<Failure, Unit> result = await authRepository.sendOtp(email: 'user@example.com').run();

        expect(result.isRight(), isTrue);
        verify(otpEndpoint.sendOtp(email: 'user@example.com')).called(1);
      });

      test('should log error to talker and return Left(Failure) when sendOtp throws exception', () async {
        final Exception exception = Exception('Network error');
        when(otpEndpoint.sendOtp(email: 'user@example.com')).thenThrow(exception);

        final Either<Failure, Unit> result = await authRepository.sendOtp(email: 'user@example.com').run();

        expect(result.isLeft(), isTrue);
        result.fold(
          (Failure failure) => expect(failure, equals(Failure.authentication(exception.toString()))),
          (_) => fail('Expected Left'),
        );
        verify(talker.handle(exception, any)).called(1);
      });
    });

    group('verifyOtp', () {
      test('should return Right(OtpVerificationResult) and update signed in user when verifyOtp succeeds', () async {
        final OtpVerificationResult expectedResult = OtpVerificationResult(isNewUser: false, authInfo: mockAuthSuccess);
        when(otpEndpoint.verifyOtp(email: 'user@example.com', code: '123456')).thenAnswer((_) async => expectedResult);
        when(sessionManager.updateSignedInUser(mockAuthSuccess)).thenAnswer((_) async => true);

        final Either<Failure, OtpVerificationResult> result = await authRepository
            .verifyOtp(email: 'user@example.com', code: '123456')
            .run();

        expect(result.isRight(), isTrue);
        verify(sessionManager.updateSignedInUser(mockAuthSuccess)).called(1);
      });

      test('should return Left(Failure) with blocked: true for admin OTP error', () async {
        final StateError error = StateError('Admin accounts cannot use OTP login');
        when(otpEndpoint.verifyOtp(email: 'admin@example.com', code: '123456')).thenThrow(error);

        final Either<Failure, OtpVerificationResult> result = await authRepository
            .verifyOtp(email: 'admin@example.com', code: '123456')
            .run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) {
          expect(failure, isA<AuthenticationError>());
          expect((failure as AuthenticationError).blocked, isTrue);
        }, (_) => fail('Expected Left'));
      });

      test('should return Left(Failure) with blocked: true when error message contains blocked', () async {
        final Exception exception = Exception('Account blocked by admin');
        when(otpEndpoint.verifyOtp(email: 'user@example.com', code: '123456')).thenThrow(exception);

        final Either<Failure, OtpVerificationResult> result = await authRepository
            .verifyOtp(email: 'user@example.com', code: '123456')
            .run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) {
          expect(failure, isA<AuthenticationError>());
          expect((failure as AuthenticationError).blocked, isTrue);
        }, (_) => fail('Expected Left'));
      });
    });

    group('completeRegistration', () {
      test('should return Right(AuthSuccess) when completeRegistration succeeds', () async {
        final OtpVerificationResult verificationResult = OtpVerificationResult(
          isNewUser: false,
          authInfo: mockAuthSuccess,
        );
        when(
          authEndpoint.completeRegistration(
            email: 'user@example.com',
            name: 'User',
            gender: 'male',
            registrationToken: 'token',
          ),
        ).thenAnswer((_) async => verificationResult);

        final Either<Failure, AuthSuccess> result = await authRepository
            .completeRegistration(email: 'user@example.com', name: 'User', gender: 'male', registrationToken: 'token')
            .run();

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected Right'), (AuthSuccess authInfo) => expect(authInfo, equals(mockAuthSuccess)));
      });

      test('should return Left(Failure) when authInfo is null', () async {
        final OtpVerificationResult verificationResult = OtpVerificationResult(isNewUser: true);
        when(
          authEndpoint.completeRegistration(
            email: 'user@example.com',
            name: 'User',
            gender: 'male',
            registrationToken: 'token',
          ),
        ).thenAnswer((_) async => verificationResult);

        final Either<Failure, AuthSuccess> result = await authRepository
            .completeRegistration(email: 'user@example.com', name: 'User', gender: 'male', registrationToken: 'token')
            .run();

        expect(result.isLeft(), isTrue);
      });
    });

    group('logout', () {
      test('should sign out single device and return Right(unit)', () async {
        when(sessionManager.signOutDevice()).thenAnswer((_) async => true);

        final Either<Failure, Unit> result = await authRepository.logout().run();

        expect(result.isRight(), isTrue);
        verify(sessionManager.signOutDevice()).called(1);
      });

      test('should log error to talker and return Left(Failure) when sign out throws exception', () async {
        final Exception exception = Exception('Storage error');
        when(sessionManager.signOutDevice()).thenThrow(exception);

        final Either<Failure, Unit> result = await authRepository.logout().run();

        expect(result.isLeft(), isTrue);
        result.fold(
          (Failure failure) => expect(failure, equals(Failure.unexpected(exception.toString()))),
          (_) => fail('Expected Left'),
        );
        verify(talker.handle(exception, any)).called(1);
      });
    });
  });
}
