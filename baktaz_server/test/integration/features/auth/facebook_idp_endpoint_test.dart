import 'package:baktaz_server/src/app/utils/auth_utils.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/facebook.dart';
import 'package:test/test.dart';

import '../../fixtures/server_fixtures.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given FacebookIdpEndpoint', (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
    setUpAll(() {
      try {
        AuthServices.instance;
      } on Object catch (_) {
        AuthServices.set(
          userProfileConfig: const UserProfileConfig(
            onBeforeUserProfileCreated: AuthUtils.onBeforeUserProfileCreated,
            onAfterUserProfileCreated: AuthUtils.onAfterUserProfileCreated,
          ),
          tokenManagerBuilders: <TokenManagerBuilder<TokenManager>>[JwtConfigFromPasswords()],
          identityProviderBuilders: <IdentityProviderBuilder<IdentityProvider>>[
            const FacebookIdpConfig(appId: 'test_app_id', appSecret: 'test_app_secret'),
          ],
        );
      }
    });
    group('when unauthenticated', () {
      final TestSessionBuilder unauthedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.unauthenticated(),
      );

      test('then hasAccount returns false', () async {
        final bool result = await endpoints.facebookIdp.hasAccount(unauthedSession);
        expect(result, isFalse);
      });

      test('then login with invalid accessToken throws exception', () async {
        await expectLater(
          endpoints.facebookIdp.login(unauthedSession, accessToken: 'invalid_facebook_token'),
          throwsA(anything),
        );
      });

      test('then login with empty accessToken throws exception', () async {
        await expectLater(endpoints.facebookIdp.login(unauthedSession, accessToken: ''), throwsA(anything));
      });

      test('then login with malformed accessToken throws exception', () async {
        await expectLater(
          endpoints.facebookIdp.login(unauthedSession, accessToken: 'malformed.token.here'),
          throwsA(anything),
        );
      });
    });

    group('when authenticated', () {
      final TestSessionBuilder authedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ServerFixtures.testAuthUserId.toString(),
          ServerFixtures.userScopes,
        ),
      );

      test('then hasAccount returns account presence status', () async {
        final bool result = await endpoints.facebookIdp.hasAccount(authedSession);
        expect(result, isA<bool>());
      });

      test('then login with valid-looking but fake token still throws', () async {
        await expectLater(
          endpoints.facebookIdp.login(authedSession, accessToken: 'fake_valid_format_token_123'),
          throwsA(anything),
        );
      });
    });
  });
}
