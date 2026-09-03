import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import '../../fixtures/server_fixtures.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given AccountEndpoint', (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
    group('when unauthenticated', () {
      final TestSessionBuilder unauthedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.unauthenticated(),
      );

      test('then getSummary throws ServerpodUnauthenticatedException', () async {
        await expectLater(
          endpoints.account.getSummary(unauthedSession),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('then deleteAccount throws ServerpodUnauthenticatedException', () async {
        await expectLater(
          endpoints.account.deleteAccount(unauthedSession),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });
    });

    group('when authenticated with account in DB', () {
      final TestSessionBuilder authedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ServerFixtures.testAuthUserId.toString(),
          ServerFixtures.userScopes,
        ),
      );

      setUp(() async {
        final Session session = sessionBuilder.build();

        await AuthUser.db.insertRow(
          session,
          AuthUser(
            id: ServerFixtures.testAuthUserId,
            createdAt: DateTime.now(),
            scopeNames: const <String>{},
            blocked: false,
          ),
        );

        final UserProfile userProfile = await UserProfile.db.insertRow(
          session,
          UserProfile(
            id: ServerFixtures.testAuthUserId,
            authUserId: ServerFixtures.testAuthUserId,
            email: 'john@example.com',
            fullName: 'John Walker',
            userName: 'johnw',
          ),
        );

        final UserInfo userInfo = await UserInfo.db.insertRow(
          session,
          UserInfo(
            userIdentifier: ServerFixtures.testAuthUserId,
            email: 'john@example.com',
            username: 'johnw',
            firstName: 'John',
            gender: Gender.male,
            birthday: DateTime(1995, 5, 15),
            mobileNumber: '+1234567890',
          ),
        );

        final Wallet wallet = await Wallet.db.insertRow(session, Wallet(cashBalance: 500.25, connectBalance: 50));

        await Account.db.insertRow(
          session,
          Account(
            id: ServerFixtures.testAuthUserId,
            authUserId: ServerFixtures.testAuthUserId,
            userProfileId: userProfile.id,
            userInfoId: userInfo.id,
            walletId: wallet.id,
          ),
        );
      });

      test('then getSummary returns summary with steps', () async {
        final AccountSummary summary = await endpoints.account.getSummary(authedSession);

        expect(summary.userId, equals(ServerFixtures.testAuthUserId));
        expect(summary.totalSteps, equals(0));
        expect(summary.activeChallengeCount, equals(0));
      });
    });
  });
}
