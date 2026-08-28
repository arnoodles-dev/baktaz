# Account Serverpod Data Models Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create Serverpod `.spy.yaml` model definitions for the Account feature (`UserInfo`, `AccountSummary`, `SubscriptionPackage`, `HostSubscription`, `Voucher`, `SavedPaymentMethod`, `PayoutDestination`) in `baktaz_server/lib/src/features/account/models/` and generate Serverpod client SDK and database migration scripts.

**Architecture:** Define domain models using Serverpod's YAML model specification format under `baktaz_server/lib/src/features/account/models/`. Run `serverpod generate` to generate Dart DTOs in `baktaz_server` and `baktaz_client`, then create database schema migrations with `serverpod create-migration`.

**Tech Stack:** Dart 3.x, Serverpod 2.x ORM, PostgreSQL schema migration toolchain.

**Spec:** `docs/specs/account_feature_spec.md`

## Global Constraints

- Backend models use Serverpod `.spy.yaml` definitions under `lib/src/features/account/models/`.
- Database primary keys use default Serverpod entity id indexing (int/UuidValue).
- Immutability and type safety strictly enforced across all models.
- No editing generated files in `baktaz_client` or `lib/src/generated/`.

---

### Task 1: Serverpod Data Models & Codegen Migration

**Files:**
- Create: `baktaz_server/lib/src/features/account/models/user_info.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/models/account_summary.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/models/subscription_package.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/models/host_subscription.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/models/voucher.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/models/saved_payment_method.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/models/payout_destination.spy.yaml`

**Interfaces:**
- Consumes: Serverpod core framework YAML parser.
- Produces: Serverpod Dart model classes (`UserInfo`, `AccountSummary`, `SubscriptionPackage`, `HostSubscription`, `Voucher`, `SavedPaymentMethod`, `PayoutDestination`) in `baktaz_server` and `baktaz_client`.

- [ ] **Step 1: Write the model YAML files**

Create `baktaz_server/lib/src/features/account/models/user_info.spy.yaml`:
```yaml
class: UserInfo
table: baktaz_user_info
fields:
  userId: UuidValue
  fullName: String
  email: String
  avatarUrl: String?
  createdAt: DateTime
  updatedAt: DateTime
```

Create `baktaz_server/lib/src/features/account/models/subscription_package.spy.yaml`:
```yaml
class: SubscriptionPackage
table: subscription_package
fields:
  title: String
  priceAmount: double
  currency: String
  durationDays: int
  featuresJson: String
  isPopular: bool
```

Create `baktaz_server/lib/src/features/account/models/host_subscription.spy.yaml`:
```yaml
class: HostSubscription
table: host_subscription
fields:
  userId: UuidValue
  packageId: int
  startDate: DateTime
  endDate: DateTime
  status: String
  autoRenew: bool
```

Create `baktaz_server/lib/src/features/account/models/voucher.spy.yaml`:
```yaml
class: Voucher
table: voucher
fields:
  code: String
  discountPercent: double
  discountAmount: double
  validUntil: DateTime
  maxRedemptions: int
  currentRedemptions: int
  isActive: bool
```

Create `baktaz_server/lib/src/features/account/models/saved_payment_method.spy.yaml`:
```yaml
class: SavedPaymentMethod
table: saved_payment_method
fields:
  userId: UuidValue
  provider: String
  paymentToken: String
  cardBrand: String
  last4: String
  isDefault: bool
```

Create `baktaz_server/lib/src/features/account/models/payout_destination.spy.yaml`:
```yaml
class: PayoutDestination
table: payout_destination
fields:
  userId: UuidValue
  channel: String
  accountName: String
  accountNumber: String
  bankCode: String?
  isDefault: bool
```

Create `baktaz_server/lib/src/features/account/models/account_summary.spy.yaml`:
```yaml
class: AccountSummary
fields:
  userInfo: UserInfo
  totalHostedChallenges: int
  totalParticipatedChallenges: int
  lifetimeWinnings: double
  activeHostSubscription: HostSubscription?
  defaultPayoutDestination: PayoutDestination?
```

- [ ] **Step 2: Run Serverpod codegen to verify syntax and model generation**

Run: `cd baktaz_server && fvm dart run serverpod_cli:serverpod generate`
Expected: Successfully generated protocol files in `baktaz_server` and `baktaz_client` without compilation errors.

- [ ] **Step 3: Create Serverpod database migration**

Run: `cd baktaz_server && fvm dart run serverpod_cli:serverpod create-migration --tag account_feature_models`
Expected: Migration SQL files generated inside `baktaz_server/migrations/`.

- [ ] **Step 4: Verify generated Dart client models compile cleanly**

Run: `cd baktaz_client && fvm dart analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit server model definitions and migrations**

```bash
git add baktaz_server/lib/src/features/account/models/ baktaz_server/migrations/ baktaz_client/
git commit -m "feat(server): add Serverpod account feature data models and migrations"
```
