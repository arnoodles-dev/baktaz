import 'package:test/test.dart';

import '../../fixtures/server_fixtures.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given JwtRefreshEndpoint', (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
    group('when refreshing access token', () {
      test('then refreshAccessToken with invalid token throws exception', () async {
        await expectLater(
          endpoints.jwtRefresh.refreshAccessToken(sessionBuilder, refreshToken: 'invalid_refresh_token_string'),
          throwsA(anything),
        );
      });

      test('then refreshAccessToken with empty token throws exception', () async {
        await expectLater(endpoints.jwtRefresh.refreshAccessToken(sessionBuilder, refreshToken: ''), throwsA(anything));
      });

      test('then refreshAccessToken with malformed token throws exception', () async {
        await expectLater(
          endpoints.jwtRefresh.refreshAccessToken(sessionBuilder, refreshToken: 'malformed.jwt.token.here'),
          throwsA(anything),
        );
      });

      test('then refreshAccessToken with expired-looking token throws exception', () async {
        // Create a token that looks like a JWT but is invalid
        const String fakeJwt = 'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2MDAwMDAwMDB9.invalid_signature';
        await expectLater(
          endpoints.jwtRefresh.refreshAccessToken(sessionBuilder, refreshToken: fakeJwt),
          throwsA(anything),
        );
      });
    });

    group('when authenticated user tries to refresh', () {
      final TestSessionBuilder authedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ServerFixtures.testAuthUserId.toString(),
          ServerFixtures.userScopes,
        ),
      );

      test('then refreshAccessToken with invalid token still throws', () async {
        await expectLater(
          endpoints.jwtRefresh.refreshAccessToken(authedSession, refreshToken: 'invalid_token'),
          throwsA(anything),
        );
      });
    });
  });
}
