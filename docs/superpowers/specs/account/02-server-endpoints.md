# Account Feature Architecture Spec — Server Endpoints

> **Document Version:** 1.0  
> **Date:** 2026-08-28  
> **Parent Spec:** `docs/superpowers/specs/account/00-overview.md`  
> **Package:** `baktaz_server` (`lib/src/features/account/`)  

---

## 1. Overview & Directory Structure

The backend account feature orchestrates profile metadata, host subscription transactions, HitPay saved payment tokens, and payout destination bindings. All logic is exposed via Serverpod `Endpoint` classes, relying on the Repository/Service layer pattern (`Endpoint → Repository → Service/DB`).

**Server Structure:** `lib/src/features/account/`
- `endpoint/` → Account API boundary.
- `data/repository/` → Business logic and data orchestration.
- `domain/interface/` → Repository contracts (`I<Name>Repository`).

---

## 2. API Endpoint Specifications

### 2.1 `AccountEndpoint` (`account_endpoint.dart`)
Manages general account metadata and profile modifications.

```dart
class AccountEndpoint extends Endpoint {
  Future<AccountSummary> getAccountSummary(Session session) async {...}
  Future<UserInfo> getProfile(Session session) async {...}
  Future<UserInfo> updateProfile(Session session, {required String fullName, required String username, String? avatarUrl}) async {...}
  Future<void> deleteAccount(Session session) async {...}
}
```

- `getAccountSummary`: Pulls joined challenge step counters and premium status.
- `updateProfile`: Validates username uniqueness and format (min 3 chars, alphanumeric). `avatarUrl` accepts HitPay/S3 presigned URL upload string.

---

### 2.2 `HostSubscriptionEndpoint` (`host_subscription_endpoint.dart`)
Handles premium tier checkout, voucher validation, and renewal status checks.

```dart
class HostSubscriptionEndpoint extends Endpoint {
  Future<List<SubscriptionPackage>> getPackages(Session session) async {...}
  Future<bool> validateVoucher(Session session, {required String voucherCode, required String targetPackageId}) async {...}
  Future<HostSubscription> checkoutSubscription(Session session, {required String packageId, required String? voucherCode, required String paymentMethodToken}) async {...}
  Future<void> cancelAutoRenew(Session session) async {...}
}
```

- **Business Rules**:
  - `validateVoucher`: Returns `false` if expired, usage limit reached, or ineligible. Returns `true` with computed discount applied to payload.
  - `checkoutSubscription`: Verifies HitPay token validity before creating `HostSubscription` row. If `paymentMethodToken` does not match user's default method, temporary default switch occurs. Returns newly active subscription.

---

### 2.3 `PayoutEndpoint` (`payout_endpoint.dart`)
Manages the single payout destination constraint and verification status.

```dart
class PayoutEndpoint extends Endpoint {
  Future<PayoutDestination?> getPayoutDestination(Session session) async {...}
  Future<PayoutDestination> upsertPayoutDestination(Session session, {required String channel, required String accountName, required String accountNumber, String? bankName}) async {...}
  Future<void> deletePayoutDestination(Session session) async {...}
  Future<void> verifyPayoutDestination(Session session, {required String otpCode}) async {...}
}
```

- **Business Rules**:
  - `upsertPayoutDestination`: Implemented via PostgreSQL `INSERT ... ON CONFLICT (user_id) DO UPDATE`. If the record exists, overwrite all fields and reset `isVerified` to `false` to trigger re-verification. If no record exists, create one.
  - `deletePayoutDestination`: Deletes the single row. **CRITICAL CHECK:** Deny deletion if the user is currently awaiting a pending payout disbursement (`Payout.status == 'pending'`).
  - `verifyPayoutDestination`: Accepts OTP, validates with provider logic, sets `isVerified = true`.

---

## 3. Repositories & Business Logic

### 3.1 `IAccountRepository` (`domain/interface/i_account_repository.dart`)
- **Injectable**: `@LazySingleton(as: IAccountRepository)`
- **Methods**: `getAccountSummary()`, `updateProfile(...)`, `deleteAccount(...)`.
- **Logic**: Orchestrates RPC calls to `baktaz_client`, handles local caching (if required via `session.caches.local` for static platform configs), and throws typed `ApiException` on failure (`ValidationFailure`, `AuthenticationFailure`).

---

### 3.2 `IHostSubscriptionRepository` (`domain/interface/i_host_subscription_repository.dart`)
- **Injectable**: `@LazySingleton(as: IHostSubscriptionRepository)`
- **Methods**: `getPackages()`, `checkout(...)`, `validateVoucher(...)`.
- **Host Cut Forfeiture Logic**:
  Upon challenge settlement event (triggered from `ChallengeRepository`), the server instantiates a `SubscriptionRepository.validateSubscriptionStatusForSettlement(String userId)` call.
  - **Validation Timestamp**: `challenge.expiresAt` (moment challenge concludes).
  - **Execution**: Query `host_subscription.expiresAt`.
  - If `host_subscription.expiresAt < challenge.expiresAt` OR `status != 'active'` → Return `false`.
  - If `false` → Host payout record `net_host_cut` is set to `0`, `failure_reason` is set to `'SUBSCRIPTION_EXPIRED_AT_COMPLETION'`.
  - **Non-Retroactive Renewal Constraint**: A renewed subscription during an ongoing challenge will *not* retroactively restore forfeited cuts for previously concluded challenges.

---

### 3.3 `IPayoutRepository` (`domain/interface/i_payout_repository.dart`)
- **Injectable**: `@LazySingleton(as: IPayoutRepository)`
- **Methods**: `getPayoutDestination()`, `upsertPayoutDestination(...)`, `deletePayoutDestination(...)`, `verifyPayoutDestination(...)`.
- **Logic**: Performs strict single-record lookups and upserts, heavily dependent on PostgreSQL unique constraint on `payout_destination.user_id_unique_idx`.

---
