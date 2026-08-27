# Prize Pool Competition Platform — Business & Payment Architecture Specification

## 1. Purpose

This document defines the proposed business, payment, ledger, payout, and backend architecture for a Philippine competition platform where:

1. Participants pay an entry fee.
2. A percentage of collected entry fees becomes the gross prize pool.
3. The platform retains a platform fee.
4. The platform absorbs payment-processing and payout transaction fees.
5. Winners receive their gross prize allocation less any applicable withholding tax.
6. The payment provider handles payment collection and payout rails.
7. The platform backend maintains the competition state, financial ledger, prize liabilities, tax liabilities, and payout orchestration.

This specification assumes a model similar to:

> Participant pays ₱100 → 90% becomes the gross prize pool → 10% becomes the platform's gross fee → payment/payout fees are absorbed by the platform → applicable winner tax is withheld from the winner's prize.

---

# 2. Important Regulatory and Compliance Principle

This architecture must **not** be interpreted as legal confirmation that the business model is permitted.

The platform involves:

- collecting participant entry fees;
- pooling participant-funded money;
- distributing prizes to winners;
- potentially withholding taxes;
- using payment and payout services.

The exact competition mechanics must be reviewed for Philippine:

- payment-services regulation;
- gaming/gambling/prize-competition regulation;
- tax treatment;
- consumer protection;
- KYC/AML requirements;
- business registration and licensing;
- payment-provider compliance.

The payment provider must explicitly approve the proposed business model before production launch.

The platform should not represent a payment-provider balance as a legal "escrow account" unless the provider and legal counsel explicitly confirm that structure.

---

# 3. Business Model

## 3.1 Core Model

Assume:

- Entry fee = ₱100
- Prize allocation = 90%
- Platform fee = 10%

For 1,000 participants:

```text
1,000 × ₱100
────────────────────
Gross collection       ₱100,000

Prize pool (90%)        ₱90,000
Platform fee (10%)      ₱10,000
```

The ₱90,000 is the **Gross Prize Pool**.

The ₱10,000 is the platform's **Gross Platform Fee**.

Payment and payout fees are operating expenses of the platform and do not reduce the advertised gross prize pool.

---

# 4. Fee Ownership Model

## 4.1 Platform Absorbs Transaction Fees

The platform absorbs:

- payment-processing fees;
- payout/disbursement fees;
- applicable payment-provider service fees;
- other payment infrastructure costs.

Example:

```text
Gross platform fee          ₱10,000
HitPay payment fees          -₱2,300
HitPay payout fees              -₱500
────────────────────────────────────
Platform contribution        ₱7,200
```

The exact payment and payout fees must be obtained from the provider's current commercial agreement and must not be hard-coded.

## 4.2 Winners Absorb Applicable Tax

Taxes applicable to a winner's prize are deducted from the winner's gross prize.

Example, assuming a 20% withholding rate applies:

```text
Gross prize                  ₱45,000
Withholding tax               -₱9,000
────────────────────────────────
Net payout                   ₱36,000
```

The tax withheld is **not platform revenue**.

If the platform is the applicable withholding agent, the withheld amount becomes a tax liability that must be remitted according to the applicable BIR rules.

The actual tax treatment and rate must be confirmed for the specific competition model before implementation.

---

# 5. Recommended Money Flow

```text
                    PARTICIPANT
                         │
                         │ Entry Fee
                         ▼
                ┌─────────────────┐
                │ Payment Provider │
                │    (HitPay)      │
                └────────┬────────┘
                         │
                         │ Payment webhook
                         ▼
                ┌─────────────────┐
                │   Platform API  │
                └────────┬────────┘
                         │
              ┌──────────┴───────────┐
              │                      │
              ▼                      ▼
       Competition Ledger      Payment Record
              │
       ┌──────┴───────┐
       │              │
       ▼              ▼
 Prize Liability   Platform Revenue
     90%               10%
       │                │
       │                ├── Payment fees
       │                ├── Payout fees
       │                └── Other costs
       │
       ▼
 Competition Ends
       │
       ▼
 Determine Winners
       │
       ▼
 Calculate Gross Prize
       │
       ▼
 Calculate Applicable Tax
       │
       ▼
 Create Net Payout
       │
       ▼
 Payment Provider Payout API
       │
       ├── GCash
       ├── Maya
       └── Bank
```

---

# 6. Payment Provider

## 6.1 Primary Candidate: HitPay

HitPay should be evaluated as a primary payment-provider candidate because its Philippine offering supports payment collection and payout capabilities.

Relevant capabilities include:

- Philippine payment collection;
- GCash;
- QR Ph;
- bank/payment rails;
- merchant balance and settlement;
- payout APIs;
- bank transfers;
- InstaPay/PESONet;
- digital-wallet payout destinations;
- payout status/webhooks.

