# Host Subscription Implementation Plan — Tasks 1–2: Server Models + Codegen

> **Parent:** `docs/superpowers/plans/account/subscription/2026-08-29-00-plan-overview.md`  
> **Spec:** `docs/superpowers/specs/account/subscription/2026-08-29-00-overview.md`

---

### Task 1: Server Models (.spy.yaml)

**Files:**
- Create: `baktaz_server/lib/src/features/account/domain/model/subscription_package.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/domain/model/host_subscription.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/domain/model/voucher.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/domain/model/voucher_plan.spy.yaml`

**Interfaces:**
- Produces: Serverpod models for codegen → `SubscriptionPackage`, `HostSubscription`, `Voucher`, `VoucherPlan` classes with DB tables.

- [ ] **Step 1: Write subscription_package.spy.yaml**

```yaml
class: SubscriptionPackage
table: subscription_package
fields:
  name: String
  durationDays: int
  priceCentavos: int
  discountPercent: double
  isActive: bool
  hitpayPlanId: String?
  createdAt: DateTime, default=now
  updatedAt: DateTime?, scope=serverOnly
```

- [ ] **Step 2: Write host_subscription.spy.yaml**

```yaml
class: HostSubscription
table: host_subscription
indexes:
  user_id_idx:
    fields: userId
fields:
  userId: UuidValue
  packageId: UuidValue
  status: String
  startedAt: DateTime
  expiresAt: DateTime
  autoRenew: bool
  lastVoucherCode: String?
  hitpayCustomerId: String?
  hitpaySubscriptionId: String?
  createdAt: DateTime, default=now
  updatedAt: DateTime?, scope=serverOnly
```

- [ ] **Step 3: Write voucher.spy.yaml**

```yaml
class: Voucher
table: voucher
indexes:
  code_unique_idx:
    fields: code
    unique: true
fields:
  code: String
  discountType: String
  discountValue: double
  expiresAt: DateTime?
  usageCap: int?
  usageCount: int, default=0
  isActive: bool, default=true
  createdAt: DateTime, default=now
```

- [ ] **Step 4: Write voucher_plan.spy.yaml**

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

- [ ] **Step 5: Commit**

```bash
cd baktaz_server && git add lib/src/features/account/models/*.spy.yaml && \
  git commit -m "feat: add host subscription models"
```

---

### Task 2: Serverpod Generate + Code Generation

**Files:**
- Modify: `baktaz_server/lib/src/generated/protocol.dart` (auto-generated)

**Interfaces:**
- Consumes: `.spy.yaml` models from Task 1
- Produces: Generated `SubscriptionPackage`, `HostSubscription`, `Voucher`, `VoucherPlan`, `Table` classes

- [ ] **Step 1: Run serverpod generate**

```bash
cd baktaz_server && dart run serverpod generate
```

Expected: 4 new model classes + table accessors in `lib/src/generated/`

- [ ] **Step 2: Commit generated files**

```bash
git add lib/src/generated/ && git commit -m "chore: regenerate protocol with subscription models"
```
