# Account Feature Architecture Spec — Server Models

> **Document Version:** 1.0  
> **Date:** 2026-08-28  
> **Parent Spec:** `docs/superpowers/specs/account/00-overview.md`  
> **Package:** `baktaz_server` (`lib/src/features/account/models/`)  

---

## 1. Overview & Directory Structure

All account-related backend data structures are declared using Serverpod `.spy.yaml` schemas. These generate strongly-typed Dart domain models, database table definitions (where applicable), and client-side RPC DTOs in `baktaz_client`.

**Server Directory:** `baktaz_server/lib/src/features/account/models/`

---

## 2. Serverpod Model Definitions (`.spy.yaml`)

### 2.1 `UserInfo` (`user_info.spy.yaml`)
Represents the public and editable identity metadata of a user account.

```yaml
class: UserInfo
fields:
  id: UuidValue
  fullName: String
  username: String
  avatarUrl: String?
  memberSince: DateTime
```

- **Usage**: Returned as part of profile metadata queries and account summary calls.
- **Constraints**: `username` must be unique across all non-deleted user records (enforced via DB index in underlying auth/user schema).

---

### 2.2 `AccountSummary` (`account_summary.spy.yaml`)
Aggregates profile identity, host subscription tier, and lifetime challenge step statistics into a single RPC payload for `AccountPage`.

```yaml
class: AccountSummary
fields:
  userInfo: UserInfo
  isPremiumHost: bool
  challengeStepsTotal: int
  challengesJoined: int
  challengesWon: int
```

- **Stat Rules**:
  - `challengeStepsTotal`: Sum of validated steps recorded *strictly* during active challenge durations. Excludes general background steps.
  - `isPremiumHost`: `true` if user possesses an unexpired `HostSubscription` record with status `active`.

---

### 2.3 `SubscriptionPackage` (`subscription_package.spy.yaml`)
Defines available Host subscription plans offered to users.

```yaml
class: SubscriptionPackage
table: subscription_package
fields:
  name: String
  durationDays: int
  priceCentavos: int
  discountPercent: double
  isActive: bool
```

- **Table**: `subscription_package`
- **Initial Seed Data**:
  1. `host_monthly`: "Monthly Host", 30 Days, ₱299 (`29900` centavos), 0.0% discount.
  2. `host_quarterly`: "3-Month Host", 90 Days, ₱799 (`79900` centavos), 11.0% discount.
  3. `host_annual`: "Annual Host", 365 Days, ₱2,699 (`269900` centavos), 25.0% discount.

---

### 2.4 `HostSubscription` (`host_subscription.spy.yaml`)
Tracks active or historical Premium Host subscriptions for a given user account.

```yaml
class: HostSubscription
table: host_subscription
indexes:
  user_id_idx:
    fields: userId
fields:
  userId: UuidValue
  packageId: UuidValue
  status: String # active, expired, cancelled
  startedAt: DateTime
  expiresAt: DateTime
  autoRenew: bool
  lastVoucherCode: String?
```

- **Table**: `host_subscription`
- **Index Constraints**: `user_id_idx` on `userId` for rapid active tier validation.
- **Status Values**:
  - `active`: Subscription is currently valid and unexpired.
  - `expired`: Duration reached and auto-renew failed or was disabled.
  - `cancelled`: Cancelled by user before term end (remains active until `expiresAt`).

---

### 2.5 `Voucher` (`voucher.spy.yaml`)
Promotional discount codes redeemable during host subscription checkout.

```yaml
class: Voucher
table: voucher
indexes:
  code_unique_idx:
    fields: code
    unique: true
fields:
  code: String
  discountType: String # percentage, fixed, free_trial
  discountValue: double
  expiresAt: DateTime?
  usageCap: int?
  usageCount: int
```

- **Table**: `voucher`
- **Index Constraints**: `code_unique_idx` unique index on `code`.
- **Discount Types**:
  - `percentage`: `discountValue` is percentage (e.g. `20.0` for 20% off).
  - `fixed`: `discountValue` is fixed amount in Pesos (e.g. `50.0` for ₱50 off).
  - `free_trial`: `discountValue` is additional trial duration in days (e.g. `7.0` for +7 days free).

---

### 2.6 `SavedPaymentMethod` (`saved_payment_method.spy.yaml`)
Tokenized payment methods saved by the user via HitPay gateway integration.

```yaml
class: SavedPaymentMethod
table: saved_payment_method
indexes:
  user_id_idx:
    fields: userId
fields:
  userId: UuidValue
  hitpayToken: String
  paymentType: String # card, gcash, maya
  last4: String?
  cardBrand: String?
  isDefault: bool
```

- **Table**: `saved_payment_method`
- **Index Constraints**: `user_id_idx` on `userId`.
- **Default Constraint**: Business logic guarantees exactly one `isDefault: true` per user when saved payment methods exist.

---

### 2.7 `PayoutDestination` (`payout_destination.spy.yaml`)
Single active bank account or e-wallet destination for receiving prize disbursements and host cuts.

```yaml
class: PayoutDestination
table: payout_destination
indexes:
  user_id_unique_idx:
    fields: userId
    unique: true
fields:
  userId: UuidValue
  channel: String # gcash, maya, bank
  accountName: String
  accountNumber: String
  bankName: String?
  isVerified: bool
```

- **Table**: `payout_destination`
- **Index Constraints**: `user_id_unique_idx` **STRICT UNIQUE INDEX** on `userId`. Enforces the system rule of **Maximum 1 active payout destination per user account** at database schema level.
- **Channels**: `gcash`, `maya`, `bank`. (`bankName` is required only if `channel == 'bank'`).
- **Verification**: `isVerified` set to `true` upon successful SMS OTP / name validation check.

---