The provider must explicitly confirm that the proposed participant-funded prize-pool business model is supported.

## 6.2 Provider Abstraction

Do not couple the competition domain directly to HitPay.

Define internal interfaces:

```text
PaymentProvider
├── createPayment()
├── getPayment()
├── refundPayment()
├── verifyWebhook()
└── getPaymentStatus()

PayoutProvider
├── createBeneficiary()
├── estimatePayoutFee()
├── createPayout()
├── getPayout()
├── verifyWebhook()
└── getPayoutStatus()
```

Implement:

```text
HitPayPaymentProvider
HitPayPayoutProvider
```

This allows future support for:

```text
PayMongoPaymentProvider
XenditPaymentProvider
```

without rewriting competition and accounting logic.

---

# 7. Business Account Structure

The platform should operate through a properly registered business entity and business payment-provider account.

Conceptually:

```text
Participant
    │
    ▼
HitPay Merchant Account
    │
    ▼
Business Settlement Account
    │
    ├── Platform revenue
    └── Funds required for prize settlement
```

The platform should not use a developer's personal bank account for production settlement.

Recommended structure:

```text
Business Entity
      │
      ├── Business Bank Account
      │
      ├── HitPay Business/Merchant Account
      │
      └── Accounting/Tax Records
```

The exact settlement structure must be approved by the payment provider and accounting/legal advisers.

---

# 8. Escrow vs Prize Liability

The system should distinguish between:

### Payment Provider Funds

Actual money held/settled by the payment provider according to its merchant agreement.

### Platform Ledger

The platform's internal accounting representation of:

- collected entry fees;
- prize liabilities;
- platform revenue;
- tax liabilities;
- payout obligations.

### Legal Escrow

A legally defined escrow arrangement.

The platform should **not call its internal ledger an escrow account**.

Recommended terminology:

```text
Gross Prize Pool
Prize Liability
Winner Payable
Tax Liability
Platform Revenue
```

rather than:

```text
User Wallet
Escrow Wallet
Prize Wallet
```

unless those terms have been legally validated.

---

# 9. Competition Lifecycle

Recommended state machine:

```text
DRAFT
  │
  ▼
OPEN
  │
  ▼
CLOSED
  │
  ▼
IN_PROGRESS
  │
  ▼
FINISHED
  │
  ▼
RESULTS_PENDING
  │
  ▼
WINNERS_CONFIRMED
  │
  ▼
PAYOUT_PENDING
  │
  ▼
PAYOUT_PROCESSING
  │
  ▼
COMPLETED
```

Additional failure states:

```text
CANCELLED
REFUND_PENDING
REFUNDED
PAYOUT_FAILED
```

State transitions must be controlled by backend business rules.

The client must never be able to arbitrarily set competition or payment states.

---

# 10. Payment Flow

## 10.1 Participant Joins

```text
Flutter
   │
   │ POST /competitions/{id}/join
   ▼
Backend
   │
   ├── Validate competition
   ├── Validate participant
   ├── Validate entry eligibility
   ├── Check duplicate entry
   └── Create payment
   │
   ▼
HitPay
   │
   ▼
Payment Checkout
   │
   ▼
Participant pays
```

The client must not be trusted to report successful payment.

---

# 11. Payment Confirmation

HitPay sends a webhook:

```text
POST /webhooks/hitpay
```

Backend:

```text
1. Verify webhook authenticity/signature.
2. Find internal payment.
3. Verify provider payment ID.
4. Verify amount.
5. Verify currency.
6. Verify competition.
7. Verify participant.
8. Check idempotency.
9. Mark payment as PAID.
10. Confirm competition entry.
11. Create ledger transaction.
12. Commit database transaction.
```

The payment webhook is the authoritative trigger for confirming an entry.

---

# 12. Idempotency

Payment and payout operations must be idempotent.

The provider may deliver the same webhook more than once.

Example:

```text
payment.paid
payment.paid
payment.paid
```

The system must produce:

```text
ONE payment
ONE competition entry
ONE ledger transaction
```

not three.

Recommended unique keys:

```text
provider + provider_payment_id
provider + provider_payout_id
provider + webhook_event_id
```

---

# 13. Prize Pool Calculation

For every confirmed entry:

```text
gross_entry_fee = ₱100

prize_allocation = gross_entry_fee × 90%
platform_fee     = gross_entry_fee × 10%
```

For 1,000 participants:

```text
Gross collection = ₱100,000
Prize pool       = ₱90,000
Platform fee     = ₱10,000
```

Payment-provider fees do not change the prize pool.

---

# 14. Prize Distribution

