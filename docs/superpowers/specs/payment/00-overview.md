# Payment & Payout Architecture Spec — Overview

**Date:** 2026-08-28
**Spec:** `docs/superpowers/specs/payment/00-overview.md`
**Parent Spec:** `docs/superpowers/specs/prize_pool_competition_payment_architecture_spec.md`

## Sub-Specs

| File | Description |
|------|-------------|
| `00-overview.md` | Scope, fee structure, architecture overview, core principles |
| `01-server-models.md` | Database schema, enums, state machines |
| `02-server-architecture.md` | Feature structure, interfaces, DI, Chopper client |
| `03-server-endpoints.md` | API endpoints (player, admin, webhooks) |
| `04-flutter-architecture.md` | Flutter features, widgets, routing |
| `05-testing.md` | Testing strategy |
| `06-provider-integration.md` | HitPay integration TODOs |

## 1. Scope

Full payment collection and prize payout flow for Baktaz competitions:
- Entry fee collection via HitPay (GCash, Maya, Credit Card, Debit Card)
- Double-entry financial ledger
- Winner prize calculation with tax withholding
- Host cut distribution (0.5% configurable)
- Payout via GCash/Maya to winners and host
- Payment method management (saved cards/wallets)
- Payout destination management

## 2. Architecture Overview

**Server Feature:** `lib/src/features/payment/` (single feature, merged payment + payout)
**Flutter Features:** `lib/features/payment/`, `lib/features/payout/` (separate features for UI)

### Core Principle
Platform owns business logic and accounting ledger. HitPay owns payment rails. Provider fees absorbed by platform for entry; winner/host absorbs payout fees.

## 3. Fee Structure

| Fee | Who Absorbs | % | When Computed |
|-----|-------------|---|---------------|
| Entry fee | — | 100% | User pays |
| Prize pool | — | 90% of gross | On payment confirmation |
| Platform fee | Platform | 10% of gross | On payment confirmation |
| Payment processing | Platform | ~2.3% | On payment webhook |
| Host cut | Host | 0.5% of prize pool | On winner determination |
| Winner payout fee | Winner | Variable | On payout creation |
| Host payout fee | Host | Variable | On payout creation |
| Tax withholding | Winner | Configurable | On payout calculation |

**Example (₱100 entry, 1,000 participants):**
```
Gross Collection:              ₱100,000
├── Prize Pool (90%):          ₱90,000
│   ├── Winner Prizes (99.5%): ₱89,550
│   └── Host Cut (0.5%):       ₱450
└── Platform Fee (10%):        ₱10,000

Platform Contribution:
├── Platform Fee:              ₱10,000
└── Payment Processing Fee:    -₱2,300
    ─────────────────────────────
    Net:                       ₱7,700
```

## 4. Provider Integration Decisions

| Conflict | Resolution |
|----------|------------|
| Wallet vs Payment Entry | Option A — Payment Intent Flow via HitPay |
| Payout Destination | Option A — Direct external payout (GCash/Maya) |
| State Machine | Option C — Hybrid (full on server, mapped for Flutter) |
| Host Cut Visibility | Option C — Selective (host-only, not public) |
| Refund Handling | Option A — Full refund via HitPay API |
| Payment Intent vs Join | Option A — Payment intent first |
| Tax Withholding | Option A — Include in MVP |
