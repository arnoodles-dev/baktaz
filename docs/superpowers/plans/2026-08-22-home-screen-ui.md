# Home Screen UI Implementation Plan (Fully Refined & Security-Hardened)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign and implement the Baktaz Home Screen (`/home`) UI across Phase A (Flutter Client UI & Logic), Phase B (Serverpod Backend RPC Endpoints & Models), and Phase C (Full Client & Server Test Suite). Every phase ends with an explicit user verification checkpoint. NO commits are made automatically.

**Architecture:** Full-Stack Clean Architecture (`presentation/`, `domain/`, `data/` / `endpoint/` layers):
- **Phase A — Flutter Client (`baktaz_flutter`)**:
  - *Presentation*: Atomic widgets (`hero/`, `chart/`, `challenge/`, `leaderboard/`), generic core widgets (`baktaz_rank_badge`, `baktaz_rank_trend`, `baktaz_stage_progress_bar`, `baktaz_leaders_strip`), `RefreshIndicator`, `RepaintBoundary`, `Skeletonizer`.
  - *Domain*: `@freezed` models with `baktaz_shared` Value Objects (`Number`, `ValueString`, `Money`, `Url`, `LocalDateTime`, `ValueBoolean`) and `get validate` rules, `IStepsRepository` and `IChallengeRepository` interfaces, `@injectable` `HomeCubit` (`CubitSignal<HomeState>` + `BlocSignalPresentationMixin`) with single-action methods.
  - *Data*: `SyncStepsService` (`@LazySingleton`), `StepsRepository` (`@LazySingleton`), `ChallengeRepository` (`@LazySingleton`) with `FlutterSecureStorage` encrypted persistence, `RetryOptions`, `RetryUtils` predicate, `fromServer` model mapping.
- **Phase B — Serverpod Backend (`baktaz_server`)**:
  - *Security & Config*: `HomeEndpoint` sets `requireLogin = true`, derives user ID from `session.auth.authenticatedUserId` (no client `userId` params), validates step range (0-100k), validates primary sync source, applies configurable daily step ceiling flagging (`AppConfig.maxDailyStepCeiling = 30000`), monotonic `max(existing, new)` updates, and strips PII from leaderboard outputs.
  - *Endpoint*: `HomeEndpoint` extending `Endpoint` in `lib/src/features/home/endpoint/home_endpoint.dart`.
  - *Domain*: `.spy.yaml` models under `domain/model/`, `IStepsRepository` and `IChallengeRepository` interfaces under `domain/interface/`.
  - *Data*: `StepsRepository` and `ChallengeRepository` (`@LazySingleton`) under `data/repository/` using `session.caches.local`.
- **Phase C — Full Test Suite (`baktaz_flutter` & `baktaz_server`)**:
  - Client Unit tests for Entities, `StepsRepository`, `ChallengeRepository`, `HomeCubit`.
  - Alchemist Golden visual tests for reusable component cards using `MockMaterialApp`.
  - Server Endpoint Unit tests for `HomeEndpoint`.

**Tech Stack:** Flutter, Dart, Serverpod 2.x, `bloc_signals_flutter`, `flutter_hooks`, `skeletonizer`, `alchemist` (Golden Testing), `flutter_secure_storage`, `baktaz_client`, `baktaz_shared`, `slang` (`strings.g.dart`), `go_router`, `responsive_framework`.

**Spec:** `docs/superpowers/specs/2026-08-22-home-screen-ui-design.md`

## Global Constraints
- Target packages: `baktaz_flutter` (Phase A), `baktaz_server` & `baktaz_client` (Phase B), Full Test Suite (Phase C).
- Delete legacy unused files: `baktaz_flutter/lib/features/home/presentation/home_shell_screen.dart` and `baktaz_flutter/lib/features/home/presentation/home_dashboard_view.dart`.
- Local Storage & Configurable Anti-Cheat Rules:
  - Encryption: Persist local step telemetry securely via `FlutterSecureStorage`.
  - Configurable Ceiling Flagging: Default ceiling threshold set to 30,000 steps/day (`AppConfig.maxDailyStepCeiling = 30000`). Steps > 30,000 flagged (`isFlaggedForReview = true`) for manual review before escrow payout.
  - Zero Manual Entries: Filter out `WAS_MANUALLY_ENTERED` (Health Connect) and `HKWasUserEntered` (HealthKit). Reject all manual inputs.
  - Monotonic DB Upsert: Apply `max(existingSteps, newSteps)` on database writes.
- User Verification Gates & Git Rules:
  - STOP after Phase A, stage files with `git add`, and ask user for verification before proceeding to Phase B.
  - STOP after Phase B, show backend codegen status, and ask user for verification before proceeding to Phase C (Tests).
  - STOP after Phase C, show full test suite summary, and present staged files to user.
  - ZERO automatic git commits. Wait for user to say "commit".