Example:

```text
Prize Pool = ₱90,000

1st = 50%
2nd = 30%
3rd = 20%
```

The backend calculates:

```text
1st = ₱45,000
2nd = ₱27,000
3rd = ₱18,000
```

These are **gross prize amounts**.

---

# 15. Winner Tax Calculation

The payout pipeline should calculate:

```text
Gross Prize
     │
     ▼
Applicable Tax Rule
     │
     ▼
Tax Withheld
     │
     ▼
Net Winner Payout
```

Example:

```text
Gross prize                 ₱45,000
Applicable withholding       ₱9,000
───────────────────────────────────
Net payout                  ₱36,000
```

Tax rules should be configurable.

Do not hard-code:

```text
tax_rate = 0.20
```

as a universal rule.

Instead:

```text
tax_rule_id
tax_rate
tax_type
threshold
effective_from
effective_until
```

This allows the tax configuration to change without rewriting payout logic.

---

# 16. Payout Flow

After winners are finalized:

```text
Competition
    │
    ▼
Winners Confirmed
    │
    ▼
Create Payout Records
    │
    ▼
Validate Winner KYC
    │
    ▼
Calculate Gross Prize
    │
    ▼
Calculate Tax
    │
    ▼
Calculate Net Payout
    │
    ▼
Create Provider Payout
    │
    ▼
HitPay
    │
    ├── GCash
    ├── Maya
    └── Bank
```

Payout states:

```text
PENDING
ELIGIBILITY_CHECK
READY
PROCESSING
SUCCESS
FAILED
RETRY_PENDING
CANCELLED
```

---

# 17. Recommended Database Design

## 17.1 users

```text
users
────────────────────────
id
email
mobile
full_name
status
created_at
updated_at
```

Do not store raw payment credentials.

---

# 18. user_identity_verifications

```text
user_identity_verifications
────────────────────────
id
user_id
provider
provider_reference
status
verified_at
expires_at
created_at
updated_at
```

Possible statuses:

```text
PENDING
VERIFIED
REJECTED
EXPIRED
```

---

# 19. payout_accounts

```text
payout_accounts
────────────────────────
id
user_id
provider
account_type
provider_account_id
masked_identifier
status
verified_at
created_at
updated_at
```

Examples:

```text
GCASH
MAYA
BANK
```

The application should store provider references rather than sensitive account credentials whenever possible.

---

# 20. competitions

```text
competitions
────────────────────────
id
name
description

entry_fee
currency

prize_percentage
platform_fee_percentage

gross_collection
gross_prize_pool
gross_platform_fee

status

starts_at
ends_at

created_at
updated_at
```

Example:

```text
entry_fee = 100
prize_percentage = 90
platform_fee_percentage = 10
```

---

# 21. competition_entries

```text
competition_entries
────────────────────────
id
competition_id
user_id
payment_id
entry_fee
status
created_at
updated_at
```

Unique constraint:

```text
competition_id + user_id
```

if each participant may only enter once.

---

# 22. payments

```text
payments
────────────────────────
id
user_id
competition_id

provider
provider_payment_id

amount
currency

status

provider_fee
settlement_status

paid_at
created_at
updated_at
```

Payment status:

```text
PENDING
PAID
FAILED
REFUNDED
PARTIALLY_REFUNDED
CANCELLED
```

Settlement status:

```text
PENDING
AVAILABLE
SETTLED
```

Payment status and settlement status must be separate.

A payment can be successfully paid while funds are not yet available for settlement/payout.

---

# 23. winners

```text
winners
────────────────────────
id
competition_id
user_id
rank
prize_percentage
gross_prize_amount
created_at
```

Winner records should become immutable once results are finalized.

Any correction should be handled through an explicit adjustment/reversal process.

---

# 24. payouts

```text
payouts
────────────────────────
id

competition_id
winner_id
user_id

gross_prize_amount
tax_withheld_amount
payout_fee_amount
net_payout_amount

tax_rule_id

provider
provider_payout_id

status

requested_at
processed_at
completed_at

failure_reason

created_at
updated_at
```

Example:

```text
gross_prize_amount   = ₱45,000
tax_withheld_amount  = ₱9,000
payout_fee_amount    = ₱0
net_payout_amount    = ₱36,000
```

If the platform absorbs payout fees:

```text
payout_fee_amount = ₱50
platform_absorbed_fee = true
net_payout_amount = ₱36,000
```

The winner still receives ₱36,000.

---

# 25. Ledger Design

The financial ledger should be **double-entry and immutable**.

Do not rely on:

```text
users.balance
```

as the source of truth.

Recommended tables:

```text
ledger_accounts
ledger_transactions
ledger_entries
```

---

# 26. ledger_accounts

