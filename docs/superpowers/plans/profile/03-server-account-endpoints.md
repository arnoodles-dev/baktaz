# Task 3: Server Account Endpoints & Repository

**Files:**
- Create: `baktaz_server/lib/src/features/account/domain/interface/i_account_repository.dart`
- Create: `baktaz_server/lib/src/features/account/data/repository/account_repository.dart`
- Create: `baktaz_server/lib/src/features/account/data/repository/account_challenge_stats_repository.dart`
- Modify: `baktaz_server/lib/src/features/account/endpoint/account_endpoint.dart`
- Create: `baktaz_server/test/integration/features/account/account_endpoint_test.dart`

**Interfaces:**
- Consumes: `Session`, `UserInfo`, `Account`, `UpdateProfileRequest`
- Produces: `IAccountRepository` with 5 methods, `AccountRepository` impl, `AccountEndpoint` thin wrapper

---

- [ ] **Step 1: Create IAccountRepository interface**

Create `baktaz_server/lib/src/features/account/domain/interface/i_account_repository.dart`:
```dart
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

abstract interface class IAccountRepository {
  Future<AccountSummary?> getAccountSummary(Session session);
  Future<Profile?> getProfile(Session session);
  Future<Profile> updateProfile(Session session, UpdateProfileRequest request);
  Future<AvatarUploadUrl> getAvatarUploadUrl(Session session);
  Future<List<String>> getLinkedProviders(Session session);
}
```

---

- [ ] **Step 2: Implement AccountRepository**

