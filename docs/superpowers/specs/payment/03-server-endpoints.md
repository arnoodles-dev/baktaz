# Payment & Payout Architecture Spec — Server Endpoints

**Date:** 2026-08-28
**Parent Spec:** `docs/superpowers/specs/payment/00-overview.md`

## 7. API Endpoints

### 7.1 Player Endpoints

```
POST /payments/intent          # Create payment intent for challenge join/create
GET  /payments/{id}/status     # Poll payment status
GET  /payments/accounts        # List saved payment methods
POST /payments/accounts        # Add payment method
DELETE /payments/accounts/{id} # Remove payment method

GET  /payouts/accounts         # List saved payout destinations
POST /payouts/accounts         # Add payout destination
DELETE /payouts/accounts/{id}  # Remove payout destination
POST /payouts/claim            # Claim payout for challenge
GET  /payouts/{id}             # Get payout status

POST /challenges/{id}/join     # Join challenge (triggers payment)
```

### 7.2 Admin Endpoints

```
POST /admin/challenges/{id}/close
POST /admin/challenges/{id}/cancel
POST /admin/challenges/{id}/refund-all
POST /admin/challenges/{id}/finalize-results
GET  /admin/challenges/{id}/financials
GET  /admin/payouts?challenge_id=&status=&page=&limit=
GET  /admin/reconciliation?from=&to=
GET  /admin/audit-log?entity_type=&entity_id=&page=
PUT  /admin/tax-rules/{id}
```

### 7.3 Internal Endpoints (Webhooks)

```
POST /webhooks/hitpay/payment
POST /webhooks/hitpay/payout
POST /webhooks/hitpay/refund
```
