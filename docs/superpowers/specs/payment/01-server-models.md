# Payment & Payout Architecture Spec — Server Models

**Date:** 2026-08-28
**Parent Spec:** `docs/superpowers/specs/payment/00-overview.md`

## 5. Database Schema

### 5.1 Tables to Create

```yaml
# challenges.spy.yaml
class: Challenge
table: challenges
fields:
  id: UuidValue?, defaultPersist=random
  name: String
  description: String?
  entry_fee: double
  currency: String
  prize_percentage: double
  platform_fee_percentage: double
  host_cut_percentage: double # default 0.5
  gross_collection: double
  gross_prize_pool: double
  gross_platform_fee: double
  gross_host_cut: double
  status: ChallengeStatus
  starts_at: DateTime?
  ends_at: DateTime?
  created_at: DateTime
  updated_at: DateTime

# challenge_entries.spy.yaml
class: ChallengeEntry
table: challenge_entries
fields:
  id: UuidValue?, defaultPersist=random
  challenge_id: Challenge, relation
  user_id: User, relation
  payment_id: Payment?, relation
  entry_fee: double
  status: ChallengeEntryStatus
  created_at: DateTime
  updated_at: DateTime
  # unique: challenge_id + user_id

# payments.spy.yaml
class: Payment
table: payments
fields:
  id: UuidValue?, defaultPersist=random
  user_id: User, relation
  challenge_id: Challenge, relation
  provider: String
  provider_payment_id: String?
  amount: double
  currency: String
  status: PaymentStatus
  provider_fee: double
  settlement_status: SettlementStatus
  payment_method_type: String?
  payment_method_subtype: String?
  brand: String?
  last4: String?
  provider_customer_id: String?
  provider_payment_method_id: String?
  provider_metadata: Json?
  paid_at: DateTime?
  created_at: DateTime
  updated_at: DateTime

# payment_accounts.spy.yaml
class: PaymentAccount
table: payment_accounts
fields:
  id: UuidValue?, defaultPersist=random
  user_id: User, relation
  provider: String
  provider_customer_id: String?
  provider_payment_method_id: String?
  type: String # gcash, maya, credit_card, debit_card
  subtype: String?
  brand: String?
  last4: String?
  is_default: bool
  status: String # active, inactive
  created_at: DateTime
  updated_at: DateTime

# challenge_winners.spy.yaml
class: ChallengeWinner
table: challenge_winners
fields:
  id: UuidValue?, defaultPersist=random
  challenge_id: Challenge, relation
  user_id: User, relation
  rank: int
  prize_percentage: double
  gross_prize_amount: double
  created_at: DateTime

# payouts.spy.yaml
class: Payout
table: payouts
fields:
  id: UuidValue?, defaultPersist=random
  challenge_id: Challenge, relation
  user_id: User, relation
  gross_prize_amount: double
  tax_withheld_amount: double
  payout_fee_amount: double
  net_payout_amount: double
  tax_rule_id: TaxRule?, relation
  provider: String
  provider_payout_id: String?
  status: PayoutStatus
  requested_at: DateTime?
  processed_at: DateTime?
  completed_at: DateTime?
  failure_reason: String?
  provider_metadata: Json?
  created_at: DateTime
  updated_at: DateTime

# host_payouts.spy.yaml
class: HostPayout
table: host_payouts
fields:
  id: UuidValue?, defaultPersist=random
  challenge_id: Challenge, relation
  host_id: User, relation
  gross_host_cut: double
  payout_fee_amount: double
  net_host_cut: double
  provider: String
  provider_payout_id: String?
  status: HostPayoutStatus
  requested_at: DateTime?
  processed_at: DateTime?
  completed_at: DateTime?
  failure_reason: String?
  created_at: DateTime
  updated_at: DateTime

# ledger_accounts.spy.yaml
class: LedgerAccount
table: ledger_accounts
fields:
  id: UuidValue?, defaultPersist=random
  account_type: String # PAYMENT_CLEARING, PRIZE_LIABILITY, etc.
  owner_type: String?
  owner_id: String?
  currency: String
  status: String
  created_at: DateTime

# ledger_transactions.spy.yaml
class: LedgerTransaction
table: ledger_transactions
fields:
  id: UuidValue?, defaultPersist=random
  reference_type: String
  reference_id: String
  transaction_type: String # ENTRY_PAYMENT, PRIZE_ALLOCATION, etc.
  description: String?
  created_at: DateTime

# ledger_entries.spy.yaml
class: LedgerEntry
table: ledger_entries
fields:
  id: UuidValue?, defaultPersist=random
  transaction_id: LedgerTransaction, relation
  account_id: LedgerAccount, relation
  direction: String # debit, credit
  amount: double
  currency: String
  created_at: DateTime

# tax_rules.spy.yaml
class: TaxRule
table: tax_rules
fields:
  id: UuidValue?, defaultPersist=random
  tax_rate: double
  tax_type: String
  threshold: double
  effective_from: DateTime
  effective_until: DateTime?
  created_at: DateTime
  updated_at: DateTime

# audit_logs.spy.yaml
class: AuditLog
table: audit_logs
fields:
  id: UuidValue?, defaultPersist=random
  actor_type: String
  actor_id: String?
  action: String
  entity_type: String
  entity_id: String?
  old_value: Json?
  new_value: Json?
  ip_address: String?
  created_at: DateTime

# user_identity_verifications.spy.yaml
class: UserIdentityVerification
table: user_identity_verifications
fields:
  id: UuidValue?, defaultPersist=random
  user_id: User, relation
  provider: String
  provider_reference: String?
  status: String # pending, verified, rejected, expired
  verified_at: DateTime?
  expires_at: DateTime?
  created_at: DateTime
  updated_at: DateTime
```

### 5.2 Tables to Delete

```
- wallet
- wallet_transactions
```

## 6. State Machines

### 6.1 Challenge Status

```
DRAFT → OPEN → CLOSED → IN_PROGRESS → FINISHED → RESULTS_PENDING
  → WINNERS_CONFIRMED → PAYOUT_PENDING → PAYOUT_PROCESSING → COMPLETED

Failure: CANCELLED, REFUND_PENDING, REFUNDED, PAYOUT_FAILED
```

### 6.2 Payment Status

```
PENDING → PAID → FAILED → REFUNDED
  → CANCELLED
Settlement: PENDING → AVAILABLE → SETTLED
```

### 6.3 Payout Status

```
PENDING → ELIGIBILITY_CHECK → READY → PROCESSING → SUCCESS
  → FAILED → RETRY_PENDING
  → CANCELLED
```

### 6.4 Host Payout Status

```
PENDING → PROCESSING → SUCCESS
  → FAILED → RETRY_PENDING
  → FORFEITED (subscription cancelled)
```
