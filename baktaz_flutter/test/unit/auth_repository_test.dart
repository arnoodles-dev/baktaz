import 'package:baktaz_flutter/features/auth/data/repository/auth_repository.dart';
import 'package:baktaz_flutter/features/auth/domain/entity/enum/login_provider.dart';
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
    late MockFlutterAuthSessionManager sessionManager;
    late MockTalker talker;
    late AuthRepository authRepository;

    setUp(() {
      serverpod = MockServerpod();
      sessionManager = MockFlutterAuthSessionManager();
      talker = MockTalker();

      when(serverpod.sessionManager).thenReturn(sessionManager);
      authRepository = AuthRepository(serverpod, talker);
    });

    tearDown(() {
      reset(serverpod);
      reset(sessionManager);
      reset(talker);
    });

    group('authInfo', () {
      test('should return sessionManager authInfo when user is signed in', () {
        // Arrange
        when(sessionManager.authInfo).thenReturn(mockAuthSuccess);

        // Act
        final AuthSuccess? result = authRepository.authInfo;

        // Assert
        expect(result, equals(mockAuthSuccess));
        verify(sessionManager.authInfo).called(1);
      });

      test('should return null when sessionManager authInfo is null', () {
        // Arrange
        when(sessionManager.authInfo).thenReturn(null);

        // Act
        final AuthSuccess? result = authRepository.authInfo;

        // Assert
        expect(result, isNull);
        verify(sessionManager.authInfo).called(1);
      });
    });

    group('loginWithProvider', () {
      test('should call onError with mobile required failure when mobile number is null for mobile provider', () async {
        // Arrange
        Failure? capturedFailure;

        // Act
        await authRepository.loginWithProvider(
          provider: LoginProvider.mobile,
          onAuthenticated: (_) {},
          onError: (Failure failure) {
            capturedFailure = failure;
          },
        );

        // Assert
        expect(capturedFailure, isNotNull);
        expect(capturedFailure, equals(const Failure.authentication('Mobile number is required for mobile login')));
      });

      test('should call onError with validation failure when mobile number format is invalid', () async {
        // Arrange
        Failure? capturedFailure;
        final MobileNumber invalidMobile = MobileNumber('123'); // Invalid format

        // Act
        await authRepository.loginWithProvider(
          provider: LoginProvider.mobile,
          onAuthenticated: (_) {},
          onError: (Failure failure) {
            capturedFailure = failure;
          },
          mobileNumber: invalidMobile,
        );

        // Assert
        expect(capturedFailure, isNotNull);
      });
    });

    group('logout', () {
      test('should sign out single device and return Right(unit)', () async {
        // Arrange
        when(sessionManager.signOutDevice()).thenAnswer((_) async => true);

        // Act
        final Either<Failure, Unit> result = await authRepository.logout().run();

        // Assert
        expect(result.isRight(), isTrue);
        verify(sessionManager.signOutDevice()).called(1);
      });

      test('should log error to talker and return Left(Failure) when sign out throws exception', () async {
        // Arrange
        final Exception exception = Exception('Storage error');
        when(sessionManager.signOutDevice()).thenThrow(exception);

        // Act
        final Either<Failure, Unit> result = await authRepository.logout().run();

        // Assert
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