Create `baktaz_server/lib/src/features/account/data/repository/account_repository.dart`:
```dart
import 'package:baktaz_server/src/features/account/data/repository/account_challenge_stats_repository.dart';
import 'package:baktaz_server/src/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_server/src/features/account/domain/interface/i_account_challenge_stats_repository.dart';
import 'package:baktaz_server/src/features/security/data/service/security_logger.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

@LazySingleton(as: IAccountRepository)
final class AccountRepository implements IAccountRepository {
  AccountRepository(
    this._securityLogger,
    this._challengeStatsRepo,
  );

  final SecurityLogger _securityLogger;
  final IAccountChallengeStatsRepository _challengeStatsRepo;

  @override
  Future<AccountSummary?> getAccountSummary(Session session) async {
    final Account? account = await _getCurrentAccount(session);
    if (account == null) return null;

    final UserInfo? userInfo = account.userInfo;
    final String firstName = userInfo?.firstName ?? account.userProfile?.firstName ?? '';
    final String lastName = userInfo?.lastName ?? account.userProfile?.lastName ?? '';
    final String displayName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    final AccountChallengeStats stats = await _challengeStatsRepo.computeChallengeStats(session);

    return AccountSummary(
      name: displayName.isNotEmpty ? displayName : account.userProfile?.fullName ?? 'Baktaz Walker',
      imageUrl: userInfo?.avatarUrl != null ? Uri.parse(userInfo!.avatarUrl!) : null,
      cashBalance: account.wallet?.cashBalance ?? 0,
      connectBalance: account.wallet?.connectBalance ?? 0,
      memberSince: account.createdAt,
      totalChallengeSteps: stats.totalChallengeSteps,
      challengesJoined: stats.challengesJoined,
      challengesWon: stats.challengesWon,
      winRatePercentage: stats.winRatePercentage,
    );
  }

  @override
  Future<Profile?> getProfile(Session session) async {
    final Account? account = await _getCurrentAccount(session);
    if (account == null) return null;

    final UserInfo? userInfo = account.userInfo;
    final UserProfile? userProfile = account.userProfile;

    return Profile(
      firstName: userInfo?.firstName ?? '',
      lastName: userInfo?.lastName ?? '',
      username: userInfo?.username ?? '',
      gender: userInfo?.gender ?? Gender.unknown,
      email: userProfile?.email,
      mobileNumber: userInfo?.mobileNumber,
      birthday: userInfo?.birthday,
      age: userInfo?.birthday?.value.age,
      imageUrl: userInfo?.avatarUrl != null ? Uri.parse(userInfo!.avatarUrl!) : null,
      updatedAt: userInfo?.updatedAt,
    );
  }

  @override
  Future<Profile> updateProfile(Session session, UpdateProfileRequest request) async {
    final UuidValue? authUserId = session.authenticated?.authUserId;
    if (authUserId == null) {
      throw ApiException(message: 'User not authenticated', code: ApiExceptionCode.unauthenticated);
    }

    final Account? account = await _getCurrentAccount(session);
    if (account == null) {
      throw ApiException(message: 'Account not found', code: ApiExceptionCode.notFound);
    }
    final UserInfo? userInfo = account.userInfo;
    if (userInfo == null) {
      throw ApiException(message: 'User info not found', code: ApiExceptionCode.notFound);
    }

    final UserInfo updated = userInfo.copyWith(
      firstName: request.firstName,
      lastName: request.lastName,
      mobileNumber: request.mobileNumber,
      birthday: request.birthday,
      avatarUrl: request.avatarUrl ?? userInfo.avatarUrl,
      updatedAt: DateTime.now(),
    );
    await UserInfo.db.updateRow(session, updated);

    // Sync UserProfile.fullName if it differs
    final UserProfile? userProfile = account.userProfile;
    if (userProfile != null) {
      final String newFullName = [request.firstName, request.lastName].where((s) => s.isNotEmpty).join(' ').trim();
      if (newFullName.isNotEmpty && userProfile.fullName != newFullName) {
        await UserProfile.db.updateRow(
          session,
          userProfile.copyWith(fullName: newFullName, updatedAt: DateTime.now()),
        );
      }
    }

    await _securityLogger.log(
      session,
      'update_profile',
      authUserId: authUserId,
    );

    return (await getProfile(session))!;
  }

  @override
  Future<AvatarUploadUrl> getAvatarUploadUrl(Session session) async {
    final UuidValue? authUserId = session.authenticated?.authUserId;
    if (authUserId == null) {
      throw ApiException(message: 'User not authenticated', code: ApiExceptionCode.unauthenticated);
    }

    final String fileKey = 'avatars/$authUserId/${DateTime.now().millisecondsSinceEpoch}.webp';
    final String uploadUrl = await session.server.fileRepository.getUploadUrl(
      fileKey,
      duration: const Duration(minutes: 10),
    );
    final String permanentUrl = await session.server.fileRepository.getPublicUrl(fileKey);

    return AvatarUploadUrl(
      uploadUrl: uploadUrl,
      permanentUrl: permanentUrl,
      fileKey: fileKey,
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    );
  }

  @override
  Future<List<String>> getLinkedProviders(Session session) async {
    final UuidValue? authUserId = session.authenticated?.authUserId;
    if (authUserId == null) return <String>[];

    // Query linked auth methods from serverpod_auth_idp tables
    // For MVP, return static list based on available data
    final List<String> linked = <String>[];
    // TODO: Query actual linked providers from auth tables
    return linked;
  }

  Future<Account?> _getCurrentAccount(Session session) async {
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
}
```

---

- [ ] **Step 3: Implement AccountChallengeStatsRepository stub**

Create `baktaz_server/lib/src/features/account/data/repository/account_challenge_stats_repository.dart`:
```dart
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';

abstract interface class IAccountChallengeStatsRepository {
  Future<AccountChallengeStats> computeChallengeStats(Session session);
}

@LazySingleton(as: IAccountChallengeStatsRepository)
final class AccountChallengeStatsRepository implements IAccountChallengeStatsRepository {
  @override
  Future<AccountChallengeStats> computeChallengeStats(Session session) async {
    // MVP Stub: Return 0 stats until Challenge domain tables are built
    return AccountChallengeStats(
      totalChallengeSteps: 0,
      challengesJoined: 0,
      challengesWon: 0,
      winRatePercentage: 0.0,
    );
  }
}
```

---

- [ ] **Step 4: Update AccountEndpoint as thin wrapper**

