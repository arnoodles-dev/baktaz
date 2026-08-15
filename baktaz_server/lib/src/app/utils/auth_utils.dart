import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

final class AuthUtils {
  /// Called BEFORE the user profile is inserted into the database.
  /// If the user signed in with Google or Apple, Serverpod's auth providers
  /// will have already populated `userProfile.fullName` and `userProfile.imageUrl`
  /// with their data from the provider.
  static Future<UserProfileData> onBeforeUserProfileCreated(
    Session session,
    UuidValue authUserId,
    UserProfileData userProfile, {
    required Transaction transaction,
  }) async {
    session.log('onBeforeUserProfileCreated', level: LogLevel.debug);
    if (userProfile.userName == null && userProfile.email != null) {
      userProfile.userName = userProfile.email?.split('@').first;
    }

    if (userProfile.fullName == null && userProfile.userName != null) {
      userProfile.fullName = userProfile.userName;
    }

    session.log('UserProfile created for authUserId: $authUserId', level: LogLevel.debug);

    return userProfile;
  }

  /// Called AFTER the UserProfile is created in the database.
  /// Best place to initialize associated app records like Account, Wallet, etc.
  static Future<void> onAfterUserProfileCreated(
    Session session,
    UserProfileModel userProfile, {
    required Transaction transaction,
  }) async {
    session.log('onAfterUserProfileCreated', level: LogLevel.debug);

    // 1. Create default UserInfo
    final UserInfo userInfoDb = await _createUserInfo(session, transaction);

    // 2. Create default Wallet
    final Wallet walletDb = await _createWallet(session, transaction);

    // 3. Retrieve AuthUser to grab scope/blocked info
    final AuthUserModel authUser = await AuthServices.instance.authUsers.get(
      session,
      authUserId: userProfile.authUserId,
      transaction: transaction,
    );

    final UserProfile? userProfileDb = await UserProfile.db.findFirstRow(
      session,
      where: (UserProfileTable t) => t.authUserId.equals(userProfile.authUserId),
      transaction: transaction,
    );
    if (userProfileDb == null) {
      throw StateError('UserProfile not found for authUserId: ${userProfile.authUserId}');
    }

    // 4. Tie everything together in Account
    final Account insertedAccount = await _createAccount(
      session,
      authUser,
      userProfileDb,
      userInfoDb,
      walletDb,
      transaction,
    );
    session.log('Account created: ${insertedAccount.toJson()}', level: LogLevel.debug);
  }

  static Future<UserInfo> _createUserInfo(Session session, Transaction transaction) async {
    final UserInfo userInfo = UserInfo(gender: Gender.unknown);
    return UserInfo.db.insertRow(session, userInfo, transaction: transaction);
  }

  static Future<Wallet> _createWallet(Session session, Transaction transaction) async {
    final Wallet wallet = Wallet(cashBalance: 0, connectBalance: 0);
    return Wallet.db.insertRow(session, wallet, transaction: transaction);
  }

  static Future<Account> _createAccount(
    Session session,
    AuthUserModel authUser,
    UserProfile userProfileDb,
    UserInfo userInfoDb,
    Wallet walletDb,
    Transaction transaction,
  ) async {
    final Account account = Account(
      id: authUser.id,
      authUserId: authUser.id,
      userProfileId: userProfileDb.id,
      userInfoId: userInfoDb.id,
      walletId: walletDb.id,
      createdAt: authUser.createdAt,
    );
    return Account.db.insertRow(session, account, transaction: transaction);
  }
}