```text
ledger_accounts
────────────────────────
id
account_type
owner_type
owner_id
currency
status
created_at
```

Possible account types:

```text
PAYMENT_CLEARING
PRIZE_LIABILITY
PLATFORM_REVENUE
PAYMENT_PROCESSING_EXPENSE
PAYOUT_EXPENSE
TAX_LIABILITY
WINNER_PAYABLE
REFUND_LIABILITY
```

---

# 27. ledger_transactions

```text
ledger_transactions
────────────────────────
id
reference_type
reference_id
transaction_type
description
created_at
```

Examples:

```text
ENTRY_PAYMENT
PLATFORM_FEE_ALLOCATION
PRIZE_ALLOCATION
TAX_WITHHOLDING
PAYOUT
REFUND
REVERSAL
```

---

# 28. ledger_entries

```text
ledger_entries
────────────────────────
id
transaction_id
account_id
direction
amount
currency
created_at
```

Every transaction must balance.

Example:

```text
Entry collection: ₱100

Debit  Payment Clearing       ₱100
Credit Prize Liability        ₱90
Credit Platform Revenue       ₱10
```

The exact debit/credit orientation depends on the accounting convention selected by the accounting team, but the ledger must always balance.

---

# 29. Example Full Ledger

For one ₱100 entry:

```text
Gross collection:

Payment Clearing       ₱100
Prize Liability         ₱90
Platform Revenue        ₱10
```

Then payment processing fee:

```text
Payment Processing Expense   ₱2.30
Payment Provider Payable     ₱2.30
```

The platform absorbs the cost.

Then winner payout:

```text
Prize Liability        ₱45,000
Tax Liability           ₱9,000
Winner Payable         ₱36,000
```

Then:

```text
Winner Payable         ₱36,000
Payment Provider       ₱36,000
```

Tax remittance:

```text
Tax Liability           ₱9,000
BIR Payable/Bank        ₱9,000
```

---

# 30. Platform Revenue

Platform revenue should be separated from payment costs.

Example:

```text
Gross platform fees              ₱10,000
Payment processing expense       -₱2,300
Payout expense                     -₱500
────────────────────────────────────────
Contribution before other costs   ₱7,200
```

The ₱10,000 is gross platform revenue.

The ₱2,800 is an expense.

Do not record only ₱7,200 as platform revenue if your accounting treatment requires gross presentation.

The final accounting presentation should be confirmed with the company's accountant.

---

# 31. Refund Handling

Refunds must be explicitly supported.

Possible scenarios:

```text
Payment successful
     │
     ├── Competition cancelled
     ├── Entry rejected
     ├── Duplicate payment
     └── Payment dispute
```

Refund flow:

```text
Competition
    │
    ▼
Refund Eligible
    │
    ▼
Create Refund
    │
    ▼
Payment Provider
    │
    ▼
Webhook
    │
    ▼
Reverse Ledger Transaction
```

The system must determine whether the platform fee and/or provider fee are recoverable.

Do not assume all payment-provider fees are refundable.

---

# 32. Competition Cancellation

If a competition is cancelled:

```text
Competition CANCELLED
        │
        ▼
Calculate refundable entries
        │
        ▼
Create refunds
        │
        ▼
Provider refund API
        │
        ▼
Refund webhook
        │
        ▼
Reverse prize liability
```

The platform should not distribute prizes from a cancelled competition.

---

# 33. Payout Failure

If a payout fails:

```text
PAYOUT_PROCESSING
       │
       ▼
PAYOUT_FAILED
       │
       ├── Temporary → RETRY
       │
       └── Permanent → MANUAL_REVIEW
```

The winner's liability must remain outstanding until:

```text
SUCCESS
```

or an approved alternative resolution occurs.

Do not mark a payout as successful merely because the provider API accepted the request.

Use the provider's final payout status/webhook.

---

# 34. Business Bank Account

The platform should maintain a dedicated business banking relationship.

Recommended:

```text
Registered Business
       │
       ├── Business Bank Account
       │
       ├── Payment Provider Merchant Account
       │
       └── Accounting Ledger
```

The business bank account is used for:

- settlement;
- operating expenses;
- tax payments;
- payment-provider funding where required;
- accounting reconciliation.

The company should avoid mixing personal and business funds.

---

# 35. Reconciliation

A daily reconciliation process should compare:

```text
Internal Ledger
       │
       ├── Payment records
       ├── Refund records
       ├── Payout records
       └── Fees
       │
       ▼
Payment Provider Reports
       │
       ▼
Business Bank Statement
```

Reconciliation should identify:

