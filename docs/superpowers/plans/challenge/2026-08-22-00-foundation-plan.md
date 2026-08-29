# 2026-08-22-00 Foundation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish the foundational challenge page infrastructure — domain entities, repository layer, Cubit state machine, typed navigation, and shared widget list — enabling all subsequent route plans to build on consistent foundations.

**Architecture:** 
- Domain layer: `@freezed` entities and enums for Challenge, RewardMode, TieBreaker, LaunchType
- Repository: three split repositories (`Lifecycle`, `Discovery`, `Leaderboard`) — Serverpod-ready (no mocks)
- State: `ChallengeCubit` extending `CubitSignal<ChallengeState>` with `initialState:` named constructor
- Navigation: `go_router` typed routes under `/challenge` (explore, detail, create, leaderboard)
- Shared widget list from spec 06-shared-models.md
- **TODO(payment)**: Payment integration deferred — challenge feature builds stubs for payment flow

**Tech Stack:** Flutter, Dart, bloc_signals, freezed, injectable, go_router, alchemist (goldens).

**Spec:** `docs/superpowers/specs/Challenge/2026-08-22-00-overview.md` and `docs/superpowers/specs/Challenge/2026-08-22-06-shared-models.md`

## Global Constraints
- Target package: `baktaz_flutter` (`lib/features/challenge`)
- Dart SDK >= 3.13.0
- Maximum file length: 400 lines
- Domain uses baktaz_shared Value Objects (`Money` for entry fee, `Number` for steps/participants/duration) + every entity exposes `Option<Failure> get validate` getter chained via andThen (HomeLeaderboardEntry pattern)
- Data layer is Serverpod-ready: constructor-injected `Client` from `baktaz_client`, no mock repositories; unwired endpoints marked `// TODO(server): wire to ChallengeEndpoint.<method>` with `UnimplementedError` in try block, tests skipped until server lands
- **TODO(payment)**: Payment-related endpoints marked with `// TODO(payment): wire to PaymentEndpoint.<method>` — stub implementations that throw `UnimplementedError`

## Repository Structure

1. Domain — entities, enums, cubit states
   - Entities expose `Option<Failure> get validate` getter, chained via `andThen` (see HomeLeaderboardEntry.validate pattern in features/home)
2. Data — repository implementation (Serverpod-ready: constructor-injected Serverpod wrapper, RetryOptions, Talker; unwired endpoints throw UnimplementedError behind TODO(server) markers)
   - Implementations in data/repository/: `challenge_lifecycle_repository.dart`, `challenge_discovery_repository.dart`, `challenge_leaderboard_repository.dart` — each mirrors StepsRepository structure exactly: const constructor injecting Serverpod wrapper + RetryOptions + Talker; every method = TaskResult.tryCatch wrapping `_retry.retry(() => _serverpod.client.challenge.<method>())`; validate entities post-construction; _talker.handle errors; return Failure.serverpod
   - Endpoint calls not yet generated: `// TODO(server): wire to ChallengeEndpoint.<method>` + throw UnimplementedError inside the try block; related tests marked skip until server lands
   - **TODO(payment)**: Payment repository stubs in `challenge_payment_repository.dart` — interfaces defined but methods throw `UnimplementedError` until payment feature implemented

- **Failure handling (hybrid, mirrors HomeCubit)**:
  - Error mapping (Q68 Option A): centralized switch in `_failureHandler.handleException` — one-to-one mapping from server exception types to localized messages, never surface raw server text
    - Mapping table: `ChallengeFullException` → i18n `challenge.errors.challengeFull`, `ChallengeNotFound` → `challenge.errors.notFound`, `StepsNotSyncedException` → `challenge.errors.stepsNotSynced`, `ChallengeExpiredException` → `challenge.errors.expired`, `InvalidInviteCodeException` → `challenge.errors.invalidInviteCode`, etc.
    - **TODO(payment)**: Add payment-specific exceptions: `PaymentIntentException` → `challenge.errors.paymentFailed`, `PaymentCancelledException` → `challenge.errors.paymentCancelled`
    - All messages localized via `slang` keys under `challenge.errors.*`; technical codes (SQL/RPC) never surfaced
    - Reuses `HomeCubit.FailureHandler` pattern, extended for challenge-specific exceptions
