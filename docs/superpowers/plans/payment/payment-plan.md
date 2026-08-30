# Payment & Payout Implementation Plan

> **Parent Canonical Roadmap:** Governed by and aligned with the Master Integration Plan in [`/Users/Arnold/Projects/baktaz/docs/superpowers/plans/2026-08-30-master-integration-plan.md`](../2026-08-30-master-integration-plan.md).
> All models, paths, and invariants (webhook idempotency verification via `gatewayTransactionId`, double-entry ledger debit/credit balance verification, tax withholding & 10% host cut distribution rules, Serverpod 2.x backend repository isolation of `HitPayService`, `session.auth.authenticatedUserId` identity derivation, Pattern B error handling, `TaskResult<T>` repository returns, and implementation-first testing workflows) strictly conform to the master roadmap.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement full payment collection and prize payout flow for Baktaz competitions using HitPay provider, with double-entry ledger, tax withholding, and host cut distribution.

**Architecture:** Single `payment` server feature with merged `IPaymentProvider` and `IPaymentRepository`. Chopper client for HitPay API. Flutter payment/payout features with payment method selector widget embedded in challenge flow.

**Tech Stack:** Serverpod 2.x, Chopper 8.x, Dart 3.13, bloc_signals, injectable, freezed, mockito, alchemist

**Spec:** `docs/superpowers/specs/payment/00-overview.md`

## Sub-Plans

| File | Description |
|------|-------------|
| `00-server-models.md` | Database models, migrations, ledger seeder |
| `01-chopper-client.md` | HitPay Chopper client, DTOs |
| `02-provider-interfaces.md` | IPaymentProvider interface, HitPayService |
| `03-repository.md` | IPaymentRepository, PaymentRepository |
| `04-endpoints.md` | PaymentEndpoint, PayoutEndpoint, WebhookEndpoint |
| `05-flutter-features.md` | Flutter payment/payout features, widgets |
| `06-testing.md` | Server and Flutter tests |
| `07-cleanup.md` | Wallet removal, final verification |

## Global Constraints

- Target packages: `baktaz_server`, `baktaz_flutter`
- Dart SDK: `>=3.13.0 <4.0.0`
- Flutter: `>=3.47.0`
- Serverpod: `4.0.0-beta.3`
- Money representation: `double` (matches Wallet.cashBalance convention)
- PKs: `UuidValue` over `int`
- No raw SQL; migrations only
- Repository throws on failure; endpoints translate to client exceptions
- Chopper for all external HTTP calls
- `mockito` only for testing
- Widget tests = golden tests (Alchemist, 15% tolerance)
- No interface tests
- No screen tests (only widgets)

## Read Sub-Plans

Execute sub-plans in order:
1. `00-server-models.md` — Foundation
2. `01-chopper-client.md` — Provider client
3. `02-provider-interfaces.md` — Service implementation
4. `03-repository.md` — Repository
5. `04-endpoints.md` — Endpoints
6. `05-flutter-features.md` — Flutter features
7. `06-testing.md` — Testing
8. `07-cleanup.md` — Cleanup
