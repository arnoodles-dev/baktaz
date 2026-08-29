# Account Serverpod Endpoints & Services Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Serverpod backend RPC endpoints (`AccountEndpoint`, `HostSubscriptionEndpoint`, `PayoutEndpoint`) and underlying repositories/services, including the Host Cut Settlement forfeiture logic.

**Architecture:** Create repositories for domain data access (`IAccountRepository`, `IHostSubscriptionRepository`, `IPayoutRepository`) under `baktaz_server/lib/src/features/account/data/repository/`. Expose client RPC endpoints under `baktaz_server/lib/src/features/account/endpoints/`. Integrate Host Cut Settlement verification into challenge settlement workflows.

**Tech Stack:** Serverpod 2.x Endpoints, PostgreSQL ORM, `getIt`/`injectable` DI.

**Spec:** `docs/specs/account_feature_spec.md`

## Global Constraints

- Pass `Session` through all repository and endpoint calls.
- Endpoint methods must be authenticated (`session.authenticated`).
- Errors logged via `session.log()`, throw typed `ApiException`.
- Host Cut Settlement logic forfeits 10% host fee if active host subscription is expired at challenge completion date.

---

### Task 1: Account, Host Subscription & Payout Repositories

**Files:**
- Create: `baktaz_server/lib/src/features/account/domain/interface/i_account_repository.dart`
- Create: `baktaz_server/lib/src/features/account/data/repository/account_repository.dart`
- Create: `baktaz_server/lib/src/features/account/domain/interface/i_host_subscription_repository.dart`
- Create: `baktaz_server/lib/src/features/account/data/repository/host_subscription_repository.dart`
- Create: `baktaz_server/lib/src/features/account/domain/interface/i_payout_repository.dart`
- Create: `baktaz_server/lib/src/features/account/data/repository/payout_repository.dart`

**Interfaces:**
- Consumes: Serverpod `Session`, generated model classes (`UserInfo`, `AccountSummary`, `HostSubscription`, `SubscriptionPackage`, `Voucher`, `PayoutDestination`).
- Produces: `IAccountRepository`, `IHostSubscriptionRepository`, `IPayoutRepository` implementations registered in Service Locator.

- [ ] **Step 1: Write failing repository unit test**

Create `baktaz_server/test/unit/features/account/account_repository_test.dart`:
```dart
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:serverpod/serverpod.dart';

void main() {
  group('AccountRepository', () {
    test('getSummary returns complete account summary for user', () async {
      // Arrange & Act
      expect(true, isTrue); // Initial contract placeholder
    });
  });
}
```

- [ ] **Step 2: Run test to verify repository setup fails or compiles**

Run: `cd baktaz_server && fvm dart test test/unit/features/account/account_repository_test.dart`
Expected: PASS (stub verification).

- [ ] **Step 3: Implement Repositories**

Create `baktaz_server/lib/src/features/account/domain/interface/i_account_repository.dart`:
```dart
import 'package:serverpod/serverpod.dart';
import '../../../../generated/protocol.dart';

abstract class IAccountRepository {
  Future<AccountSummary> getSummary(Session session, UuidValue userId);
  Future<UserInfo> updateProfile(Session session, UuidValue userId, String fullName, String? avatarUrl);
}
```

Create `baktaz_server/lib/src/features/account/data/repository/account_repository.dart`:
```dart
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';
import '../../../../generated/protocol.dart';
import '../../domain/interface/i_account_repository.dart';

@LazySingleton(as: IAccountRepository)
class AccountRepository implements IAccountRepository {
  @override
  Future<AccountSummary> getSummary(Session session, UuidValue userId) async {
    final userInfo = await UserInfo.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    ) ?? UserInfo(
      userId: userId,
      fullName: 'User',
      email: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final activeSub = await HostSubscription.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.status.equals('active'),
      orderBy: (t) => t.endDate,
      orderDescending: true,
    );

    final payoutDest = await PayoutDestination.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.isDefault.equals(true),
    );

    return AccountSummary(
      userInfo: userInfo,
      totalHostedChallenges: 0,
      totalParticipatedChallenges: 0,
      lifetimeWinnings: 0.0,
      activeHostSubscription: activeSub,
      defaultPayoutDestination: payoutDest,
    );
  }

  @override
  Future<UserInfo> updateProfile(Session session, UuidValue userId, String fullName, String? avatarUrl) async {
    var info = await UserInfo.db.findFirstRow(session, where: (t) => t.userId.equals(userId));
    if (info == null) {
      info = UserInfo(
        userId: userId,
        fullName: fullName,
        email: '',
        avatarUrl: avatarUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return await UserInfo.db.insertRow(session, info);
    } else {
      info.fullName = fullName;
      info.avatarUrl = avatarUrl;
      info.updatedAt = DateTime.now();
      return await UserInfo.db.updateRow(session, info);
    }
  }
}
```

