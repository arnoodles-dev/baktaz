# Host Subscription Implementation Plan — Task 4: Server Endpoint + Repositories

> **Parent:** `docs/superpowers/plans/account/subscription/2026-08-29-00-plan-overview.md`  
> **Spec:** `docs/superpowers/specs/account/subscription/2026-08-29-02-server-endpoints.md`

---

### Task 4: Server Endpoint + Repositories

**Files:**
- Create: `baktaz_server/lib/src/features/account/domain/interface/i_host_subscription_repository.dart`
- Create: `baktaz_server/lib/src/features/account/domain/interface/i_voucher_repository.dart`
- Create: `baktaz_server/lib/src/features/account/data/repository/host_subscription_repository.dart`
- Create: `baktaz_server/lib/src/features/account/data/repository/voucher_repository.dart`
- Create: `baktaz_server/lib/src/features/account/endpoint/host_subscription_endpoint.dart`

**Interfaces:**
- Consumes: Generated `SubscriptionPackage`, `HostSubscription`, `Voucher`, `VoucherPlan` from Task 2
- Produces: `HostSubscriptionEndpoint`, `HostSubscriptionRepository`, `VoucherRepository`

- [ ] **Step 1: Write i_host_subscription_repository.dart**

```dart
abstract interface class IHostSubscriptionRepository {
  TaskResult<List<SubscriptionPackage>> getPackages(Session session);
  TaskResult<CheckoutResponse> checkout({
    required String packageId,
    String? voucherCode,
  });
  TaskResult<VoucherValidationResponse> validateVoucher({
    required String voucherCode,
    required String packageId,
  });
  TaskResult<HostSubscription?> getCurrentSubscription(Session session);
  TaskResult<HostSubscription> cancelSubscription(Session session);
  TaskResult<bool> validateSubscriptionStatusForSettlement(
    Session session,
    UuidValue userId,
    DateTime challengeExpiresAt,
  );
}
```

- [ ] **Step 2: Write i_voucher_repository.dart**

```dart
abstract interface class IVoucherRepository {
  TaskResult<Voucher?> findByCode(Session session, String code);
  TaskResult<bool> hasUserRedeemed(Session session, UuidValue userId, UuidValue voucherId);
  TaskResult<void> recordRedemption(Session session, UuidValue userId, UuidValue voucherId);
  TaskResult<void> incrementUsageCount(Session session, UuidValue voucherId);
}
```

- [ ] **Step 3: Write voucher_repository.dart**

```dart
@LazySingleton(as: IVoucherRepository)
class VoucherRepository implements IVoucherRepository {
  @override
  TaskResult<Voucher?> findByCode(Session session, String code) =>
      TaskResult.tryCatch(() async {
        return await Voucher.db.findFirstRow(
          session,
          where: (t) => t.code.equals(code),
        );
      }, onError: (e, s) => Failure.serverError(e.toString()));

  @override
  TaskResult<bool> hasUserRedeemed(Session session, UuidValue userId, UuidValue voucherId) =>
      TaskResult.tryCatch(() async {
        return false;
      }, onError: (e, s) => Failure.serverError(e.toString()));

  @override
  TaskResult<void> recordRedemption(Session session, UuidValue userId, UuidValue voucherId) =>
      TaskResult.tryCatch(() async {}, onError: (e, s) => Failure.serverError(e.toString()));

  @override
  TaskResult<void> incrementUsageCount(Session session, UuidValue voucherId) =>
      TaskResult.tryCatch(() async {
        final current = await Voucher.db.findById(session, voucherId);
        if (current == null) return;
        await Voucher.db.updateRow(
          session,
          current.copyWith(usageCount: current.usageCount + 1),
        );
      }, onError: (e, s) => Failure.serverError(e.toString()));
}
```

- [ ] **Step 4: Write host_subscription_repository.dart**

