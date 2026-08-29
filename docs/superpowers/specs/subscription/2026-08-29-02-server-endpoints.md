# Host Subscription Feature Spec — Server Endpoints

> **Document Version:** 1.1  
> **Date:** 2026-08-29  
> **Parent Spec:** `docs/superpowers/specs/account/subscription/2026-08-29-00-overview.md`  
> **Package:** `baktaz_server` (`lib/src/features/account/`)  

---

## 1. Directory Structure

```
baktaz_server/lib/src/features/account/
├── endpoint/
│   └── host_subscription_endpoint.dart
├── domain/
│   └── interface/
│       ├── i_host_subscription_repository.dart
│       └── i_voucher_repository.dart
├── data/
│   └── repository/
│       ├── host_subscription_repository.dart
│       └── voucher_repository.dart
├── data/
│   └── service/
│       └── hitpay_service.dart
├── webhook/
│   └── hitpay_webhook_endpoint.dart
└── setup/
    └── hitpay_plan_setup.dart          # NEW: One-time HitPay plan creation script
```

---

## 2. API Endpoint: `HostSubscriptionEndpoint`

### 2.1 `getPackages(Session session) -> List<SubscriptionPackage>`

```dart
@ServerMethod
Future<List<SubscriptionPackage>> getPackages(Session session) async {
  return SubscriptionPackage.db.findAll(
    session,
    where: (t) => t.isActive.equals(true),
    orderBy: (t) => [Ordering.asc(t.durationDays)],
  );
}
```

### 2.2 `checkout(Session session, String packageId, String? voucherCode) -> CheckoutResponse`

```dart
@ServerMethod
Future<CheckoutResponse> checkout(
  Session session,
  String packageId,
  String? voucherCode,
) async {
  // 1. Validate user auth
  // 2. Load package
  // 3. If voucherCode: validate voucher (active, not expired, not exhausted, user hasn't used, applies to package)
  // 4. Calculate final amount (apply discount for first charge only)
  // 5. Create/retrieve HitPay customer for user
  // 6. Create HitPay recurring billing via API (amount = finalAmount, startDate = now + trialDays if applicable)
  // 7. Create HostSubscription record with hitpayCustomerId, hitpaySubscriptionId
  // 8. If voucher used: increment usageCount, insert into user_voucher_usage
  // 9. Return { checkoutUrl, subscriptionId }
}
```

### 2.3 `validateVoucher(Session session, String voucherCode, String packageId) -> VoucherValidationResponse`

```dart
@ServerMethod
Future<VoucherValidationResponse> validateVoucher(
  Session session,
  String voucherCode,
  String packageId,
) async {
  // 1. Load voucher by code (case-insensitive)
  // 2. Check isActive, expiresAt, usageCap vs usageCount
  // 3. Check user hasn't already redeemed this voucher (UserVoucherUsage)
  // 4. Check voucher_plan junction: voucher applies to this package
  // 5. Calculate discount amount for this package's price
  // 6. Return { isValid, discountType, discountValue, finalPriceCentavos, errorMessage? }
}
```

### 2.4 `getCurrentSubscription(Session session) -> HostSubscription?`

```dart
@ServerMethod
Future<HostSubscription?> getCurrentSubscription(Session session) async {
  final userId = session.authenticated!.authUserId!;
  return HostSubscription.db.findFirstRow(
    session,
    where: (t) => t.userId.equals(userId),
    orderBy: (t) => [Ordering.desc(t.createdAt)],
  );
}
```

### 2.5 `cancelSubscription(Session session) -> HostSubscription`

```dart
@ServerMethod
Future<HostSubscription> cancelSubscription(Session session) async {
  // 1. Find active subscription for user
  // 2. Update status = 'cancelled', autoRenew = false
  // 3. Call HitPay API to cancel recurring billing
  // 4. Return updated record
}
```

### 2.6 `validateSubscriptionStatusForSettlement(UuidValue userId, DateTime challengeExpiresAt) -> bool`

```dart
Future<bool> validateSubscriptionStatusForSettlement(
  UuidValue userId,
  DateTime challengeExpiresAt,
) async {
  final sub = await HostSubscription.db.findFirstRow(
    session,
    where: (t) => t.userId.equals(userId) & t.status.equals('active'),
  );
  if (sub == null) return false;
  // STRICT POINT-IN-TIME CHECK
  return sub.expiresAt.isAfter(challengeExpiresAt);
}
```

