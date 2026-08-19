import 'package:test/test.dart';

import '../../fixtures/server_fixtures.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given GoogleIdpEndpoint', (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
    group('when unauthenticated', () {
      final TestSessionBuilder unauthedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.unauthenticated(),
      );

      test('then hasAccount returns false', () async {
        final bool result = await endpoints.googleIdp.hasAccount(unauthedSession);
        expect(result, isFalse);
      });

      test('then login with invalid idToken throws exception', () async {
        await expectLater(
          endpoints.googleIdp.login(unauthedSession, idToken: 'invalid_google_id_token', accessToken: null),
          throwsA(anything),
        );
      });

      test('then loginWithCode with invalid code throws exception', () async {
        await expectLater(
          endpoints.googleIdp.loginWithCode(
            unauthedSession,
            code: 'invalid_code',
            codeVerifier: 'invalid_verifier',
            redirectUri: 'https://example.com/callback',
          ),
          throwsA(anything),
        );
      });

      test('then loginWithCode with missing parameters throws exception', () async {
        await expectLater(
          endpoints.googleIdp.loginWithCode(unauthedSession, code: '', codeVerifier: '', redirectUri: ''),
          throwsA(anything),
        );
      });
    });

    group('when authenticated as regular user', () {
      final TestSessionBuilder authedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ServerFixtures.testAuthUserId.toString(),
          ServerFixtures.userScopes,
        ),
      );

      test('then hasAccount checks account existence', () async {
        final bool result = await endpoints.googleIdp.hasAccount(authedSession);
        expect(result, isA<bool>());
      });

      test('then loginWithCode with valid format but invalid values throws exception', () async {
        await expectLater(
          endpoints.googleIdp.loginWithCode(
            authedSession,
            code: 'valid_format_but_invalid',
            codeVerifier: 'valid_verifier_but_invalid',
            redirectUri: 'https://example.com/callback',
          ),
          throwsA(anything),
        );
      });
    });
  });
}
