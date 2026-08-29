# Host Subscription Implementation Plan — Task 3: Seed Migration

> **Parent:** `docs/superpowers/plans/account/subscription/2026-08-29-00-plan-overview.md`  
> **Spec:** `docs/superpowers/specs/account/subscription/2026-08-29-00-overview.md`

---

### Task 3: Seed Migration

**Files:**
- Create: `baktaz_server/lib/src/features/account/domain/model/migrations/V20260829000001__host_subscription_seed.sql`

**Interfaces:**
- Consumes: Generated `SubscriptionPackage`, `Voucher`, `VoucherPlan` model names
- Produces: Pre-populated DB with 3 packages + 3 placeholder vouchers

- [ ] **Step 1: Write seed SQL**

```sql
-- Insert subscription packages
INSERT INTO subscription_package (id, name, duration_days, price_centavos, discount_percent, is_active, created_at)
VALUES
  (gen_random_uuid(), 'Monthly Host', 30, 29900, 0.0, true, now()),
  (gen_random_uuid(), '3-Month Host', 90, 79900, 11.0, true, now()),
  (gen_random_uuid(), 'Annual Host', 365, 269900, 25.0, true, now())
ON CONFLICT DO NOTHING;

-- Insert placeholder vouchers (dev only!)
INSERT INTO voucher (id, code, discount_type, discount_value, expires_at, usage_cap, usage_count, is_active, created_at)
VALUES
  (gen_random_uuid(), 'WELCOME20', 'percentage', 20.0, now() + interval '90 days', 100, 0, true, now()),
  (gen_random_uuid(), 'LAUNCH50', 'fixed', 50.0, now() + interval '60 days', 50, 0, true, now()),
  (gen_random_uuid(), 'FREE7DAYS', 'free_trial', 7.0, now() + interval '30 days', 20, 0, true, now())
ON CONFLICT (code) DO NOTHING;

-- Map vouchers to plans
INSERT INTO voucher_plan (id, voucher_id, package_id, created_at)
SELECT gen_random_uuid(), v.id, p.id, now()
FROM voucher v
JOIN subscription_package p ON p.name IN ('Monthly Host', '3-Month Host', 'Annual Host')
WHERE v.code = 'WELCOME20' AND v.is_active = true
ON CONFLICT DO NOTHING;

INSERT INTO voucher_plan (id, voucher_id, package_id, created_at)
SELECT gen_random_uuid(), v.id, p.id, now()
FROM voucher v
JOIN subscription_package p ON p.name IN ('3-Month Host', 'Annual Host')
WHERE v.code = 'LAUNCH50' AND v.is_active = true
ON CONFLICT DO NOTHING;

INSERT INTO voucher_plan (id, voucher_id, package_id, created_at)
SELECT gen_random_uuid(), v.id, p.id, now()
FROM voucher v
JOIN subscription_package p ON p.name = 'Monthly Host'
WHERE v.code = 'FREE7DAYS' AND v.is_active = true
ON CONFLICT DO NOTHING;
```

- [ ] **Step 2: Commit migration**

```bash
git add lib/src/features/account/models/migrations/ && \
  git commit -m "feat: add host subscription seed data"
```
