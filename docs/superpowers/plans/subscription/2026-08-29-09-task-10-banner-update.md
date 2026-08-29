# Host Subscription Plan — Task 10: AccountPage Banner Update

> **Parent:** `docs/superpowers/plans/account/subscription/2026-08-29-00-plan-overview.md`  
> **Spec:** `docs/superpowers/specs/account/subscription/2026-08-29-04-flutter-ui.md`

---

### Task 10: AccountPage Banner Update

**Files:**
- Modify: `baktaz_flutter/lib/features/account/presentation/widgets/account_content_header.dart`
- Modify: `baktaz_flutter/lib/features/account/domain/entity/model/account_summary.dart`
- Modify: `baktaz_flutter/lib/app/routes/app_routes.dart`

**Interfaces:**
- Consumes: `AccountSummary.isPremiumHost` (new field), `HostSubscriptionRoute`
- Produces: AccountPage shows HostSubscriptionBanner instead of hardcoded "VIP"

- [ ] **Step 1: Add isPremiumHost to AccountSummary**
- [ ] **Step 2: Update AccountContentHeader to use HostSubscriptionBanner**
- [ ] **Step 3: Commit**
