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

      test('then getCurrentAccount throws ServerpodUnauthenticatedException', () async {
        await expectLater(
          endpoints.account.getCurrentAccount(unauthedSession),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('then getAccountSummary throws ServerpodUnauthenticatedException', () async {
        await expectLater(
          endpoints.account.getAccountSummary(unauthedSession),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('then getProfile throws ServerpodUnauthenticatedException', () async {
        await expectLater(
          endpoints.account.getProfile(unauthedSession),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });
    });

    group('when authenticated without account in DB', () {
      final TestSessionBuilder authedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ServerFixtures.testAuthUserId.toString(),
          ServerFixtures.userScopes,
        ),
      );

      test('then getCurrentAccount returns null', () async {
        final Account? result = await endpoints.account.getCurrentAccount(authedSession);
        expect(result, isNull);
      });

      test('then getAccountSummary returns null', () async {
        final AccountSummary? result = await endpoints.account.getAccountSummary(authedSession);
        expect(result, isNull);
      });

      test('then getProfile returns null', () async {
        final Profile? result = await endpoints.account.getProfile(authedSession);
        expect(result, isNull);
      });
    });

    group('when authenticated with account, profile, userInfo, and wallet in DB', () {
      final TestSessionBuilder authedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ServerFixtures.testAuthUserId.toString(),
          ServerFixtures.userScopes,
        ),
      );

      setUp(() async {
        final Session session = sessionBuilder.build();

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
          UserInfo(gender: Gender.male, birthday: DateTime(1995, 5, 15), mobileNumber: '+1234567890'),
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

      test('then getCurrentAccount returns account with relations', () async {
        final Account? account = await endpoints.account.getCurrentAccount(authedSession);

        expect(account, isNotNull);
        expect(account!.authUserId, equals(ServerFixtures.testAuthUserId));
        expect(account.userProfile?.fullName, equals('John Walker'));
        expect(account.userInfo?.gender, equals(Gender.male));
        expect(account.wallet?.cashBalance, equals(500.25));
        expect(account.wallet?.connectBalance, equals(50));
      });

      test('then getAccountSummary returns summary with wallet balances', () async {
        final AccountSummary? summary = await endpoints.account.getAccountSummary(authedSession);

        expect(summary, isNotNull);
        expect(summary!.name, equals('John Walker'));
        expect(summary.cashBalance, equals(500.25));
        expect(summary.connectBalance, equals(50));
      });

      test('then getProfile returns profile populated with account details', () async {
        final Profile? profile = await endpoints.account.getProfile(authedSession);

        expect(profile, isNotNull);
        expect(profile!.fullName, equals('John Walker'));
        expect(profile.gender, equals(Gender.male));
        expect(profile.email, equals('john@example.com'));
        expect(profile.mobileNumber, equals('+1234567890'));
        expect(profile.birthday, equals(DateTime(1995, 5, 15)));
      });
    });

    group('financial ledger transaction edge cases', () {
      final UuidValue ledgerAuthUserId = UuidValue.fromString('00000000-0000-4000-8000-000000000099');
      final TestSessionBuilder ledgerSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ledgerAuthUserId.toString(),
          ServerFixtures.userScopes,
        ),
      );

      test('handles zero wallet balances and null user profile fallbacks', () async {
        final Session session = sessionBuilder.build();

        final Wallet wallet = await Wallet.db.insertRow(session, Wallet(cashBalance: 0, connectBalance: 0));

        await Account.db.insertRow(
          session,
          Account(id: ledgerAuthUserId, authUserId: ledgerAuthUserId, walletId: wallet.id),
        );

        final AccountSummary? summary = await endpoints.account.getAccountSummary(ledgerSession);

        expect(summary, isNotNull);
        expect(summary!.name, equals('Baktaz Walker'));
        expect(summary.cashBalance, equals(0));
        expect(summary.connectBalance, equals(0));

        final Profile? profile = await endpoints.account.getProfile(ledgerSession);

        expect(profile, isNotNull);
        expect(profile!.fullName, equals('Baktaz Walker'));
        expect(profile.gender, equals(Gender.unknown));
      });

      test('handles wallet transaction entries in financial ledger', () async {
        final Session session = sessionBuilder.build();

        final Wallet wallet = await Wallet.db.insertRow(session, Wallet(cashBalance: 1000, connectBalance: 100));

        await WalletTransactions.db.insertRow(
          session,
          WalletTransactions(
            walletId: wallet.id!,
            amount: 500,
            transactionDate: DateTime(2026),
            transactionType: TransactionType.credit,
          ),
        );

        await WalletTransactions.db.insertRow(
          session,
          WalletTransactions(
            walletId: wallet.id!,
            amount: 200,
            transactionDate: DateTime(2026, 1, 2),
            transactionType: TransactionType.debit,
          ),
        );

        final List<WalletTransactions> txs = await WalletTransactions.db.find(
          session,
          where: (WalletTransactionsTable t) => t.walletId.equals(wallet.id),
        );

        expect(txs, hasLength(2));
        expect(txs[0].transactionType, equals(TransactionType.credit));
        expect(txs[1].transactionType, equals(TransactionType.debit));
      });

      test('getProfile derives fullName from userProfile when userInfo not present', () async {
        final Session session = sessionBuilder.build();

        final UserProfile userProfile = await UserProfile.db.insertRow(
          session,
          UserProfile(
            authUserId: ledgerAuthUserId,
            email: 'ledger@example.com',
            fullName: 'Ledger User',
            userName: 'ledgeruser',
          ),
        );

        final Wallet wallet = await Wallet.db.insertRow(session, Wallet(cashBalance: 100, connectBalance: 20));

        await Account.db.insertRow(
          session,
          Account(
            id: ledgerAuthUserId,
            authUserId: ledgerAuthUserId,
            userProfileId: userProfile.id,
            walletId: wallet.id,
          ),
        );

        final Profile? profile = await endpoints.account.getProfile(ledgerSession);

        expect(profile, isNotNull);
        expect(profile!.fullName, equals('Ledger User'));
        expect(profile.gender, equals(Gender.unknown));
        expect(profile.mobileNumber, isNull);
      });

      test('getProfile falls back to Baktaz Walker when userProfile and userInfo are both null', () async {
        final Session session = sessionBuilder.build();

        final Wallet wallet = await Wallet.db.insertRow(session, Wallet(cashBalance: 0, connectBalance: 0));

        await Account.db.insertRow(
          session,
          Account(id: ledgerAuthUserId, authUserId: ledgerAuthUserId, walletId: wallet.id),
        );

        final Profile? profile = await endpoints.account.getProfile(ledgerSession);

        expect(profile, isNotNull);
        expect(profile!.fullName, equals('Baktaz Walker'));
        expect(profile.gender, equals(Gender.unknown));
      });

      test(
        'getAccountSummary uses userProfile fullName over default when userInfo present but profile absent',
        () async {
          final Session session = sessionBuilder.build();

          final UserInfo userInfo = await UserInfo.db.insertRow(
            session,
            UserInfo(gender: Gender.female, birthday: DateTime(1990)),
          );

          final Wallet wallet = await Wallet.db.insertRow(session, Wallet(cashBalance: 999.99, connectBalance: 42));

          await Account.db.insertRow(
            session,
            Account(id: ledgerAuthUserId, authUserId: ledgerAuthUserId, userInfoId: userInfo.id, walletId: wallet.id),
          );

          final AccountSummary? summary = await endpoints.account.getAccountSummary(ledgerSession);

          expect(summary, isNotNull);
          expect(summary!.name, equals('Baktaz Walker'));
          expect(summary.cashBalance, equals(999.99));
          expect(summary.connectBalance, equals(42));
        },
      );

      test('getCurrentAccount returns account with null relations gracefully', () async {
        final Session session = sessionBuilder.build();

        await Account.db.insertRow(session, Account(id: ledgerAuthUserId, authUserId: ledgerAuthUserId));

        final Account? account = await endpoints.account.getCurrentAccount(ledgerSession);

        expect(account, isNotNull);
        expect(account!.authUserId, equals(ledgerAuthUserId));
        expect(account.userProfile, isNull);
        expect(account.userInfo, isNull);
        expect(account.wallet, isNull);
      });
    });

    group('when authenticated with negative wallet balances', () {
      final TestSessionBuilder negativeSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ServerFixtures.testAuthUserId.toString(),
          ServerFixtures.userScopes,
        ),
      );

      test('then getAccountSummary returns negative balances', () async {
        final Session session = sessionBuilder.build();

        final Wallet wallet = await Wallet.db.insertRow(session, Wallet(cashBalance: -100.5, connectBalance: -5));

        await Account.db.insertRow(
          session,
          Account(id: ServerFixtures.testAuthUserId, authUserId: ServerFixtures.testAuthUserId, walletId: wallet.id),
        );

        final AccountSummary? summary = await endpoints.account.getAccountSummary(negativeSession);

        expect(summary, isNotNull);
        expect(summary!.cashBalance, equals(-100.5));
        expect(summary.connectBalance, equals(-5));
      });
    });
  });
}