- Health Sync Architecture:
  - Create `SyncStepsService` (`@LazySingleton(as: ISyncStepsService)`) in `baktaz_flutter/lib/features/home/data/service/sync_steps_service.dart`.
  - Provide simulated step reads with structured `// TODO(...)` markers for Health Connect (Android), Apple HealthKit (iOS), Strava API, and Samsung Health.
  - `StepsRepository` orchestrates step fetch from `SyncStepsService`, uploads payload to `Serverpod.client.home.syncSteps()`, and updates encrypted `FlutterSecureStorage`.
  - `HomeEndpoint.syncSteps()` validates step range (0 <= steps <= 100,000) and invalidates `session.caches.local` for active challenge leaderboards.
- Retry Policy: Centralize retry exception checking in `baktaz_flutter/lib/app/helpers/utils/retry_utils.dart` (`RetryUtils.isRetryableException`).
- Shared Component Wrappers: MUST use `baktaz_shared` widgets (`BaktazText`, `BaktazCard`, `BaktazButton`, `BaktazAvatar`, `BaktazDivider`, `Paddings`, `AppSizes`, `Gap`, `StepFormatter`, `MoneyFormatter`).
- i18n Localization: No hardcoded user-facing strings; use `context.i18n.home.*`. Update `assets/i18n/en.i18n.json`.
- Deferred Codegen Workflow: Apply all code changes first → run batch codegen (`fvm dart run slang && fvm dart run build_runner build --delete-conflicting-outputs` for client, `serverpod generate` for server) → run tests.
- Apply TDD: Write test first (RED), implement minimum code (GREEN), refactor.

---

## PHASE A: FLUTTER CLIENT IMPLEMENTATION (`baktaz_flutter`)

### Task 1: Clean Up Legacy Files & Update i18n Translations

**Files:**
- Delete: `baktaz_flutter/lib/features/home/presentation/home_shell_screen.dart`
- Delete: `baktaz_flutter/lib/features/home/presentation/home_dashboard_view.dart`
- Modify: `baktaz_flutter/assets/i18n/en.i18n.json`

- [ ] **Step 1: Delete legacy unused files**
- [ ] **Step 2: Add new Home translation keys to `assets/i18n/en.i18n.json`**

---

### Task 2: Create Generic Core Reusable Widgets

**Files:**
- Create: `baktaz_flutter/lib/core/presentation/widgets/baktaz_rank_badge.dart`
- Create: `baktaz_flutter/lib/core/presentation/widgets/baktaz_rank_trend.dart`
- Create: `baktaz_flutter/lib/core/presentation/widgets/baktaz_stage_progress_bar.dart`
- Create: `baktaz_flutter/lib/core/presentation/widgets/baktaz_leaders_strip.dart`

- [ ] **Step 1: Implement 4 core widgets using `BaktazText`, `BaktazAvatar`**

---

### Task 3: Create Hero Card Subcomponents (`widgets/hero/`)

**Files:**
- Create: `baktaz_flutter/lib/features/home/presentation/widgets/hero/home_daily_step_header.dart`
- Create: `baktaz_flutter/lib/features/home/presentation/widgets/hero/home_daily_step_linear_gauge.dart`
- Create: `baktaz_flutter/lib/features/home/presentation/widgets/hero/home_daily_step_sync_footer.dart`
- Create: `baktaz_flutter/lib/features/home/presentation/widgets/home_daily_step_hero_card.dart`

- [ ] **Step 1: Implement hero sub-widgets & HeroCard using `BaktazCard`, `BaktazText`, `Paddings`, `Gap`**

---

### Task 4: Create Weekly Chart Subcomponents (`widgets/chart/`)

**Files:**
- Create: `baktaz_flutter/lib/features/home/presentation/widgets/chart/home_weekly_chart_header.dart`
- Create: `baktaz_flutter/lib/features/home/presentation/widgets/chart/home_weekly_bar_item.dart`
- Create: `baktaz_flutter/lib/features/home/presentation/widgets/chart/home_weekly_total_footer.dart`
- Create: `baktaz_flutter/lib/features/home/presentation/widgets/home_weekly_steps_chart.dart`

- [ ] **Step 1: Implement chart sub-widgets & WeeklyStepsChart using `BaktazCard`, `BaktazText`, `Paddings`, `Gap`**

---

### Task 5: Create Active Challenge Ticker Subcomponents (`widgets/challenge/`)

**Files:**
- Create: `baktaz_flutter/lib/features/home/presentation/widgets/challenge/home_challenge_discovery_banner.dart`
- Create: `baktaz_flutter/lib/features/home/presentation/widgets/home_active_challenge_ticker.dart`

