import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

final class AccountEndpoint extends Endpoint {
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
}