- **Network vs Server errors (Q89 Option A)**:
  - Network errors (`Exception` — socket timeout, no internet): transient → presentation toast via `emitPresentation(showError(...))` → retryable
  - Server exceptions (typed `ChallengeFullException` etc): business logic → mapped via `handleException` to localized message
  - Both wrap in `safeRun(onException: _failureHandler.handleException)` but path differs: network → toast, server → state/error handling
    - Side effect union: `const factory ChallengeStateSideEffect.onException(Exception exception) = ChallengeStateException` (+ route-specific effects as needed). Matches HomeCubit pattern.
- **Per-Cubit Side Effects (Q2 — RESOLVED):** Each sub-route Cubit (`ChallengeExploreCubit`, `ChallengeDetailsCubit`, `ChallengeLeaderboardCubit`, `ChallengeCreateCubit`) emits its own presentation stream. Their respective screens handle side effects independently via `BlocSignalPresentationMixin`. Root `ChallengePage` listens only to `cubit.presentationStream` for enrollment-level errors (e.g., challenge-not-found on init). This matches the `HomeCubit` precedent and keeps each Cubit self-contained and testable.
    - Transient errors (join failed, network down, vote failed) → `_failureHandler.handleFailure(f)` in fold + `emitPresentation(ChallengeStateException(exception))` → screen-level listener shows toast/snackbar
    - Persistent layout errors stay IN state: `.initial(inviteCodeError: ...)` renders inline under invite textfield
    - All cubit methods wrap in `safeRun(onException: _failureHandler.handleException)`
- **Error behavior by state**:
  - `.initial` state errors: toast (user can retry action)
  - `.registered` state errors: toast + stay on `.registered` (Q146) — never reset to `.initial` on transient errors
  - `.done` state errors: toast (read-only, user navigates back)

## State Machine

- **`loading`** — initial fetch or refresh in progress
- **`initial(inviteCodeError: ..., isPremium:)`** — default state for non-enrolled user
- **`registered`** — user is enrolled in an active challenge (Q71 Option B)
  - Sub-states via sealed union (Q103):
    - `active` — normal competition
    - `validationWindow` — 24h dispute window open
    - `disputePending` — dispute filed, awaiting vote
    - `disputeUpheld` — dispute upheld, recalculating
    - `disputeRejected` — dispute rejected, payout ready
    - `completed` — challenge finished (winner/non-winner branches)
    - `cancelled` — challenge cancelled (host or auto)
- **`done(result)`** — post-challenge outcome screen (winner/non-winner)

## Cubit State (Freezed)

```dart
@freezed
class ChallengeState with _$ChallengeState {
  const factory ChallengeState.loading() = _Loading;
  const factory ChallengeState.initial({
    String? inviteCodeError,
    required bool isPremium,
  }) = _Initial;
  const factory ChallengeState.registered({
    required ChallengeDashboard dashboard,
  }) = _Registered;
  const factory ChallengeState.done({
    required ChallengeDoneResult result,
  }) = _Done;
}

// Side effects for presentation layer
@freezed
class ChallengeStateSideEffect with _$ChallengeStateSideEffect {
  const factory ChallengeStateSideEffect.onException(Exception exception) = ChallengeStateException;
}
```

## Repository Contract

Three split repositories mirror the three data concerns:

1. **`IChallengeLifecycleRepository`**
   - `getActiveChallengeSummary(session)` → `ChallengeSummary?`
   - `joinChallenge(session, challengeId)` → `ChallengeEntry`
   - `leaveChallenge(session, challengeId)` → `void`
   - `startPrivateChallenge(session, challengeId)` → `void`
   - `getLeaderboardPreview(session, challengeId, limit)` → `List<ChallengeLeaderboardEntry>`

2. **`IChallengeDiscoveryRepository`**
   - `listChallenges(session, filter)` → `List<ChallengeSummary>`
   - `getChallengeDetail(session, challengeId)` → `ChallengeDetail`
   - `validateInviteCode(session, code)` → `ChallengeDetail`

3. **`IChallengeLeaderboardRepository`**
   - `getLeaderboard(session, challengeId, page, limit)` → `LeaderboardPage`
   - `syncSteps(session, steps, source)` → `DailyStepTelemetry`

- **TODO(payment)**: `IPaymentRepository` stubs — interfaces defined in foundation, implementations deferred to payment feature:
  - `createPaymentIntent(session, challengeId)` → `PaymentIntent`
  - `getPaymentStatus(session, paymentId)` → `PaymentStatus`
  - `listPaymentAccounts(session)` → `List<PaymentAccount>`
  - `createPayoutAccount(session, account)` → `PayoutAccount`
  - `listPayoutAccounts(session)` → `List<PayoutAccount>`

