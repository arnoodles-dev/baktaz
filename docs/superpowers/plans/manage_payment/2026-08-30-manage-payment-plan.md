# Manage Payment & Payout Implementation Plan — Overview

> **Parent Canonical Roadmap:** Governed by and aligned with the Master Integration Plan in [`/Users/Arnold/Projects/baktaz/docs/superpowers/plans/2026-08-30-master-integration-plan.md`](../2026-08-30-master-integration-plan.md).
> All models, paths, and invariants (max 5 saved payment methods limit via `AppConfig.maxSavedPaymentMethods = 5`, 1 active payout destination per user via DB unique index, Serverpod 2.x backend repository isolation of `HitPayService`, boundary RPC input validation, `session.auth.authenticatedUserId` identity derivation, Pattern B error handling, `TaskResult<T>` repository returns, and implementation-first testing workflows) strictly conform to the master roadmap.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Document Version:** 1.2  
**Date:** 2026-08-30  
**Rule Compliance:** 100% compliant with `.agents/rules/` (`flutter-architecture.md`, `serverpod-architecture.md`, `state-management-architecture.md`, `error-handling-architecture.md`, `design-system.md`, `testing.md`, `code-quality.md`).

**Goal:** Build unified `/account/payment` screen managing tokenized saved payment methods (HitPay) and single active payout destination (GCash, Maya, Bank).

**Architecture:** Extend `baktaz_server` account models (`SavedPaymentMethod`, `PayoutDestination`, `PaymentPayoutSummary`) and endpoints; consume via `baktaz_client` in `baktaz_flutter` with `ManagePaymentCubit` (`CubitSignal<ManagePaymentState>` with `initialState:` constructor) and `ManagePaymentScreen`.

**Tech Stack:** Dart, Flutter, Serverpod 2.x, `bloc_signals_flutter`, `fpdart`, `freezed`, `mockito`, `alchemist`.

**Spec:** `docs/superpowers/specs/manage_payment/2026-08-30-00-overview.md`

## Global Constraints
- Target packages: `baktaz_server`, `baktaz_client`, `baktaz_flutter`
- Strict 1 active payout destination per user (DB unique index in Serverpod `.spy.yaml`)
- Max saved payment methods limit: 5 (`AppConfig.maxSavedPaymentMethods = 5` in `lib/src/app/config/app_config.dart`)
- **Pattern B Error Handling**: `ManagePaymentCubit` wraps repo calls in `safeRun(onException:)`. `FailureHandler` triggers UI side effects; `ManagePaymentState` never holds `Failure` objects (`.agents/rules/error-handling-architecture.md`)
- **Flutter Cubit**: `CubitSignal<ManagePaymentState>` with `initialState:` named constructor. No god methods (`.agents/rules/flutter-architecture.md`, `state-management-architecture.md`)
- **Design System**: Exclusive use of `baktaz_shared` wrappers (`BaktazCard`, `BaktazButton`, `BaktazStatusBadge`, `BaktazTextField`, `BaktazSectionHeader`, `ConfirmationDialog`). User-facing text via `context.l10n.*` (`.agents/rules/design-system.md`)
- **Server Repository Pattern**: `@LazySingleton(as: Interface)` repositories (`IPaymentRepository`, `IPayoutRepository`) in `domain/interface/`. `HitPayService` isolated in `data/service/`. Endpoints depend on repos only (`.agents/rules/serverpod-architecture.md`)
- **Implementation-First Workflow**: All tasks are executed sequentially; codegen, migrations, and cross-package build must complete before any tests are written or run (`.agents/rules/testing.md`)

## Task Index
- `2026-08-30-00-server-models.md`: Task 1 - Serverpod `.spy.yaml` models, `AppConfig` limit, and codegen
- `2026-08-30-01-server-endpoints.md`: Task 2 - Backend repositories, `AccountEndpoint` RPCs, business logic & integration tests
- `2026-08-30-02-flutter-cubit.md`: Task 3 - Flutter `ManagePaymentCubit`, state & unit tests
- `2026-08-30-03-flutter-ui.md`: Task 4 - Flutter `ManagePaymentScreen`, HitPay webview channel, payout dialogs, challenge blocks & golden tests
- `2026-08-30-04-testing.md`: Task 5 - Test execution, coverage verification, and pre-merge finalization
