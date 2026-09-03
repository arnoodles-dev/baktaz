import 'package:baktaz_server/src/app/utils/username_utils.dart';
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
    final UserInfo userInfoDb = await _createUserInfo(session, userProfile, transaction);

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
    final (AuthUserModel, UserProfile, UserInfo, Wallet) seed = (authUser, userProfileDb, userInfoDb, walletDb);
    final Account insertedAccount = await _createAccount(session, seed, transaction);
    session.log('Account created: ${insertedAccount.toJson()}', level: LogLevel.debug);

    if (!authUser.scopes.contains(Scope.admin)) {
      await createEmailAccountLink(session, userProfile, transaction: transaction);
    }
  }

  static Future<void> createEmailAccountLink(
    Session session,
    UserProfileModel userProfile, {
    required Transaction transaction,
  }) async {
    final String? email = userProfile.email;
    if (email == null || email.isEmpty) return;
    final String emailLower = email.trim().toLowerCase();

    final EmailAccount? existing = await EmailAccount.db.findFirstRow(
      session,
      where: (EmailAccountTable t) => t.email.equals(emailLower),
      transaction: transaction,
    );
    if (existing != null) return; // Already linked

    await EmailAccount.db.insertRow(
      session,
      EmailAccount(
        authUserId: userProfile.authUserId,
        email: emailLower,
        passwordHash: 'placeholder-otp-only-no-password',
      ),
      transaction: transaction,
    );
  }

  static Future<UserInfo> _createUserInfo(
    Session session,
    UserProfileModel userProfile,
    Transaction transaction,
  ) async {
    final String email = userProfile.email ?? '';
    final String handle = UsernameUtils.generateUniqueHandle(userProfile.fullName, email);
    final UserInfo userInfo = UserInfo(
      userIdentifier: userProfile.authUserId,
      email: email,
      username: handle,
      firstName: userProfile.fullName,
      gender: Gender.unknown,
      createdAt: DateTime.now(),
    );
    return UserInfo.db.insertRow(session, userInfo, transaction: transaction);
  }

  static Future<Wallet> _createWallet(Session session, Transaction transaction) async {
    final Wallet wallet = Wallet(cashBalance: 0, connectBalance: 0);
    return Wallet.db.insertRow(session, wallet, transaction: transaction);
  }

  static Future<Account> _createAccount(
    Session session,
    (AuthUserModel, UserProfile, UserInfo, Wallet) seed,
    Transaction transaction,
  ) async {
    final (AuthUserModel authUser, UserProfile userProfileDb, UserInfo userInfoDb, Wallet walletDb) = seed;
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
