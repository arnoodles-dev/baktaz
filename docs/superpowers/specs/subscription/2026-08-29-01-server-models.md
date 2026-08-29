# Host Subscription Feature Spec — Server Models

> **Document Version:** 1.1  
> **Date:** 2026-08-29  
> **Parent Spec:** `docs/superpowers/specs/account/subscription/2026-08-29-00-overview.md`  
> **Package:** `baktaz_server` (`lib/src/features/account/models/`)  

---

## 1. Directory Structure

```
baktaz_server/lib/src/features/account/domain/model/
├── subscription_package.spy.yaml    # Serverpod model
├── host_subscription.spy.yaml       # Serverpod model
├── voucher.spy.yaml                 # Serverpod model
├── voucher_plan.spy.yaml            # Serverpod model (junction table)
├── user_voucher_usage.spy.yaml      # NEW: Tracks per-user voucher redemptions
└── migrations/
    └── V20260829000001__host_subscription_schema.sql  # Migration for seed data
```

---

## 2. Serverpod Model Definitions

### 2.1 `SubscriptionPackage` (`subscription_package.spy.yaml`)

```yaml
class: SubscriptionPackage
table: subscription_package
fields:
  name: String
  durationDays: int
  priceCentavos: int
  discountPercent: double
  isActive: bool
  hitpayPlanId: String?        # HitPay subscription plan reference ID
  createdAt: DateTime, default=now
  updatedAt: DateTime?, scope=serverOnly
```

### 2.2 `HostSubscription` (`host_subscription.spy.yaml`)

```yaml
class: HostSubscription
table: host_subscription
indexes:
  user_id_idx:
    fields: userId
fields:
  userId: UuidValue
  packageId: UuidValue
  status: String        # active, expired, cancelled
  startedAt: DateTime
  expiresAt: DateTime
  autoRenew: bool
  lastVoucherCode: String?
  hitpayCustomerId: String?
  hitpaySubscriptionId: String?
  createdAt: DateTime, default=now
  updatedAt: DateTime?, scope=serverOnly
```

### 2.3 `Voucher` (`voucher.spy.yaml`)

```yaml
class: Voucher
table: voucher
indexes:
  code_unique_idx:
    fields: code
    unique: true
fields:
  code: String                  # Uppercase alphanumeric, e.g. "WELCOME20"
  discountType: String          # percentage, fixed, free_month
  discountValue: double         # 20.0 (20%), 50.0 (₱50), 100.0 (100% off first month)
  expiresAt: DateTime?
  usageCap: int?                # Total redemptions across all users
  usageCount: int, default=0
  isActive: bool, default=true
  createdAt: DateTime, default=now
```

### 2.4 `VoucherPlan` (`voucher_plan.spy.yaml`)

```yaml
class: VoucherPlan
table: voucher_plan
indexes:
  voucher_id_idx:
    fields: voucherId
  package_id_idx:
    fields: packageId
fields:
  voucherId: UuidValue
  packageId: UuidValue
  createdAt: DateTime, default=now
```

### 2.5 `UserVoucherUsage` (`user_voucher_usage.spy.yaml`) — NEW

```yaml
class: UserVoucherUsage
table: user_voucher_usage
indexes:
  user_voucher_idx:
    fields: userId, voucherId
    unique: true
fields:
  userId: UuidValue
  voucherId: UuidValue
  redeemedAt: DateTime, default=now
```

---

## 3. Seed Script Updates

Placeholder vouchers now include `FREE1MONTH` instead of trial days:

```sql
INSERT INTO voucher (id, code, discount_type, discount_value, expires_at, usage_cap, usage_count, is_active, created_at)
VALUES
  (gen_random_uuid(), 'WELCOME20', 'percentage', 20.0, now() + interval '90 days', 100, 0, true, now()),
  (gen_random_uuid(), 'LAUNCH50', 'fixed', 50.0, now() + interval '60 days', 50, 0, true, now()),
  (gen_random_uuid(), 'FREE1MONTH', 'percentage', 100.0, now() + interval '30 days', 20, 0, true, now())
ON CONFLICT (code) DO NOTHING;
```