- [ ] **Step 1: Implement challenge sub-widgets using `BaktazCard`, `BaktazButton`, `BaktazDivider`, `BaktazRankBadge`, `BaktazLeadersStrip`, `BaktazStageProgressBar`**

---

### Task 6: Create Leaderboard Preview Subcomponents (`widgets/leaderboard/`)

**Files:**
- Create: `baktaz_flutter/lib/features/home/presentation/widgets/leaderboard/home_leaderboard_row.dart`
- Create: `baktaz_flutter/lib/features/home/presentation/widgets/home_leaderboard_preview.dart`

- [ ] **Step 1: Implement leaderboard sub-widgets using `BaktazCard`, `BaktazAvatar`, `BaktazRankTrend`, `BaktazButton`, `BaktazDivider`**

---

### Task 7: Define Home Domain Entities, Value Objects & Client Repository Interfaces

**Files:**
- Create: `baktaz_flutter/lib/features/home/domain/interface/i_steps_repository.dart`
- Create: `baktaz_flutter/lib/features/home/domain/interface/i_challenge_repository.dart`
- Create: `baktaz_flutter/lib/features/home/domain/entity/model/daily_step_telemetry.dart`
- Create: `baktaz_flutter/lib/features/home/domain/entity/model/weekly_step_analytics.dart`
- Create: `baktaz_flutter/lib/features/home/domain/entity/model/active_challenge_summary.dart`
- Create: `baktaz_flutter/lib/features/home/domain/entity/model/home_leaderboard_entry.dart`

- [ ] **Step 1: Implement `IStepsRepository` & `IChallengeRepository` interfaces and domain entities with `fromServer` and `get validate`**

---

### Task 8: Create `SyncStepsService`, `RetryUtils`, `StepsRepository` & `ChallengeRepository`

**Files:**
- Create: `baktaz_flutter/lib/features/home/data/service/i_sync_steps_service.dart`
- Create: `baktaz_flutter/lib/features/home/data/service/sync_steps_service.dart`
- Create: `baktaz_flutter/lib/app/helpers/utils/retry_utils.dart`
- Create: `baktaz_flutter/lib/features/home/data/repository/steps_repository.dart`
- Create: `baktaz_flutter/lib/features/home/data/repository/challenge_repository.dart`

**Interfaces:**
- Consumes: `SyncStepsService`, `Serverpod` client (`_serverpod.client.home`), `FlutterSecureStorage`, `RetryOptions`, `RetryUtils`, `Talker`
- Produces: `SyncStepsService` implementation (`@LazySingleton(as: ISyncStepsService)`), `RetryUtils.isRetryableException` predicate, `@LazySingleton(as: IStepsRepository) StepsRepository` with `FlutterSecureStorage` encrypted persistence, and `@LazySingleton(as: IChallengeRepository) ChallengeRepository`.

- [ ] **Step 1: Implement `ISyncStepsService`, `SyncStepsService` (with `// TODO` platform markers), `RetryUtils`, `@LazySingleton(as: IStepsRepository) StepsRepository`, and `@LazySingleton(as: IChallengeRepository) ChallengeRepository`**

---

### Task 9: Refactor `HomeState` & `HomeCubit` (Injecting `IStepsRepository` & `IChallengeRepository`)

**Files:**
- Modify: `baktaz_flutter/lib/features/home/domain/cubit/home/home_state.dart`
- Modify: `baktaz_flutter/lib/features/home/domain/cubit/home/home_cubit.dart`

- [ ] **Step 1: Refactor `HomeState` with section-specific `QueryStatus` fields (`telemetryQueryStatus`, `weeklyQueryStatus`, `activeChallengeQueryStatus`, `leaderboardQueryStatus`) and `@injectable` `HomeCubit` integrating `FailureHandler` and `ErrorActions`**

---

### Task 10: Assemble `HomePage` Dashboard View & Execute Client Codegen

**Files:**
- Modify: `baktaz_flutter/lib/features/home/presentation/views/home_page.dart`

- [ ] **Step 1: Update `HomePage` implementation**

Integrate all subcomponents into `HomePage`'s `CustomScrollView` wrapped in `RefreshIndicator`, `RepaintBoundary`, `Skeletonizer`, section error retry banners, and `BaktazErrorScreen` fallback. Connect `goBranch(1)` for Challenge tab switching.

- [ ] **Step 2: Run Batch Codegen Across Client**