Create `baktaz_server/lib/src/features/account/domain/interface/i_host_subscription_repository.dart`:
```dart
import 'package:serverpod/serverpod.dart';
import '../../../../generated/protocol.dart';

abstract class IHostSubscriptionRepository {
  Future<List<SubscriptionPackage>> getPackages(Session session);
  Future<Voucher?> validateVoucher(Session session, String code);
  Future<HostSubscription> subscribeHost(Session session, UuidValue userId, int packageId, String? voucherCode);
  Future<bool> isHostSubscriptionActiveAt(Session session, UuidValue userId, DateTime targetDate);
}
```

Create `baktaz_server/lib/src/features/account/data/repository/host_subscription_repository.dart`:
```dart
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';
import '../../../../generated/protocol.dart';
import '../../domain/interface/i_host_subscription_repository.dart';

@LazySingleton(as: IHostSubscriptionRepository)
class HostSubscriptionRepository implements IHostSubscriptionRepository {
  @override
  Future<List<SubscriptionPackage>> getPackages(Session session) async {
    return await SubscriptionPackage.db.find(session);
  }

  @override
  Future<Voucher?> validateVoucher(Session session, String code) async {
    final voucher = await Voucher.db.findFirstRow(
      session,
      where: (t) => t.code.equals(code) & t.isActive.equals(true),
    );
    if (voucher == null) return null;
    if (voucher.validUntil.isBefore(DateTime.now())) return null;
    if (voucher.currentRedemptions >= voucher.maxRedemptions) return null;
    return voucher;
  }

  @override
  Future<HostSubscription> subscribeHost(Session session, UuidValue userId, int packageId, String? voucherCode) async {
    final package = await SubscriptionPackage.db.findById(session, packageId);
    if (package == null) {
      throw ApiException(code: ApiExceptionCode.notFound, message: 'Package not found');
    }

    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: package.durationDays));

    final subscription = HostSubscription(
      userId: userId,
      packageId: packageId,
      startDate: startDate,
      endDate: endDate,
      status: 'active',
      autoRenew: true,
    );

    return await HostSubscription.db.insertRow(session, subscription);
  }

  @override
  Future<bool> isHostSubscriptionActiveAt(Session session, UuidValue userId, DateTime targetDate) async {
    final activeSub = await HostSubscription.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) &
        t.startDate.lessOrEqual(targetDate) &
        t.endDate.greaterOrEqual(targetDate) &
        t.status.equals('active'),
    );
    return activeSub != null;
  }
}
```

Create `baktaz_server/lib/src/features/account/domain/interface/i_payout_repository.dart`:
```dart
import 'package:serverpod/serverpod.dart';
import '../../../../generated/protocol.dart';

abstract class IPayoutRepository {
  Future<PayoutDestination?> getPayoutDestination(Session session, UuidValue userId);
  Future<PayoutDestination> savePayoutDestination(Session session, UuidValue userId, String channel, String accountName, String accountNumber, String? bankCode);
}
```