---

## 3. Repository Interfaces

### 3.1 `IHostSubscriptionRepository`

```dart
abstract interface class IHostSubscriptionRepository {
  @LazySingleton(as: IHostSubscriptionRepository)
  
  TaskResult<List<SubscriptionPackage>> getPackages();
  TaskResult<CheckoutResponse> checkout({
    required String packageId,
    String? voucherCode,
  });
  TaskResult<VoucherValidationResponse> validateVoucher({
    required String voucherCode,
    required String packageId,
  });
  TaskResult<HostSubscription?> getCurrentSubscription();
  TaskResult<HostSubscription> cancelSubscription();
  TaskResult<bool> validateSubscriptionStatusForSettlement(
    UuidValue userId,
    DateTime challengeExpiresAt,
  );
}
```

### 3.2 `IVoucherRepository`

```dart
abstract interface class IVoucherRepository {
  @LazySingleton(as: IVoucherRepository)
  
  TaskResult<Voucher?> findByCode(String code);
  TaskResult<bool> hasUserRedeemed(UuidValue userId, UuidValue voucherId);
  TaskResult<Unit> recordRedemption(UuidValue userId, UuidValue voucherId);
  TaskResult<Unit> incrementUsageCount(UuidValue voucherId);
}
```

---

## 4. HitPay Service Integration

### `HitPayService` (`data/service/hitpay_service.dart`)

```dart
@LazySingleton
class HitPayService {
  final HttpClient _httpClient;
  final String _apiKey;
  final String _businessId;
  final String _baseUrl;
  final String _webhookSalt;

  // 1. Create customer: POST /v1/customer
  Future<HitPayCustomer> createOrGetCustomer({
    required String email,
    required String name,
    String? phone,
  });

  // 2. Create subscription plan: POST /v1/subscription-plan (one-time setup)
  Future<HitPaySubscriptionPlan> createSubscriptionPlan({
    required String name,
    required int durationDays,
    required int priceCentavos,
    required String currency,
    required String reference,
  });

  // 3. Create recurring billing: POST /v1/recurring-billing
  Future<HitPayRecurringBillingResponse> createRecurringBilling({
    required String planId,
    required String customerEmail,
    required String customerName,
    required DateTime startDate,
    required int amountCentavos,
    required String currency,
    required String redirectUrl,
    String? reference,
    List<String>? paymentMethods,
  });

  // 4. Cancel recurring billing: POST /v1/recurring-billing/cancel
  Future<void> cancelRecurringBilling(String subscriptionId);

  // 5. Validate webhook signature
  bool validateWebhook(String payload, String signature);

  // 6. Parse webhook payload
  HitPayWebhookEvent parseWebhook(String payload);
}
```

**Webhook Events:**
- `charge.created` → extend `HostSubscription.expiresAt` by `durationDays`
- `recurring_billing.subscription_updated` (status: cancelled/expired) → update local status

**Failed Charge Handling:** Local 24hr retry check before relying on webhook.

**Webhook Endpoint:** `POST /api/webhook/hitpay` (Relic)

---

## 5. HitPay Plan Setup Script

`setup/hitpay_plan_setup.dart` — One-time script run after seed migration:

```dart
Future<void> setupHitPayPlans() async {
  final packages = await SubscriptionPackage.db.findAll(session);
  for (final pkg in packages) {
    if (pkg.hitpayPlanId == null) {
      final plan = await _hitPayService.createSubscriptionPlan(
        name: pkg.name,
        durationDays: pkg.durationDays,
        priceCentavos: pkg.priceCentavos,
        currency: 'PHP',
        reference: pkg.id.toString(),
      );
      await SubscriptionPackage.db.updateRow(session, pkg.copyWith(hitpayPlanId: plan.id));
    }
  }
}
```

---

## 6. CheckoutResponse & VoucherValidationResponse

```yaml
class: CheckoutResponse
fields:
  checkoutUrl: String
  subscriptionId: UuidValue

class: VoucherValidationResponse
fields:
  isValid: bool
  discountType: String?
  discountValue: double?
  finalPriceCentavos: int?
  errorMessage: String?
```

---

## 7. Error Codes (unchanged)
