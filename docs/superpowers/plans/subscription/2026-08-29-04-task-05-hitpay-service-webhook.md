# Host Subscription Plan — Task 5: HitPay Service + Webhook

> **Parent:** `docs/superpowers/plans/account/subscription/2026-08-29-00-plan-overview.md`  
> **Spec:** `docs/superpowers/specs/account/subscription/2026-08-29-02-server-endpoints.md`

---

### Task 5: HitPay Service + Webhook

**Files:**
- Create: `baktaz_server/lib/src/features/account/data/service/hitpay_service.dart`
- Create: `baktaz_server/lib/src/features/account/domain/model/checkout_response.spy.yaml`
- Modify: `baktaz_server/lib/src/features/account/data/repository/host_subscription_repository.dart`
- Create: `baktaz_server/lib/src/features/account/webhook/hitpay_webhook_endpoint.dart`

**Interfaces:**
- Consumes: `HitPayService`, `IHostSubscriptionRepository`, `IVoucherRepository`
- Produces: Full checkout flow with HitPay API integration

- [ ] **Step 1: Write checkout_response.spy.yaml**
- [ ] **Step 2: Regenerate after adding CheckoutResponse** (`dart run serverpod generate`)
- [ ] **Step 3: Write hitpay_service.dart** (createCustomer, createRecurringBilling, validateWebhook)
- [ ] **Step 4: Implement checkout() in HostSubscriptionRepository**
- [ ] **Step 5: Write HitPay webhook endpoint**
- [ ] **Step 6: Commit**