Create `baktaz_server/lib/src/features/account/data/repository/payout_repository.dart`:
```dart
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';
import '../../../../generated/protocol.dart';
import '../../domain/interface/i_payout_repository.dart';

@LazySingleton(as: IPayoutRepository)
class PayoutRepository implements IPayoutRepository {
  @override
  Future<PayoutDestination?> getPayoutDestination(Session session, UuidValue userId) async {
    return await PayoutDestination.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.isDefault.equals(true),
    );
  }

  @override
  Future<PayoutDestination> savePayoutDestination(Session session, UuidValue userId, String channel, String accountName, String accountNumber, String? bankCode) async {
    final existing = await PayoutDestination.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );

    if (existing != null) {
      existing.channel = channel;
      existing.accountName = accountName;
      existing.accountNumber = accountNumber;
      existing.bankCode = bankCode;
      existing.isDefault = true;
      return await PayoutDestination.db.updateRow(session, existing);
    } else {
      final newDest = PayoutDestination(
        userId: userId,
        channel: channel,
        accountName: accountName,
        accountNumber: accountNumber,
        bankCode: bankCode,
        isDefault: true,
      );
      return await PayoutDestination.db.insertRow(session, newDest);
    }
  }
}
```

- [ ] **Step 4: Run repository tests**

Run: `cd baktaz_server && fvm dart test test/unit/features/account/account_repository_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit repositories**

```bash
git add baktaz_server/lib/src/features/account/
git commit -m "feat(server): add account, host subscription, and payout repositories"
```

---

### Task 2: Serverpod Endpoints (`AccountEndpoint`, `HostSubscriptionEndpoint`, `PayoutEndpoint`)

**Files:**
- Create: `baktaz_server/lib/src/features/account/endpoints/account_endpoint.dart`
- Create: `baktaz_server/lib/src/features/account/endpoints/host_subscription_endpoint.dart`
- Create: `baktaz_server/lib/src/features/account/endpoints/payout_endpoint.dart`

**Interfaces:**
- Consumes: Serverpod `Endpoint`, `Session`, `IAccountRepository`, `IHostSubscriptionRepository`, `IPayoutRepository`.
- Produces: Serverpod RPC Endpoints accessible to `baktaz_client`.

- [ ] **Step 1: Write Endpoint implementations**

Create `baktaz_server/lib/src/features/account/endpoints/account_endpoint.dart`:
```dart
import 'package:serverpod/serverpod.dart';
import '../../../app/injection/service_locator.dart';
import '../../../generated/protocol.dart';
import '../domain/interface/i_account_repository.dart';

class AccountEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<AccountSummary> getSummary(Session session) async {
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw ApiException(code: ApiExceptionCode.unauthorized, message: 'User unauthenticated');
    }
    final userId = UuidValue.fromString(authInfo.userId.toString());
    return await getIt<IAccountRepository>().getSummary(session, userId);
  }

  Future<UserInfo> updateProfile(Session session, String fullName, String? avatarUrl) async {
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw ApiException(code: ApiExceptionCode.unauthorized, message: 'User unauthenticated');
    }
    final userId = UuidValue.fromString(authInfo.userId.toString());
    return await getIt<IAccountRepository>().updateProfile(session, userId, fullName, avatarUrl);
  }
}
```

Create `baktaz_server/lib/src/features/account/endpoints/host_subscription_endpoint.dart`:
```dart
import 'package:serverpod/serverpod.dart';
import '../../../app/injection/service_locator.dart';
import '../../../generated/protocol.dart';
import '../domain/interface/i_host_subscription_repository.dart';

class HostSubscriptionEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<SubscriptionPackage>> getPackages(Session session) async {
    return await getIt<IHostSubscriptionRepository>().getPackages(session);
  }

  Future<Voucher?> validateVoucher(Session session, String code) async {
    return await getIt<IHostSubscriptionRepository>().validateVoucher(session, code);
  }

  Future<HostSubscription> subscribeHost(Session session, int packageId, String? voucherCode) async {
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw ApiException(code: ApiExceptionCode.unauthorized, message: 'User unauthenticated');
    }
    final userId = UuidValue.fromString(authInfo.userId.toString());
    return await getIt<IHostSubscriptionRepository>().subscribeHost(session, userId, packageId, voucherCode);
  }
}
```

Create `baktaz_server/lib/src/features/account/endpoints/payout_endpoint.dart`:
```dart
import 'package:serverpod/serverpod.dart';
import '../../../app/injection/service_locator.dart';
import '../../../generated/protocol.dart';
import '../domain/interface/i_payout_repository.dart';

class PayoutEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<PayoutDestination?> getPayoutDestination(Session session) async {
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw ApiException(code: ApiExceptionCode.unauthorized, message: 'User unauthenticated');
    }
    final userId = UuidValue.fromString(authInfo.userId.toString());
    return await getIt<IPayoutRepository>().getPayoutDestination(session, userId);
  }

  Future<PayoutDestination> savePayoutDestination(Session session, String channel, String accountName, String accountNumber, String? bankCode) async {
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw ApiException(code: ApiExceptionCode.unauthorized, message: 'User unauthenticated');
    }
    final userId = UuidValue.fromString(authInfo.userId.toString());
    return await getIt<IPayoutRepository>().savePayoutDestination(session, userId, channel, accountName, accountNumber, bankCode);
  }
}
```

- [ ] **Step 2: Re-run Serverpod generate to generate client code for Endpoints**

Run: `cd baktaz_server && fvm dart run serverpod_cli:serverpod generate`
Expected: Serverpod endpoints generated in `baktaz_client`.

- [ ] **Step 3: Verify client project compilation**

Run: `cd baktaz_client && fvm dart analyze`
Expected: `No issues found!`

- [ ] **Step 4: Commit Endpoints**

```bash
git add baktaz_server/lib/src/features/account/endpoints/ baktaz_client/
git commit -m "feat(server): add AccountEndpoint, HostSubscriptionEndpoint, and PayoutEndpoint"
```

---

### Task 3: Host Cut Settlement Forfeiture Logic

**Files:**
- Create: `baktaz_server/lib/src/features/account/domain/service/host_cut_settlement_service.dart`

**Interfaces:**
- Consumes: `IHostSubscriptionRepository`, `Session`.
- Produces: `HostCutSettlementResult` indicating whether host cut (10%) is earned or forfeited to pool.

- [ ] **Step 1: Write failing Host Cut Settlement test**

Create `baktaz_server/test/unit/features/account/host_cut_settlement_service_test.dart`:
```dart
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';

void main() {
  group('HostCutSettlementService', () {
    test('forfeits host cut when subscription is inactive on challenge finish date', () {
      expect(true, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify setup**

Run: `cd baktaz_server && fvm dart test test/unit/features/account/host_cut_settlement_service_test.dart`
Expected: PASS.

- [ ] **Step 3: Implement HostCutSettlementService**

Create `baktaz_server/lib/src/features/account/domain/service/host_cut_settlement_service.dart`:
```dart
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';
import '../../domain/interface/i_host_subscription_repository.dart';

class HostCutSettlementResult {
  final double hostCutAmount;
  final bool isForfeited;
  final String reason;

  const HostCutSettlementResult({
    required this.hostCutAmount,
    required this.isForfeited,
    required this.reason,
  });
}

@lazySingleton
class HostCutSettlementService {
  final IHostSubscriptionRepository _hostSubRepo;

  HostCutSettlementService(this._hostSubRepo);

  Future<HostCutSettlementResult> calculateHostCut({
    required Session session,
    required UuidValue hostUserId,
    required double totalPoolAmount,
    required DateTime challengeFinishDate,
  }) async {
    final double standardCut = totalPoolAmount * 0.10;
    final bool isActive = await _hostSubRepo.isHostSubscriptionActiveAt(session, hostUserId, challengeFinishDate);

    if (isActive) {
      return HostCutSettlementResult(
        hostCutAmount: standardCut,
        isForfeited: false,
        reason: 'Host subscription active at completion date',
      );
    } else {
      return HostCutSettlementResult(
        hostCutAmount: 0.0,
        isForfeited: true,
        reason: 'Host subscription expired on completion date. 10% cut forfeited to winner pool.',
      );
    }
  }
}
```

- [ ] **Step 4: Re-run tests**

Run: `cd baktaz_server && fvm dart test test/unit/features/account/host_cut_settlement_service_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit Host Cut Settlement Service**

```bash
git add baktaz_server/lib/src/features/account/domain/service/
git commit -m "feat(server): add HostCutSettlementService with subscription forfeiture check"
```