```text
MISSING_PAYMENT
DUPLICATE_PAYMENT
MISSING_PAYOUT
DUPLICATE_PAYOUT
FEE_MISMATCH
SETTLEMENT_MISMATCH
REFUND_MISMATCH
```

No production financial system should rely solely on application logs.

---

# 36. Security Requirements

## Payment

- Verify provider webhook signatures.
- Never trust client-side payment success.
- Never store card details.
- Use provider-hosted/tokenized payment flows.
- Store provider IDs.
- Use idempotency keys.

## Payout

- Require verified payout destination.
- Require appropriate identity verification.
- Protect payout creation endpoints.
- Require server-side authorization.
- Prevent duplicate payout creation.
- Log all payout actions.

## Ledger

- Ledger entries are immutable.
- Corrections use reversal/adjustment transactions.
- No direct balance mutation.
- Every financial transaction has a reference ID.

---

# 37. Administrative Controls

The admin system should support:

```text
Competition
├── View participants
├── View payments
├── View gross prize pool
├── View platform fees
├── View payment fees
├── View winners
├── View tax liabilities
├── View payouts
├── View refunds
└── View reconciliation
```

Sensitive operations should require elevated permissions.

Examples:

```text
ADMIN
FINANCE
COMPLIANCE
SUPPORT
SUPER_ADMIN
```

Winner/result changes should be audited.

---

# 38. Audit Log

Create an immutable audit log:

```text
audit_logs
────────────────────────
id
actor_type
actor_id
action
entity_type
entity_id
old_value
new_value
ip_address
created_at
```

Important events:

```text
COMPETITION_CREATED
COMPETITION_OPENED
ENTRY_CREATED
PAYMENT_CONFIRMED
PAYMENT_REFUNDED
COMPETITION_CLOSED
RESULTS_FINALIZED
WINNER_CONFIRMED
PAYOUT_CREATED
PAYOUT_SUBMITTED
PAYOUT_COMPLETED
PAYOUT_FAILED
TAX_CALCULATED
REFUND_CREATED
MANUAL_ADJUSTMENT
```

---

# 39. Recommended Backend Modules

For a Serverpod-based backend:

```text
lib/
├── src/
│   ├── competition/
│   │   ├── competition_service.dart
│   │   ├── competition_repository.dart
│   │   └── competition_endpoint.dart
│   │
│   ├── payment/
│   │   ├── payment_service.dart
│   │   ├── payment_provider.dart
│   │   ├── hitpay_payment_provider.dart
│   │   └── payment_webhook_endpoint.dart
│   │
│   ├── payout/
│   │   ├── payout_service.dart
│   │   ├── payout_provider.dart
│   │   ├── hitpay_payout_provider.dart
│   │   └── payout_webhook_endpoint.dart
│   │
│   ├── ledger/
│   │   ├── ledger_service.dart
│   │   ├── ledger_repository.dart
│   │   └── ledger_transaction_service.dart
│   │
│   ├── tax/
│   │   ├── tax_service.dart
│   │   └── tax_rule_repository.dart
│   │
│   ├── identity/
│   │   └── kyc_service.dart
│   │
│   └── reconciliation/
│       └── reconciliation_service.dart
```

---

# 40. API Design

Suggested endpoints:

```text
POST   /competitions
GET    /competitions
GET    /competitions/{id}

POST   /competitions/{id}/join
GET    /competitions/{id}/entries

POST   /payments/{id}/refund

POST   /webhooks/hitpay

GET    /competitions/{id}/results
POST   /competitions/{id}/finalize-results

GET    /users/me/payout-accounts
POST   /users/me/payout-accounts

GET    /payouts/{id}

POST   /webhooks/hitpay/payouts
```

Financial operations should generally be server-controlled and not directly exposed as arbitrary client-side mutations.

---

# 41. Example End-to-End Transaction

## Step 1 — Participant enters

```text
Entry fee = ₱100
```

HitPay collects:

```text
₱100
```

Backend records:

```text
Entry = CONFIRMED
```

## Step 2 — Allocate funds

```text
Prize allocation = ₱90
Platform fee     = ₱10
```

## Step 3 — HitPay fee

Assume:

```text
HitPay fee = ₱2.30
```

Platform absorbs it.

## Step 4 — Competition ends

```text
Gross Prize Pool = ₱90,000
```

## Step 5 — Winners

```text
1st = ₱45,000
2nd = ₱27,000
3rd = ₱18,000
```

## Step 6 — Tax

Assuming a 20% withholding rate applies:

```text
1st:
₱45,000 gross
- ₱9,000 tax
= ₱36,000 net

2nd:
₱27,000 gross
- ₱5,400 tax
= ₱21,600 net

3rd:
₱18,000 gross
- ₱3,600 tax
= ₱14,400 net
```

## Step 7 — Payout

