# 2026-08-22-06 Verification Plan

**Goal:** Comprehensive verification of all Challenge Page implementation plans.

## Pre-Phase: Dedicated Test Authoring

1. Repository unit tests — 100% target (TODO(server)-gated methods marked skip)
2. Cubit tests (bloc_test) per route — 100% target
3. Golden tests (Alchemist) — all views/screens/pages
4. Widget tests — ≥80% target

## Tasks

- [ ] **Task 1: Formatting**
  - Run `fvm dart format lib test` inside `baktaz_flutter`
  - Verify no formatting changes needed

- [ ] **Task 2: Code Generation**
  - Run `slang` codegen for localization
  - Run `build_runner` for freezed, injectable, json_serializable
  - Run `serverpod generate` for client SDK if models changed
  - Verify no generated file conflicts

- [ ] **Task 3: Static Analysis**
  - Run `dart analyze` across `baktaz_flutter`
  - Must pass with zero errors/warnings
  - `very_good_analysis` + `dart_code_metrics` with `--fatal-infos`

- [ ] **Task 4: Golden Tests (Alchemist)**
  - Run golden tests for:
    - `ChallengeInitialView` (Trophy Case layout)
    - `ChallengeRegisteredView` (Pro Challenge Hub with host card, dispute banners)
    - `ChallengeExploreScreen` (Discovery cards, filter sheet)
    - `ChallengeDetailsScreen` (Race Contract layout)
    - `ChallengeLeaderboardPage` (Arena Dashboard)
    - `ChallengeCreateScreen` (Ledger Form)
    - `RulesBottomSheet`
    - `AntiCheatVoteBottomSheet`
  - 15% tolerance threshold

- [ ] **Task 5: Unit Tests**
  - **Repository Tests** (100% coverage):
    - `ChallengeLifecycleRepository`, `ChallengeDiscoveryRepository`, `ChallengeLeaderboardRepository`
    - Serverpod client injection, TODO(server) stubs, TaskResult folding
    - Error handling (network vs server exceptions via FailureHandler)
  - **Cubit Tests** (100% coverage):
    - `ChallengeCubit` state transitions: `loading` → `initial`/`registered`/`done`
    - Background init check (enrollment check)
    - Invite code validation
    - Wallet checks (insufficient balance handling)
    - Non-refundable entry fee disclaimer confirmation
    - Refresh flow (dashboard fast path, ChallengeNotFound fallback)
    - Post-challenge reset to `.initial` (Q139, Q140)
    - Error handling via FailureHandler (no failure state)
  - Use `bloc_test` for Cubits, `fake_async` for async

- [ ] **Task 6: Widget Tests**
  - Focus on:
    - Form validation (create form, invite code input)
    - Navigation triggers
    - Dialog interactions (disclaimer, leave challenge, start challenge confirmation)
    - Filter bottom sheet interactions
    - Search debounce
    - Sort toggles
    - Infinite scroll triggers

- [ ] **Task 7: Coverage Verification**
  - Run `make test_app`
  - Verify coverage targets:
    - Overall: ≥80%
    - Unit Tests: 100%
    - Widget Tests: ≥80%

- [ ] **Task 8: DTD App Sanity Check**
  - Connect via DTD and verify challenge routes load
  - Check logs for errors

- [ ] **Task 9: Design System Compliance**
  - Verify no hardcoded colors/text/styles
  - Verify AppSizes, Paddings, Gap usage
  - Verify Baktaz* shared widgets

- [ ] **Task 10: Documentation Consistency**
  - Verify terminology ("Entry Fee" not "buy-in")
  - Verify file paths match project structure
  - Verify shared widget list matches *_shared

- [ ] **Task 11: Spec Cross-Check**
  - Verify each spec requirement has corresponding plan task
  - Check all 6 specs against plans
