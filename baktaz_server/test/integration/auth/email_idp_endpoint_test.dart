import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../../fixtures/server_fixtures.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given EmailIdpEndpoint', (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
    group('when logging in', () {
      test('then login with invalid email/password fails or throws exception', () async {
        await expectLater(
          endpoints.emailIdp.login(sessionBuilder, email: 'invalid@example.com', password: 'WrongPassword123!'),
          throwsA(anything),
        );
      });

      test('then login with empty email throws exception', () async {
        await expectLater(endpoints.emailIdp.login(sessionBuilder, email: '', password: 'password'), throwsA(anything));
      });

      test('then login with empty password throws exception', () async {
        await expectLater(
          endpoints.emailIdp.login(sessionBuilder, email: 'test@example.com', password: ''),
          throwsA(anything),
        );
      });
    });

    group('when starting registration', () {
      test('then startRegistration accepts valid email format', () async {
        final UuidValue requestId = await endpoints.emailIdp.startRegistration(
          sessionBuilder,
          email: 'newuser@example.com',
        );

        expect(requestId, isNotNull);
        expect(requestId, isA<UuidValue>());
      });

      test('then startRegistration rejects invalid email format', () async {
        await expectLater(
          endpoints.emailIdp.startRegistration(sessionBuilder, email: 'invalid-email'),
          throwsA(anything),
        );
      });

      test('then startRegistration rejects empty email', () async {
        await expectLater(endpoints.emailIdp.startRegistration(sessionBuilder, email: ''), throwsA(anything));
      });
    });

    group('when verifying registration code', () {
      test('then verifyRegistrationCode with invalid code fails or throws', () async {
        final UuidValue dummyId = UuidValue.fromString('00000000-0000-4000-8000-000000000099');

        await expectLater(
          endpoints.emailIdp.verifyRegistrationCode(
            sessionBuilder,
            accountRequestId: dummyId,
            verificationCode: '000000',
          ),
          throwsA(anything),
        );
      });

      test('then verifyRegistrationCode with empty code fails', () async {
        final UuidValue requestId = UuidValue.fromString('00000000-0000-4000-8000-000000000001');

        await expectLater(
          endpoints.emailIdp.verifyRegistrationCode(sessionBuilder, accountRequestId: requestId, verificationCode: ''),
          throwsA(anything),
        );
      });
    });

    group('when finishing registration', () {
      test('then finishRegistration with invalid token fails', () async {
        await expectLater(
          endpoints.emailIdp.finishRegistration(
            sessionBuilder,
            registrationToken: 'invalid_token',
            password: 'ValidPass123!',
          ),
          throwsA(anything),
        );
      });

      test('then finishRegistration with empty token fails', () async {
        await expectLater(
          endpoints.emailIdp.finishRegistration(sessionBuilder, registrationToken: '', password: 'ValidPass123!'),
          throwsA(anything),
        );
      });

      test('then finishRegistration with empty password fails', () async {
        await expectLater(
          endpoints.emailIdp.finishRegistration(sessionBuilder, registrationToken: 'valid_token', password: ''),
          throwsA(anything),
        );
      });
    });

    group('when requesting password reset', () {
      test('then startPasswordReset accepts email input', () async {
        final UuidValue resetId = await endpoints.emailIdp.startPasswordReset(
          sessionBuilder,
          email: 'user@example.com',
        );

        expect(resetId, isNotNull);
      });

      test('then startPasswordReset rejects invalid email format', () async {
        await expectLater(
          endpoints.emailIdp.startPasswordReset(sessionBuilder, email: 'invalid-email'),
          throwsA(anything),
        );
      });

      test('then startPasswordReset rejects empty email', () async {
        await expectLater(endpoints.emailIdp.startPasswordReset(sessionBuilder, email: ''), throwsA(anything));
      });
    });

    group('when verifying password reset code', () {
      test('then verifyPasswordResetCode with invalid code fails', () async {
        final UuidValue dummyId = UuidValue.fromString('00000000-0000-4000-8000-000000000099');

        await expectLater(
          endpoints.emailIdp.verifyPasswordResetCode(
            sessionBuilder,
            passwordResetRequestId: dummyId,
            verificationCode: '000000',
          ),
          throwsA(anything),
        );
      });

      test('then verifyPasswordResetCode with empty code fails', () async {
        final UuidValue requestId = UuidValue.fromString('00000000-0000-4000-8000-000000000001');

        await expectLater(
          endpoints.emailIdp.verifyPasswordResetCode(
            sessionBuilder,
            passwordResetRequestId: requestId,
            verificationCode: '',
          ),
          throwsA(anything),
        );
      });
    });

    group('when finishing password reset', () {
      test('then finishPasswordReset with invalid token fails', () async {
        await expectLater(
          endpoints.emailIdp.finishPasswordReset(
            sessionBuilder,
            finishPasswordResetToken: 'invalid_token',
            newPassword: 'NewPass123!',
          ),
          throwsA(anything),
        );
      });

      test('then finishPasswordReset with empty token fails', () async {
        await expectLater(
          endpoints.emailIdp.finishPasswordReset(
            sessionBuilder,
            finishPasswordResetToken: '',
            newPassword: 'NewPass123!',
          ),
          throwsA(anything),
        );
      });

      test('then finishPasswordReset with empty new password fails', () async {
        await expectLater(
          endpoints.emailIdp.finishPasswordReset(
            sessionBuilder,
            finishPasswordResetToken: 'valid_token',
            newPassword: '',
          ),
          throwsA(anything),
        );
      });
    });

    group('when checking account existence', () {
      test('then hasAccount returns false for unauthenticated session', () async {
        final TestSessionBuilder unauthedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.unauthenticated(),
        );

        final bool result = await endpoints.emailIdp.hasAccount(unauthedSession);
        expect(result, isFalse);
      });

      test('then hasAccount returns account presence status for authenticated session', () async {
        final TestSessionBuilder authedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            ServerFixtures.testAuthUserId.toString(),
            ServerFixtures.userScopes,
          ),
        );

        final bool result = await endpoints.emailIdp.hasAccount(authedSession);
        expect(result, isA<bool>());
      });
    });
  });
}
