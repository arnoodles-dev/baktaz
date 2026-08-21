import 'package:baktaz_server/src/app/config/app_config.dart';
import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/security/data/service/security_logger.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

final class AccountEndpoint extends Endpoint {
  AccountEndpoint([SecurityLogger? securityLogger]) : _securityLogger = securityLogger ?? getIt<SecurityLogger>();

  final SecurityLogger _securityLogger;

  @override
  bool get requireLogin => true;

  Future<Account?> getCurrentAccount(Session session) async {
    final UuidValue? authUserId = session.authenticated?.authUserId;
    if (authUserId == null) return null;
    return Account.db.findFirstRow(
      session,
      where: (AccountTable t) => t.authUserId.equals(authUserId),
      include: Account.include(
        userProfile: UserProfile.include(),
        userInfo: UserInfo.include(),
        wallet: Wallet.include(),
      ),
    );
  }

  Future<AccountSummary?> getAccountSummary(Session session) async {
    final Account? account = await getCurrentAccount(session);
    if (account == null) return null;

    return AccountSummary(
      name: account.userProfile?.fullName ?? 'Baktaz Walker',
      cashBalance: account.wallet?.cashBalance ?? 0,
      connectBalance: account.wallet?.connectBalance ?? 0,
    );
  }

  Future<Profile?> getProfile(Session session) async {
    final Account? account = await getCurrentAccount(session);
    if (account == null) return null;

    return Profile(
      fullName: account.userProfile?.fullName ?? 'Baktaz Walker',
      gender: account.userInfo?.gender ?? Gender.unknown,
      email: account.userProfile?.email,
      mobileNumber: account.userInfo?.mobileNumber,
      birthday: account.userInfo?.birthday,
      updatedAt: account.userInfo?.updatedAt,
    );
  }

  Future<void> deleteAccount(Session session) async {
    final UuidValue? authUserId = session.authenticated?.authUserId;
    if (authUserId == null) {
      throw StateError('User not authenticated');
    }

    if (!AppConfig.accountDeletionEnabled) {
      throw StateError('Account deletion is disabled');
    }

    await session.db.transaction((Transaction transaction) async {
      final Account? account = await Account.db.findFirstRow(
        session,
        where: (AccountTable t) => t.authUserId.equals(authUserId),
        include: Account.include(
          userProfile: UserProfile.include(),
          userInfo: UserInfo.include(),
          wallet: Wallet.include(),
        ),
        transaction: transaction,
      );

      if (account != null) {
        await Account.db.deleteRow(session, account, transaction: transaction);
        if (account.wallet != null) {
          await Wallet.db.deleteRow(session, account.wallet!, transaction: transaction);
        }
        if (account.userInfo != null) {
          await UserInfo.db.deleteRow(session, account.userInfo!, transaction: transaction);
        }
        if (account.userProfile != null) {
          await UserProfile.db.deleteRow(session, account.userProfile!, transaction: transaction);
        }
      }

      final EmailAccount? emailAccount = await EmailAccount.db.findFirstRow(
        session,
        where: (EmailAccountTable t) => t.authUserId.equals(authUserId),
        transaction: transaction,
      );
      if (emailAccount != null) {
        await EmailAccount.db.deleteRow(session, emailAccount, transaction: transaction);
      }

      await AuthServices.instance.authUsers.delete(session, authUserId: authUserId, transaction: transaction);
      await _securityLogger.log(session, 'account_delete', authUserId: authUserId, transaction: transaction);
    });
  }
}