Platform absorbs payout fees.

```text
HitPay → Winner #1 = ₱36,000
HitPay → Winner #2 = ₱21,600
HitPay → Winner #3 = ₱14,400
```

## Step 8 — Tax remittance

Applicable withheld tax is recorded as a tax liability and remitted to the BIR according to the required process.

---

# 42. Recommended Financial Terminology

Use these terms throughout the product and backend:

| Concept | Recommended Term |
|---|---|
| Total participant payments | Gross Collection |
| 90% participant allocation | Gross Prize Pool |
| 10% platform allocation | Gross Platform Fee |
| Provider payment cost | Payment Processing Expense |
| Provider payout cost | Payout Expense |
| Winner's calculated prize | Gross Prize |
| Tax deducted from winner | Withholding Tax |
| Amount sent to winner | Net Payout |
| Amount owed to winners | Prize Liability |
| Tax owed to government | Tax Liability |
| Company's remaining economics | Platform Contribution/Margin |

Avoid calling the internal database balances:

```text
Escrow
Wallet
Stored Value
User Money
```

unless the legal/compliance structure supports those terms.

---

# 43. Product Display Recommendation

The user-facing competition page should clearly communicate:

```text
Entry Fee
₱100

Prize Pool
₱90,000

Platform Fee
Included in entry fee

Winner payouts
Subject to applicable taxes
```

For winner results:

```text
1st Place
Gross Prize: ₱45,000
Less applicable tax: ₱9,000
Estimated Net Payout: ₱36,000
```

The exact wording should be reviewed by legal/tax counsel.

---

# 44. Business Economics Formula

For each competition:

```text
Gross Collection
    = Number of Confirmed Entries × Entry Fee

Gross Prize Pool
    = Gross Collection × Prize Percentage

Gross Platform Fee
    = Gross Collection × Platform Fee Percentage

Platform Contribution
    = Gross Platform Fee
      - Payment Processing Expenses
      - Payout Expenses
      - Other Direct Payment Costs
```

Winner:

```text
Gross Winner Prize
    = Gross Prize Pool × Winner Allocation

Tax Withheld
    = Gross Winner Prize × Applicable Tax Rate

Net Winner Payout
    = Gross Winner Prize - Tax Withheld
```

The tax formula must support exemptions, thresholds, different tax categories, and future rule changes.

---

# 45. Important Business Rules

1. The platform fee is determined when the competition is created.
2. Prize percentage + platform fee percentage must equal 100%, unless an explicitly documented additional allocation exists.
3. Payment-provider fees are absorbed by the platform.
4. Payout-provider fees are absorbed by the platform.
5. Applicable winner taxes are deducted from gross winner prizes.
6. Tax withheld is never treated as platform revenue.
7. The gross prize pool is not reduced by payment-provider fees.
8. A payment is confirmed only through a trusted provider confirmation/webhook.
9. A payout is considered complete only after final provider confirmation.
10. Every money movement produces an immutable ledger transaction.
11. Financial corrections use reversal/adjustment transactions.
12. Competition results become immutable once finalized.
13. Refunds and cancellations have explicit accounting flows.
14. All financial operations are auditable.
15. The payment provider's approved business model and compliance requirements override assumptions in this document.

---

# 46. Pre-Launch Checklist

- [ ] Register appropriate Philippine business entity.
- [ ] Confirm competition model with Philippine legal counsel.
- [ ] Confirm whether the competition is considered a regulated gaming/prize activity.
- [ ] Confirm tax treatment with a Philippine tax professional.
- [ ] Confirm withholding-agent responsibilities.
- [ ] Open appropriate business bank account.
- [ ] Apply for HitPay business/merchant account.
- [ ] Submit the competition business model to HitPay compliance.
- [ ] Confirm HitPay supports participant-funded prize pools.
- [ ] Confirm HitPay payout support for intended winner destinations.
- [ ] Confirm payment settlement timing.
- [ ] Confirm payout fees.
- [ ] Confirm refund/chargeback treatment.
- [ ] Confirm payout limits.
- [ ] Confirm KYC requirements.
- [ ] Confirm required business documents.
- [ ] Implement payment webhooks.
- [ ] Implement payout webhooks.
- [ ] Implement idempotency.
- [ ] Implement immutable double-entry ledger.
- [ ] Implement reconciliation.
- [ ] Implement audit logging.
- [ ] Implement tax-rule configuration.
- [ ] Test cancellation/refund scenarios.
- [ ] Test payout failure/retry scenarios.
- [ ] Perform end-to-end financial reconciliation before production.

---

# 47. Final Recommended Architecture