```dart
@LazySingleton(as: IHostSubscriptionRepository)
class HostSubscriptionRepository implements IHostSubscriptionRepository {
  @override
  TaskResult<List<SubscriptionPackage>> getPackages(Session session) =>
      TaskResult.tryCatch(() async {
        return await SubscriptionPackage.db.find(
          session,
          where: (t) => t.isActive.equals(true),
          orderBy: (t) => [Ordering.asc(t.durationDays)],
        );
      }, onError: (e, s) => Failure.serverError(e.toString()));

  @override
  TaskResult<CheckoutResponse> checkout({
    required String packageId,
    String? voucherCode,
  }) {
    throw UnimplementedError('Implemented in Task 5 with HitPayService');
  }

  @override
  TaskResult<VoucherValidationResponse> validateVoucher({
    required String voucherCode,
    required String packageId,
  }) {
    throw UnimplementedError('Implemented in Task 5');
  }

  @override
  TaskResult<HostSubscription?> getCurrentSubscription(Session session) =>
      TaskResult.tryCatch(() async {
        final userId = session.authenticated!.authUserId!;
        return await HostSubscription.db.findFirstRow(
          session,
          where: (t) => t.userId.equals(userId),
          orderBy: (t) => [Ordering.desc(t.createdAt)],
        );
      }, onError: (e, s) => Failure.serverError(e.toString()));

  @override
  TaskResult<HostSubscription> cancelSubscription(Session session) =>
      TaskResult.tryCatch(() async {
        final userId = session.authenticated!.authUserId!;
        final sub = await HostSubscription.db.findFirstRow(
          session,
          where: (t) => t.userId.equals(userId) & t.status.equals('active'),
        );
        if (sub == null) throw ApiException(message: 'No active subscription', code: ApiExceptionCode.badRequest);
        final cancelled = sub.copyWith(status: 'cancelled', autoRenew: false);
        await HostSubscription.db.updateRow(session, cancelled);
        return cancelled;
      }, onError: (e, s) => Failure.serverError(e.toString()));

  @override
  TaskResult<bool> validateSubscriptionStatusForSettlement(
    Session session,
    UuidValue userId,
    DateTime challengeExpiresAt,
  ) => TaskResult.tryCatch(() async {
      final sub = await HostSubscription.db.findFirstRow(
        session,
        where: (t) => t.userId.equals(userId) & t.status.equals('active'),
      );
      if (sub == null) return false;
      return sub.expiresAt.isAfter(challengeExpiresAt);
    }, onError: (e, s) => Failure.serverError(e.toString()));
}
```

- [ ] **Step 5: Write host_subscription_endpoint.dart**

```dart
final class HostSubscriptionEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<SubscriptionPackage>> getPackages(Session session) async {
    final repo = getIt<IHostSubscriptionRepository>();
    return (await repo.getPackages(session)).getOrElse((l) => throw l);
  }

  Future<VoucherValidationResponse> validateVoucher(
    Session session,
    String voucherCode,
    String packageId,
  ) async {
    final repo = getIt<IHostSubscriptionRepository>();
    return (await repo.validateVoucher(voucherCode: voucherCode, packageId: packageId))
        .getOrElse((l) => throw l);
  }

  Future<CheckoutResponse> checkout(
    Session session,
    String packageId,
    String? voucherCode,
  ) async {
    final repo = getIt<IHostSubscriptionRepository>();
    return (await repo.checkout(packageId: packageId, voucherCode: voucherCode))
        .getOrElse((l) => throw l);
  }

  Future<HostSubscription?> getCurrentSubscription(Session session) async {
    final repo = getIt<IHostSubscriptionRepository>();
    return (await repo.getCurrentSubscription(session)).getOrElse((l) => throw l);
  }

  Future<HostSubscription> cancelSubscription(Session session) async {
    final repo = getIt<IHostSubscriptionRepository>();
    return (await repo.cancelSubscription(session)).getOrElse((l) => throw l);
  }
}
```

- [ ] **Step 6: Commit**

```bash
git add lib/src/features/account/{domain,endpoint,data} && \
  git commit -m "feat: add host subscription endpoint and repositories"
```
