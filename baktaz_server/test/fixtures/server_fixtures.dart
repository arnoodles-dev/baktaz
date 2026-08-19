import 'package:baktaz_server/src/features/auth/domain/interface/i_admin_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

abstract final class ServerFixtures {
  // Test UUIDs
  static final UuidValue testAuthUserId = UuidValue.fromString('00000000-0000-4000-8000-000000000001');
  static final UuidValue testAdminAuthUserId = UuidValue.fromString('00000000-0000-4000-8000-000000000002');
  static final UuidValue testBlockedAuthUserId = UuidValue.fromString('00000000-0000-4000-8000-000000000003');
  static final UuidValue testAccountId = UuidValue.fromString('00000000-0000-4000-8000-000000000010');
  static final UuidValue testAdminAccountId = UuidValue.fromString('00000000-0000-4000-8000-000000000011');
  static final UuidValue testWalletId = UuidValue.fromString('00000000-0000-4000-8000-000000000020');
  static final UuidValue testUserInfoId = UuidValue.fromString('00000000-0000-4000-8000-000000000030');
  static final UuidValue testAddressId = UuidValue.fromString('00000000-0000-4000-8000-000000000040');

  // Scope collections
  static final Set<Scope> adminScopes = <Scope>{Scope.admin};
  static final Set<Scope> userScopes = <Scope>{};
  static final Set<Scope> customScopes = <Scope>{const Scope('user'), const Scope('custom')};

  // UserInfos
  static final UserInfo sampleUserInfo = UserInfo(
    id: testUserInfoId,
    gender: Gender.male,
    birthday: DateTime(1995, 5, 15),
    mobileNumber: '+1234567890',
  );

  // Profiles
  static final Profile sampleProfile = Profile(
    fullName: 'John Walker',
    gender: Gender.male,
    email: 'john@example.com',
    mobileNumber: '+1234567890',
    birthday: DateTime(1995, 5, 15),
  );

  static final Profile adminProfile = Profile(fullName: 'Admin User', gender: Gender.female, email: 'admin@baktaz.com');

  // Wallets & Transactions
  static final Wallet sampleWallet = Wallet(id: testWalletId, cashBalance: 250.75, connectBalance: 15);

  static final Wallet zeroWallet = Wallet(
    id: UuidValue.fromString('00000000-0000-4000-8000-000000000021'),
    cashBalance: 0,
    connectBalance: 0,
  );

  static final Wallet negativeWallet = Wallet(
    id: UuidValue.fromString('00000000-0000-4000-8000-000000000022'),
    cashBalance: -100,
    connectBalance: -5,
  );

  static final WalletTransactions depositTransaction = WalletTransactions(
    walletId: testWalletId,
    amount: 100,
    transactionDate: DateTime(2026, 1, 10),
    transactionType: TransactionType.credit,
  );

  static final WalletTransactions withdrawalTransaction = WalletTransactions(
    walletId: testWalletId,
    amount: 50,
    transactionDate: DateTime(2026, 1, 12),
    transactionType: TransactionType.debit,
  );

  // Accounts
  static final Account sampleAccount = Account(
    id: testAccountId,
    authUserId: testAuthUserId,
    userInfoId: testUserInfoId,
    walletId: testWalletId,
    wallet: sampleWallet,
    userInfo: sampleUserInfo,
  );

  static final Account adminAccount = Account(id: testAdminAccountId, authUserId: testAdminAuthUserId);

  // AuthUsers & UserProfiles
  static final AuthUserModel sampleAuthUser = AuthUserModel(
    id: testAuthUserId,
    createdAt: DateTime.now(),
    scopeNames: const <String>{},
    blocked: false,
  );

  static final AuthUserModel adminAuthUser = AuthUserModel(
    id: testAdminAuthUserId,
    createdAt: DateTime.now(),
    scopeNames: const <String>{'admin'},
    blocked: false,
  );

  static final AuthUserModel blockedAuthUser = AuthUserModel(
    id: testBlockedAuthUserId,
    createdAt: DateTime.now(),
    scopeNames: const <String>{},
    blocked: true,
  );

  static final UserProfileModel sampleUserProfileModel = UserProfileModel(
    authUserId: testAuthUserId,
    email: 'john@example.com',
    fullName: 'John Walker',
    userName: 'johnw',
  );

  static final UserProfileModel adminUserProfileModel = UserProfileModel(
    authUserId: testAdminAuthUserId,
    email: 'admin@baktaz.com',
    fullName: 'Admin User',
    userName: 'admin',
  );

  static final AdminUser sampleAdminUserRecord = (authUser: sampleAuthUser, userProfile: sampleUserProfileModel);

  static final AdminUser adminAdminUserRecord = (authUser: adminAuthUser, userProfile: adminUserProfileModel);

  // Addresses & Contacts
  static final Address sampleAddress = Address(
    id: testAddressId,
    label: 'Home',
    street: '123 Main St',
    locality: 'Metropolis',
    country: 'US',
    isDefault: true,
  );

  static final Contact sampleContact = Contact(
    accountId: testAccountId,
    mobileNumber: '+1234567890',
    email: 'john@example.com',
  );
}
