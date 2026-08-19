import 'package:baktaz_server/src/app/utils/auth_utils.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import '../fixtures/server_fixtures.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given AuthUtils', (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
    group('onBeforeUserProfileCreated', () {
      test('sets userName from email when userName is null and email provided', () async {
        final Session session = sessionBuilder.build();
        final UuidValue authUserId = ServerFixtures.testAuthUserId;
        final UserProfileData userProfile = UserProfileData(email: 'test@example.com', fullName: 'Test User');

        await session.db.transaction((Transaction transaction) async {
          final UserProfileData result = await AuthUtils.onBeforeUserProfileCreated(
            session,
            authUserId,
            userProfile,
            transaction: transaction,
          );

          expect(result.userName, equals('test'));
          expect(result.fullName, equals('Test User'));
          expect(result.email, equals('test@example.com'));
        });
      });

      test('sets fullName from userName when fullName is null', () async {
        final Session session = sessionBuilder.build();
        final UuidValue authUserId = ServerFixtures.testAuthUserId;
        final UserProfileData userProfile = UserProfileData(userName: 'customuser');

        await session.db.transaction((Transaction transaction) async {
          final UserProfileData result = await AuthUtils.onBeforeUserProfileCreated(
            session,
            authUserId,
            userProfile,
            transaction: transaction,
          );

          expect(result.userName, equals('customuser'));
          expect(result.fullName, equals('customuser'));
        });
      });

      test('does not override existing userName or fullName', () async {
        final Session session = sessionBuilder.build();
        final UuidValue authUserId = ServerFixtures.testAuthUserId;
        final UserProfileData userProfile = UserProfileData(
          email: 'test@example.com',
          userName: 'existinguser',
          fullName: 'Existing Name',
        );

        await session.db.transaction((Transaction transaction) async {
          final UserProfileData result = await AuthUtils.onBeforeUserProfileCreated(
            session,
            authUserId,
            userProfile,
            transaction: transaction,
          );

          expect(result.userName, equals('existinguser'));
          expect(result.fullName, equals('Existing Name'));
        });
      });

      test('handles empty email - sets userName to empty string', () async {
        final Session session = sessionBuilder.build();
        final UuidValue authUserId = ServerFixtures.testAuthUserId;
        final UserProfileData userProfile = UserProfileData(email: '');

        await session.db.transaction((Transaction transaction) async {
          final UserProfileData result = await AuthUtils.onBeforeUserProfileCreated(
            session,
            authUserId,
            userProfile,
            transaction: transaction,
          );

          expect(result.userName, equals(''));
          // fullName stays null because userName is empty string (falsy in Dart)
          expect(result.fullName, isNull);
        });
      });

      test('handles null email - no userName or fullName set', () async {
        final Session session = sessionBuilder.build();
        final UuidValue authUserId = ServerFixtures.testAuthUserId;
        final UserProfileData userProfile = UserProfileData();

        await session.db.transaction((Transaction transaction) async {
          final UserProfileData result = await AuthUtils.onBeforeUserProfileCreated(
            session,
            authUserId,
            userProfile,
            transaction: transaction,
          );

          expect(result.userName, isNull);
          expect(result.fullName, isNull);
        });
      });

      test('sets userName and fullName from email when both userName and fullName are null', () async {
        final Session session = sessionBuilder.build();
        final UuidValue authUserId = ServerFixtures.testAuthUserId;
        final UserProfileData userProfile = UserProfileData(email: 'user@domain.com');

        await session.db.transaction((Transaction transaction) async {
          final UserProfileData result = await AuthUtils.onBeforeUserProfileCreated(
            session,
            authUserId,
            userProfile,
            transaction: transaction,
          );

          expect(result.userName, equals('user'));
          expect(result.fullName, equals('user'));
        });
      });
    });

    group('onAfterUserProfileCreated', () {
      test('creates Account with associated records when UserProfile and AuthUser exist', () async {
        final Session session = sessionBuilder.build();
        final UuidValue authUserId = ServerFixtures.testAuthUserId;
        final UserProfileModel userProfile = UserProfileModel(
          authUserId: authUserId,
          email: 'newuser@example.com',
          fullName: 'New User',
          userName: 'newuser',
        );

        await session.db.transaction((Transaction transaction) async {
          // Insert AuthUser so authUsers.get succeeds
          await AuthUser.db.insertRow(
            session,
            AuthUser(id: authUserId, createdAt: DateTime.now(), scopeNames: const <String>{}, blocked: false),
            transaction: transaction,
          );

          // Insert UserProfile so findFirstRow succeeds
          await UserProfile.db.insertRow(
            session,
            UserProfile(
              authUserId: authUserId,
              email: 'newuser@example.com',
              fullName: 'New User',
              userName: 'newuser',
            ),
            transaction: transaction,
          );

          await AuthUtils.onAfterUserProfileCreated(session, userProfile, transaction: transaction);

          // Verify Account was created with all relations
          final Account? account = await Account.db.findFirstRow(
            session,
            where: (AccountTable t) => t.authUserId.equals(authUserId),
            include: Account.include(wallet: Wallet.include(), userInfo: UserInfo.include()),
            transaction: transaction,
          );

          expect(account, isNotNull);
          expect(account!.authUserId, equals(authUserId));
          expect(account.userProfileId, isNotNull);
          expect(account.userInfoId, isNotNull);
          expect(account.walletId, isNotNull);

          // Verify Wallet was created with zero balances
          expect(account.wallet, isNotNull);
          expect(account.wallet!.cashBalance, equals(0));
          expect(account.wallet!.connectBalance, equals(0));

          // Verify UserInfo was created with default gender
          expect(account.userInfo, isNotNull);
          expect(account.userInfo!.gender, equals(Gender.unknown));
        });
      });

      test('throws StateError when UserProfile not found after creation', () async {
        final Session session = sessionBuilder.build();
        final UuidValue authUserId = ServerFixtures.testAuthUserId;
        final UserProfileModel userProfile = UserProfileModel(
          authUserId: authUserId,
          email: 'test@example.com',
          fullName: 'Test User',
          userName: 'testuser',
        );

        await session.db.transaction((Transaction transaction) async {
          // Insert AuthUser so authUsers.get succeeds, but do NOT insert UserProfile
          await AuthUser.db.insertRow(
            session,
            AuthUser(id: authUserId, createdAt: DateTime.now(), scopeNames: const <String>{}, blocked: false),
            transaction: transaction,
          );

          await expectLater(
            AuthUtils.onAfterUserProfileCreated(session, userProfile, transaction: transaction),
            throwsA(
              isA<StateError>().having(
                (StateError e) => e.toString(),
                'message',
                contains('UserProfile not found for authUserId'),
              ),
            ),
          );
        });
      });
    });
  });
}