Run: `cd baktaz_flutter && fvm dart run slang && fvm dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Stage Files & Stop for Phase A User Verification Gate**

Run: `git add baktaz_flutter/`
Present changed files to user and wait for user's explicit verification before proceeding to Phase B.

---

## PHASE B: SERVERPOD BACKEND (`baktaz_server`)

### Task 11: Create Serverpod Backend Models, Repositories & Endpoints (`baktaz_server`)

**Files:**
- Create: `baktaz_server/lib/src/features/home/domain/model/daily_step_telemetry.spy.yaml`
- Create: `baktaz_server/lib/src/features/home/domain/model/weekly_step_analytics.spy.yaml`
- Create: `baktaz_server/lib/src/features/home/domain/model/active_challenge_summary.spy.yaml`
- Create: `baktaz_server/lib/src/features/home/domain/model/home_leaderboard_entry.spy.yaml`
- Create: `baktaz_server/lib/src/features/home/domain/interface/i_steps_repository.dart`
- Create: `baktaz_server/lib/src/features/home/domain/interface/i_challenge_repository.dart`
- Create: `baktaz_server/lib/src/features/home/data/repository/steps_repository.dart`
- Create: `baktaz_server/lib/src/features/home/data/repository/challenge_repository.dart`
- Create: `baktaz_server/lib/src/features/home/endpoint/home_endpoint.dart`

- [ ] **Step 1: Create `.spy.yaml` models, `IStepsRepository` & `IChallengeRepository` interfaces, `StepsRepository` & `ChallengeRepository` with `session.caches.local`, and `HomeEndpoint` with single-source validation, anti-cheat manual entry rejection, configurable daily 30k ceiling flagging (`AppConfig.maxDailyStepCeiling = 30000`), monotonic `max(existing, new)` updates, anti-spoofing validation (0-100k steps/day), and cache invalidation**
- [ ] **Step 2: Run `cd baktaz_server && serverpod generate` to update `baktaz_client`**
- [ ] **Step 3: Stage Files & Stop for Phase B User Verification Gate**

Run: `git add baktaz_server/ baktaz_client/`
Present backend changes to user and wait for user's explicit verification before proceeding to Phase C.

---

## PHASE C: FULL TEST SUITE (`baktaz_flutter` & `baktaz_server`)

### Task 12: Register Mocks, Write Client & Server Tests, & Verify Full Suite

**Files:**
- Modify: `baktaz_flutter/test/utils/generated_mocks.dart` (Add `MockSpec<IStepsRepository>()`, `MockSpec<IChallengeRepository>()`, `MockSpec<ISyncStepsService>()`)
- Modify: `baktaz_flutter/test/flutter_test_config.dart` (Add `provideDummy<TaskResult<T>>` entries)
- Create: `baktaz_flutter/test/widget/core/baktaz_core_widgets_test.dart`
- Create: `baktaz_flutter/test/widget/home/home_daily_step_hero_card_test.dart`
- Create: `baktaz_flutter/test/widget/home/home_weekly_steps_chart_test.dart`
- Create: `baktaz_flutter/test/widget/home/home_active_challenge_ticker_test.dart`
- Create: `baktaz_flutter/test/widget/home/home_leaderboard_preview_test.dart`
- Create: `baktaz_flutter/test/unit/home_entities_test.dart`
- Create: `baktaz_flutter/test/unit/steps_repository_test.dart`
- Create: `baktaz_flutter/test/unit/challenge_repository_test.dart`
- Create: `baktaz_flutter/test/unit/home_cubit_test.dart`
- Create: `baktaz_server/test/features/home/home_endpoint_test.dart`

- [ ] **Step 1: Register `MockSpec<IStepsRepository>()`, `MockSpec<IChallengeRepository>()`, and `MockSpec<ISyncStepsService>()` in `generated_mocks.dart` and `provideDummy` entries in `flutter_test_config.dart`**
- [ ] **Step 2: Run build_runner to generate mocks (`cd baktaz_flutter && fvm dart run build_runner build --delete-conflicting-outputs`)**
- [ ] **Step 3: Write Alchemist golden tests for core widgets and cards using `MockMaterialApp`**
- [ ] **Step 4: Write Unit tests (100% coverage) for Entities, `StepsRepository`, `ChallengeRepository`, and `HomeCubit`**
- [ ] **Step 5: Write Server Endpoint Unit Test (`baktaz_server/test/features/home/home_endpoint_test.dart`)**
- [ ] **Step 6: Run Full Verification Test Suite Across Client and Server**

Run: `cd baktaz_flutter && fvm flutter test && cd ../baktaz_server && fvm dart test`

- [ ] **Step 7: Stage All Files & Present to User**

Run: `git add .agents/rules/testing.md baktaz_server/ baktaz_client/ baktaz_flutter/`
Present test results and staged files to user. Do NOT commit. Wait for user to say "commit".
