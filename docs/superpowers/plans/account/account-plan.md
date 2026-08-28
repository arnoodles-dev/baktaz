# Account Feature Master Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Provide a comprehensive, full-stack roadmap for implementing the Account & Wallet Tab feature set (`/account`) across Serverpod backend (`baktaz_server`), client SDK (`baktaz_client`), and Flutter frontend (`baktaz_flutter`).

**Architecture:** Full-stack architecture incorporating Serverpod 2.x data models & RPC endpoints, reactive Flutter state controllers (`CubitSignal<S>`), `fpdart` `TaskResult<T>` error handling, typed `go_router` navigation, and DESIGN.md compliant UI components.

**Tech Stack:** Dart 3.x, Flutter, Serverpod 2.x, PostgreSQL, `bloc_signals_flutter`, `fpdart`, `alchemist`, `go_router`.

**Spec:** `docs/specs/account_feature_spec.md`

## Global Constraints

- **Scope Limits:** Stored in-app wallet balance, internal ledger, referral hubs, bio, ratings, and saved delivery addresses are EXCLUDED.
- **Repository Contracts:** All Flutter repository methods MUST return `TaskResult<T>` (`Either<Failure, T>`). Never throw exceptions.
- **Error Handling:** Pattern B error handling enforced (state holds continuous values, side effects handled via events).
- **Host Cut Rule:** 10% host fee cut is forfeited to the winner pool if the host's subscription is expired on the challenge completion date.
- **Testing Sequence:** Testing (`04-testing.md`) occurs ONLY after implementation (00-03) and code generation are 100% completed across all packages.

---

## Sub-Plans Roadmap

The implementation plan is broken down into 5 sequential sub-plans. Each sub-plan is bite-sized, self-contained, and independently testable.

| Step | Sub-Plan Document | Focus & Scope |
|---|---|---|
| 0 | [`00-server-models.md`](./00-server-models.md) | Serverpod `.spy.yaml` data models (`UserInfo`, `AccountSummary`, `SubscriptionPackage`, `HostSubscription`, `Voucher`, `SavedPaymentMethod`, `PayoutDestination`), codegen (`serverpod generate`), and DB migrations (`serverpod create-migration`). |
| 1 | [`01-server-endpoints.md`](./01-server-endpoints.md) | Serverpod repositories (`AccountRepository`, `HostSubscriptionRepository`, `PayoutRepository`), RPC endpoints (`AccountEndpoint`, `HostSubscriptionEndpoint`, `PayoutEndpoint`), and `HostCutSettlementService` forfeiture logic. |
| 2 | [`02-flutter-core.md`](./02-flutter-core.md) | `baktaz_flutter` domain enums, repository interfaces, reactive Cubits (`AccountCubit`, `HostSubscriptionCubit`, `PaymentCubit`, `HealthSyncCubit`), and `@TypedGoRoute` definitions. |
| 3 | [`03-flutter-ui.md`](./03-flutter-ui.md) | Reusable Account widgets (`AccountHeaderCard`, `LifetimeStatsGrid`, `AccountMenuTile`, `LogoutConfirmationDialog`) and screens (`AccountPage`, `ProfileEditScreen`, `HostSubscriptionScreen`, `ManagePaymentScreen`, `HealthSyncScreen`). |
| 4 | [`04-testing.md`](./04-testing.md) | Unit tests (100% Cubits/Repos), Widget & Golden tests (80% UI baselines via `alchemist`), and Serverpod integration tests (`withServerpod`). |

---

## Execution Guide

### Recommended Workflow (Subagent-Driven)

1. Execute sub-plan [`00-server-models.md`](./00-server-models.md).
2. Execute sub-plan [`01-server-endpoints.md`](./01-server-endpoints.md).
3. Execute sub-plan [`02-flutter-core.md`](./02-flutter-core.md).
4. Execute sub-plan [`03-flutter-ui.md`](./03-flutter-ui.md).
5. Execute sub-plan [`04-testing.md`](./04-testing.md).

Run verification commands after each sub-plan before proceeding to the next step.