```text
                         ┌────────────────────┐
                         │      Flutter       │
                         └─────────┬──────────┘
                                   │
                                   ▼
                         ┌────────────────────┐
                         │   Serverpod API    │
                         └─────────┬──────────┘
                                   │
          ┌────────────────────────┼────────────────────────┐
          │                        │                        │
          ▼                        ▼                        ▼
   Competition Service       Payment Service          Payout Service
          │                        │                        │
          │                        ▼                        ▼
          │                  HitPay Payment          HitPay Payout
          │                        │                        │
          │                        │                        │
          └───────────────┬────────┴────────────────────────┘
                          ▼
                   Ledger Service
                          │
              ┌───────────┼────────────┐
              │           │            │
              ▼           ▼            ▼
        Prize Liability  Revenue   Tax Liability
              │           │            │
              │           │            ▼
              │           │           BIR
              │           │
              │           ▼
              │      Business Bank
              │
              ▼
           Winners
              │
              ▼
        GCash / Maya / Bank
```

## Core principle

The platform should own the **business logic and accounting ledger**, while the payment provider owns the **payment rails and provider-side settlement/payout infrastructure**.

The business model is:

```text
Participant Entry
       │
       ▼
Gross Collection
       │
       ├── 90% → Gross Prize Pool
       │
       └── 10% → Gross Platform Fee
                         │
                         ├── Payment Provider Fees
                         └── Payout Provider Fees
                                  │
                                  ▼
                         Platform Contribution
```

And the winner model is:

```text
Gross Prize
     │
     └── Applicable Withholding Tax
                │
                ▼
          Net Winner Payout
```

This keeps **prize money, platform revenue, provider expenses, and tax liabilities clearly separated**, which is the central design principle for the entire payment architecture.

---

# 48. MVP Payment and Payout Scope

The MVP intentionally supports only e-wallets and cards for participant payments, and GCash/Maya for winner payouts.

## Participant Payments

Supported:
- GCash
- Maya
- Credit Card
- Debit Card

Deferred:
- QR Ph
- Online Banking
- Bank Transfer

The exact production methods depend on HitPay's current Philippine capabilities and the methods approved for the merchant account.

## Payment Method Enum

```text
GCASH
MAYA
CREDIT_CARD
DEBIT_CARD
```

---

# 49. Payment Accounts and Saved Cards

A payment transaction and a saved payment account are separate concepts.

```text
payment_accounts
────────────────────────────
id
user_id
provider
provider_customer_id
provider_payment_method_id
type
subtype
brand
last4
is_default
status
created_at
updated_at
```

For saved cards, use provider tokenization/references. Never store full card numbers, CVV/CVC, PIN, or OTP.

Example display:

```text
Visa •••• 4242
```

Saved cards are reusable only where HitPay's approved integration supports reusable payment methods.

GCash/Maya should not automatically be treated as reusable credentials; they may require fresh authorization for each payment depending on the provider flow.

---

# 50. Payment Flow

```text
Flutter
   │
   ▼
Select Payment Method
   │
   ├── GCash
   ├── Maya
   ├── Credit Card
   └── Debit Card
   │
   ▼
Serverpod Backend
   │
   ▼
HitPay
   │
   ▼
Checkout / Authorization
   │
   ▼
Participant Pays
   │
   ▼
HitPay Webhook
   │
   ▼
Backend Verification
   │
   ▼
Competition Entry = CONFIRMED
```

The client must never be the authority for successful payment.

---

# 51. Payment Transaction Record

```text
payments
────────────────────────────
id
user_id
competition_id
payment_account_id
provider
provider_payment_id
payment_method_type
payment_method_subtype
brand
last4
amount
currency
status
provider_fee
settlement_status
created_at
paid_at
updated_at
```

Keep an immutable snapshot of non-sensitive payment-method metadata so historical payments remain understandable after a saved payment account is deleted.

---

# 52. Payment vs Payout

Payment and payout methods are independent.

```text
Payment Method
    = How a participant pays

Payout Method
    = Where a winner receives the prize
```

Examples:

```text
Pay: Credit Card
Receive: GCash
```

or:

```text
Pay: GCash
Receive: Maya
```

Therefore:

```text
Payment Method ≠ Payout Method
```

---

# 53. MVP Winner Payout Methods

For the MVP:

```text
GCASH
MAYA
```

Deferred:

```text
BANK_ACCOUNT
```

A winner must have an eligible payout destination before the prize can be released.

---

# 54. Payout Accounts

Keep payout accounts separate from payment accounts.

```text
payout_accounts
────────────────────────────
id
user_id
provider
provider_recipient_id
provider_account_id
type
masked_identifier
is_default
status
verified_at
created_at
updated_at
```

Example:

```text
GCASH
09******1234
ACTIVE
DEFAULT
```

or:

```text
MAYA
09******5678
ACTIVE
```

Store provider references and masked identifiers, not wallet credentials.

---

# 55. Winner Payout Account Setup

Users should be able to configure a payout destination before they win.

```text
Prize Payout Accounts

● GCash ••••1234    ✓ Verified
○ Maya  ••••5678    ✓ Verified
```

Actions:

```text
Add GCash
Add Maya
Set Default
Remove
```

Whether an account can be permanently linked depends on HitPay's current payout API and recipient model. If provider verification is required, the backend should perform it before the account becomes ACTIVE.

---

# 56. Winner Payout Flow

```text
Competition Ends
       │
       ▼
Determine Winners
       │
       ▼
Winner Confirmed
       │
       ▼
Check Payout Account
       │
       ├── Missing → Request setup
       │
       └── Valid
              │
              ▼
       KYC / Eligibility Check
              │
              ▼
       Calculate Gross Prize
              │
              ▼
       Calculate Withholding Tax
              │
              ▼
       Calculate Net Payout
              │
              ▼
       Create Payout
              │
              ▼
       HitPay Payout API
              │
         ┌────┴────┐
         ▼         ▼
       GCash      Maya
         │         │
         └────┬────┘
              ▼
       Provider Confirmation
              │
              ▼
        Payout = SUCCESS
```

---

# 57. Payout Eligibility Checks

Before submitting a payout, verify:

1. Competition results are finalized.
2. Winner is CONFIRMED.
3. Winner has an eligible payout account.
4. Payout destination is supported.
5. Account ownership/verification requirements are satisfied.
6. Required KYC/identity checks are complete.
7. Required tax information is available.
8. Gross prize is correct.
9. Tax is calculated.
10. Net payout is positive.
11. No previous successful payout exists.
12. Prize liability is sufficient.
13. No payout is already processing.

---

# 58. Payout Calculation

Example:

```text
Gross Prize                  ₱45,000
Withholding Tax               -₱9,000
Payout Fee to Winner              ₱0
────────────────────────────────────
Net Winner Payout             ₱36,000
```

If HitPay charges a ₱50 payout fee:

```text
Winner receives                ₱36,000
Platform payout expense            ₱50
```

The payout fee does not reduce the winner's net payout because the platform absorbs it.

---

# 59. Payout Record

```text
payouts
────────────────────────────
id
competition_id
winner_id
user_id
payout_account_id
provider
provider_payout_id
payout_method_type
gross_prize_amount
tax_withheld_amount
payout_fee_amount
net_payout_amount
tax_rule_id
status
requested_at
processed_at
completed_at
failure_reason
created_at
updated_at
```

---

# 60. Payout State Machine

```text
PENDING
   │
   ▼
ELIGIBILITY_CHECK
   │
   ▼
READY
   │
   ▼
PROCESSING
   │
   ├───────────────┐
   ▼               ▼
SUCCESS          FAILED
                   │
                   ▼
              RETRY_PENDING
                   │
                   ▼
               PROCESSING
```

Permanent failures should transition to MANUAL_REVIEW.

A payout is successful only after final provider confirmation/webhook.

---

# 61. Payout Security

Never store:

```text
GCash PIN
Maya PIN
OTP
Full wallet credentials
```

Recommended controls:

- Require re-authentication for payout-account changes.
- Verify payout-account ownership where supported.
- Record payout-account changes in audit logs.
- Never accept arbitrary provider recipient IDs from the client.
- Resolve recipients from the authenticated user's verified payout accounts.
- Consider a security cooldown after changing a payout destination for high-value prizes.
- Revalidate the payout destination immediately before payout.

---

# 62. Final MVP Payment/Payout Architecture

```text
                         USER
                          │
             ┌────────────┴────────────┐
             │                         │
             ▼                         ▼
       PAYMENT ACCOUNT           PAYOUT ACCOUNT
             │                         │
       ┌─────┴─────┐             ┌─────┴─────┐
       │           │             │           │
     CARD       E-WALLET       GCASH       MAYA
       │           │
       └─────┬─────┘
             │
             ▼
           HitPay
             │
             ▼
        Competition
             │
             ▼
          Winners
             │
             ▼
           HitPay
             │
       ┌─────┴─────┐
       ▼           ▼
     GCash        Maya
       │           │
       └─────┬─────┘
             ▼
           Winner
```

## Core Principle

The platform owns competition logic, payment records, prize calculation, tax calculation, payout orchestration, financial ledger, reconciliation, and audit records.

HitPay handles payment/payout rails and sensitive payment credentials according to the approved integration.

> **The platform absorbs payment and payout transaction fees. Winners absorb applicable taxes. Participant payment methods and winner payout destinations are independent.**