## ChallengeCubit

```dart
class ChallengeCubit extends CubitSignal<ChallengeState> {
  ChallengeCubit(
    this._lifecycleRepo,
    this._discoveryRepo,
    this._leaderboardRepo,
    this._failureHandler,
  ) : super(const ChallengeState.loading()) {
    // TODO(payment): Inject payment repository when available
  }

  final IChallengeLifecycleRepository _lifecycleRepo;
  final IChallengeDiscoveryRepository _discoveryRepo;
  final IChallengeLeaderboardRepository _leaderboardRepo;
  final FailureHandler _failureHandler;
  // TODO(payment): final IPaymentRepository _paymentRepo;

  // ... methods
}
```

## Implementation Order

1. Domain — entities, enums, cubit state
2. Data — repository implementation (Serverpod-ready stubs)
3. Presentation — screens, widgets, routes
4. **TODO(payment)**: Payment integration (deferred)

## Checkpoint Definition

**Checkpoint (per plan):** `fvm dart format lib test` clean + codegen (`slang` → `build_runner`) compiles. NO commits during implementation (user commits manually when ready).

## Testing Strategy (Q83 Option A — phased)

**Foundation checkpoint (no server yet):**
- [ ] `dart format` clean
- [ ] Codegen (`slang` + `build_runner`) compiles

**Route checkpoints (01-05):**
- [ ] `fvm dart format lib test` clean
- [ ] Codegen (`slang` → `build_runner` → `serverpod generate`) compiles

**Mock contract (testing.md rules):** `mockito` ONLY — never `mocktail`. Generate mocks once in `test/utils/generated_mocks.dart` via @GenerateMocks/@GenerateNiceMocks and reuse across tests; register dummies with `provideDummy<T>` in setUpAll/flutter_test_config instead of custom wrappers.

## Files to Create/Modify

- [ ] `lib/features/challenge/domain/entity/challenge.dart`
- [ ] `lib/features/challenge/domain/entity/challenge_entry.dart`
- [ ] `lib/features/challenge/domain/entity/enum/challenge_status.dart`
- [ ] `lib/features/challenge/domain/entity/enum/reward_mode.dart`
- [ ] `lib/features/challenge/domain/entity/enum/tie_breaker.dart`
- [ ] `lib/features/challenge/domain/entity/enum/launch_type.dart`
- [ ] `lib/features/challenge/domain/cubit/challenge_cubit.dart`
- [ ] `lib/features/challenge/domain/cubit/state/challenge_state.dart`
- [ ] `lib/features/challenge/domain/cubit/state/challenge_state_side_effect.dart`
- [ ] `lib/features/challenge/domain/interface/i_challenge_lifecycle_repository.dart`
- [ ] `lib/features/challenge/domain/interface/i_challenge_discovery_repository.dart`
- [ ] `lib/features/challenge/domain/interface/i_challenge_leaderboard_repository.dart`
- [ ] `lib/features/challenge/data/repository/challenge_lifecycle_repository.dart`
- [ ] `lib/features/challenge/data/repository/challenge_discovery_repository.dart`
- [ ] `lib/features/challenge/data/repository/challenge_leaderboard_repository.dart`
- [ ] `lib/features/challenge/presentation/views/pages/challenge_page.dart`
- [ ] `lib/features/challenge/presentation/views/screens/challenge_initial_screen.dart`
- [ ] `lib/features/challenge/presentation/views/screens/challenge_registered_screen.dart`
- [ ] `lib/features/challenge/presentation/views/screens/challenge_done_screen.dart`
- [ ] `lib/features/challenge/presentation/widgets/challenge_card.dart`
- [ ] `lib/features/challenge/presentation/widgets/challenge_app_bar.dart`
- [ ] `lib/features/challenge/presentation/routes/challenge_routes.dart`
- [ ] **TODO(payment)**: `lib/features/challenge/data/repository/challenge_payment_repository.dart` (stub)

## Verification Checklist

- [ ] `dart analyze` — zero errors/warnings (--fatal-infos)
- [ ] `fvm dart format lib test` — clean
- [ ] Codegen (`slang` → `build_runner`) — compiles
- [ ] Routes typed and registered
- [ ] All entities expose `validate` getter
- [ ] All cubits use `initialState:` constructor
- [ ] All repo methods wrap in `TaskResult.tryCatch`
- [ ] **TODO(payment)**: Payment stubs throw `UnimplementedError` with clear markers