Modify `baktaz_server/lib/src/features/account/endpoint/account_endpoint.dart`:
```dart
import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_server/src/features/security/data/service/security_logger.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';

final class AccountEndpoint extends Endpoint {
  AccountEndpoint([SecurityLogger? securityLogger])
    : _accountRepo = getIt.isRegistered<IAccountRepository>() 
        ? getIt<IAccountRepository>() 
        : AccountRepository(),
      _securityLogger = securityLogger ?? (getIt.isRegistered<SecurityLogger>() ? getIt<SecurityLogger>() : SecurityLogger());

  final IAccountRepository _accountRepo;
  final SecurityLogger _securityLogger;

  @override
  bool get requireLogin => true;

  Future<AccountSummary?> getAccountSummary(Session session) async {
    return _accountRepo.getAccountSummary(session);
  }

  Future<Profile?> getProfile(Session session) async {
    return _accountRepo.getProfile(session);
  }

  Future<Profile> updateProfile(Session session, UpdateProfileRequest request) async {
    return _accountRepo.updateProfile(session, request);
  }

  Future<AvatarUploadUrl> getAvatarUploadUrl(Session session) async {
    return _accountRepo.getAvatarUploadUrl(session);
  }

  Future<List<String>> getLinkedProviders(Session session) async {
    return _accountRepo.getLinkedProviders(session);
  }
}
```

---

- [ ] **Step 5: Run Serverpod codegen**

Run:
```bash
cd /Users/Arnold/Projects/baktaz
melos run build_runner
cd baktaz_server && serverpod generate
```
Expected: `baktaz_client` regenerated with new endpoint signatures and models.

---

- [ ] **Step 6: Write integration tests**

Create `baktaz_server/test/integration/features/account/account_endpoint_test.dart`:
```dart
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';
import 'package:baktaz_client/baktaz_client.dart';

void main() {
  withServerpod('AccountEndpoint Tests', (run, session) {
    final AccountEndpoint endpoint = AccountEndpoint();

    group('getAccountSummary', () {
      test('returns memberSince from Account.createdAt', () async {
        final Account account = await Account.db.insertRow(session, Account(
          authUserId: session.authenticated!.userId,
          createdAt: DateTime(2024, 1, 15),
        ));
        final AccountSummary? summary = await endpoint.getAccountSummary(session);
        expect(summary?.memberSince, equals(DateTime(2024, 1, 15)));
      });

      test('returns challenge stats from repository', () async {
        final AccountSummary? summary = await endpoint.getAccountSummary(session);
        expect(summary?.totalChallengeSteps, equals(0));
        expect(summary?.winRatePercentage, equals(0.0));
      });
    });

    group('updateProfile', () {
      test('updates firstName and lastName', () async {
        final UserInfo userInfo = await UserInfo.db.insertRow(session, UserInfo(
          firstName: 'Old',
          lastName: 'Name',
          username: 'oldname',
          gender: Gender.unknown,
        ));
        final Profile updated = await endpoint.updateProfile(session, UpdateProfileRequest(
          firstName: 'New',
          lastName: 'Name',
        ));
        expect(updated.firstName, equals('New'));
        expect(updated.lastName, equals('Name'));
      });

      test('throws notFound when userInfo does not exist', () async {
        expect(
          () => endpoint.updateProfile(session, UpdateProfileRequest(firstName: 'Test', lastName: 'User')),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', equals(ApiExceptionCode.notFound))),
        );
      });

      test('updates avatarUrl', () async {
        final Profile updated = await endpoint.updateProfile(session, UpdateProfileRequest(
          firstName: 'Test',
          lastName: 'User',
          avatarUrl: 'https://example.com/avatar.webp',
        ));
        expect(updated.imageUrl, isNotNull);
      });
    });

    group('getAvatarUploadUrl', () {
      test('returns valid presigned URL with correct file key', () async {
        final AvatarUploadUrl result = await endpoint.getAvatarUploadUrl(session);
        expect(result.uploadUrl, isNotEmpty);
        expect(result.fileKey, startsWith('avatars/'));
        expect(result.permanentUrl, isNotEmpty);
        expect(result.expiresAt, isAfter(DateTime.now()));
      });
    });
  });
}
```

---

- [ ] **Step 6: Run integration tests**

Run:
```bash
cd /Users/Arnold/Projects/baktaz/baktaz_server
fvm dart test test/integration/features/account/account_endpoint_test.dart --concurrency=1
```
Expected: All tests PASS (requires Docker/Postgres).

---

- [ ] **Step 7: Commit endpoint & repository changes**

```bash
cd /Users/Arnold/Projects/baktaz
git add baktaz_server/lib/src/features/account/ baktaz_client/ baktaz_server/test/integration/features/account/
git commit -m "feat(server): add IAccountRepository & AccountRepository; thin AccountEndpoint wrapper"
```
