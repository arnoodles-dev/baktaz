# 2026-08-22-00 Foundation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish the foundational challenge page infrastructure — domain entities, repository layer, Cubit state machine, typed navigation, and shared widget list — enabling all subsequent route plans to build on consistent foundations.

**Architecture:** 
- Domain layer: `@freezed` entities and enums for Challenge, RewardMode, TieBreaker, LaunchType
- Repository: three split repositories (`Lifecycle`, `Discovery`, `Leaderboard`) — Serverpod-ready (no mocks)
- State: `ChallengeCubit` extending `CubitSignal<ChallengeState>` with `initialState:` named constructor
- Navigation: `go_router` typed routes under `/challenge` (explore, detail, create, leaderboard)
- Shared widget list from spec 06-shared-models.md

**Tech Stack:** Flutter, Dart, bloc_signals, freezed, injectable, go_router, alchemist (goldens).

**Spec:** `docs/superpowers/specs/challenge/2026-08-22-00-overview.md` and `docs/superpowers/specs/challenge/2026-08-22-06-shared-models.md`

## Global Constraints
- Target package: `baktaz_flutter` (`lib/features/challenge`)
- Dart SDK >= 3.13.0
- Maximum file length: 400 lines
- Domain uses baktaz_shared Value Objects (`Money` for entry fee, `Number` for steps/participants/duration) + every entity exposes `Option<Failure> get validate` getter chained via andThen (HomeLeaderboardEntry pattern)
- Data layer is Serverpod-ready: constructor-injected `Client` from `baktaz_client`, no mock repositories; unwired endpoints marked `// TODO(server): wire to ChallengeEndpoint.<method>` with `UnimplementedError` in try block, tests skipped until server lands

## Implementation Order
1. Domain — entities, enums, VOs
2. Data — repository implementation (Serverpod-ready: constructor-injected Serverpod wrapper, RetryOptions, Talker; unwired endpoints throw UnimplementedError behind TODO(server) markers)
3. Presentation — screens, widgets, dialogs, goldens

## Tasks

- [ ] **Task 1: Domain Entities & Enums**
  - Create `domain/entity/` with `challenge_summary.dart`, `challenge_detail.dart`, `challenge_dashboard.dart`, `challenge_completion_result.dart`
  - Create `domain/entity/enum/` with `reward_mode.dart`, `tie_breaker.dart`, `launch_type.dart`, `challenge_status.dart`, `anti_cheat_status.dart`, `payout_status.dart`, `dispute_status.dart`
  - Entities expose `Option<Failure> get validate` getter, chained via `andThen` (see HomeLeaderboardEntry.validate pattern in features/home)

- [ ] **Task 2: Repository Interfaces**
  - Create `domain/interface/` with:
    - `i_challenge_lifecycle_repository.dart` — getActiveChallengeSummary, getChallengeDashboard, join/leave/create/startPrivate/claimPayout/voteAntiCheat/fileDispute
    - `i_challenge_discovery_repository.dart` — searchChallenges, validateInviteCode, getChallengeDetails
    - `i_challenge_leaderboard_repository.dart` — getLeaderboard, getUserRank
  - Mirror `IStepsRepository` structure

- [ ] **Task 3: Repository Implementations**
  - Implementations in data/repository/: `challenge_lifecycle_repository.dart`, `challenge_discovery_repository.dart`, `challenge_leaderboard_repository.dart` — each mirrors StepsRepository structure exactly: const constructor injecting Serverpod wrapper + RetryOptions + Talker; every method = TaskResult.tryCatch wrapping `_retry.retry(() => _serverpod.client.challenge.<method>())`; validate entities post-construction; _talker.handle errors; return Failure.serverpod
  - Endpoint calls not yet generated: `// TODO(server): wire to ChallengeEndpoint.<method>` + throw UnimplementedError inside the try block; related tests marked skip until server lands

- [ ] **Task 4: Cubit State & SideEffect**
  - Create `domain/cubit/challenge_cubit.dart` extending `CubitSignal<ChallengeState>` with `initialState:` named constructor
  - **Failure handling (hybrid, mirrors HomeCubit)**:
    - Mixin: `with BlocSignalPresentationMixin<ChallengeStateSideEffect, ChallengeState>`
    - Error mapping (Q68 Option A): centralized switch in `_failureHandler.handleException` — one-to-one mapping from server exception types to localized messages, never surface raw server text
      - Mapping table: `ChallengeFullException` → i18n `challenge.errors.challengeFull`, `InsufficientWalletBalanceException` → `challenge.errors.insufficientFunds`, `ChallengeNotFound` → `challenge.errors.notFound`, `StepsNotSyncedException` → `challenge.errors.stepsNotSynced`, `ChallengeExpiredException` → `challenge.errors.expired`, `InvalidInviteCodeException` → `challenge.errors.invalidInviteCode`, etc.
      - All messages localized via `slang` keys under `challenge.errors.*`; technical codes (SQL/RPC) never surfaced
      - Reuses `HomeCubit.FailureHandler` pattern, extended for challenge-specific exceptions
- **Network vs Server errors (Q89 Option A)**:
  - Network errors (`Exception` — socket timeout, no internet): transient → presentation toast via `emitPresentation(showError(...))` → retryable
  - Server exceptions (typed `ChallengeFullException` etc): business logic → mapped via `handleException` to localized message
  - Both wrap in `safeRun(onException: _failureHandler.handleException)` but path differs: network → toast, server → state/error handling
    - Side effect union: `const factory ChallengeStateSideEffect.onException(Exception exception) = ChallengeStateException` (+ route-specific effects as needed). Matches HomeCubit pattern.
- **Centralized (Q145 Option A)**: Root `ChallengePage` widget listens to `cubit.presentationStream` via `useEffect` + `StreamSubscription`, handles all `ChallengeStateException` → `FailureHandler.handleException()`. Child route screens (Explore, Details, Leaderboard, Create) do NOT need their own side effect listeners — unified error toast across entire challenge flow.
    - Transient errors (join failed, network down, vote failed) → `_failureHandler.handleFailure(f)` in fold + `emitPresentation(ChallengeStateException(exception))` → listener shows toast/snackbar
    - Persistent layout errors stay IN state: `.initial(inviteCodeError: ...)` renders inline under invite textfield
    - All cubit methods wrap in `safeRun(onException: _failureHandler.handleException)`
- **Error behavior by state**:
  - `.initial` state errors: toast (user can retry action)
  - `.registered` state errors: toast + stay on `.registered` (Q146) — never reset to `.initial` on transient errors
  - `.done` state errors: toast (read-only, user navigates back)
  - Define `ChallengeState` as freezed sealed union (Option B):
  ```dart
  @freezed
  sealed class ChallengeState with _$ChallengeState {
    // merged pre-check + in-flight enrollment check → renders skeleton.
    // isEnrolledHint comes from login-time enrollment check / cached session,
    // not from server roundtrip (avoids double-call on app start).
    const factory ChallengeState.loading({required bool isEnrolled}) = ChallengeStateLoading;
    // `loading` also covers transient sync states (step sync, vote in progress) — no separate syncing state (Q142)
    const factory ChallengeState.initial({
      required bool isPremium,
      String? inviteCodeError,
    }) = ChallengeStateInitial;
    const factory ChallengeState.registered({
      required ChallengeDashboard dashboard,  // aggregate: activeChallenge + leaderboardPreview + userRank
    }) = ChallengeStateRegistered;
    const factory ChallengeState.done({
      required ChallengeCompletionResult result,  // final outcome: winner/loser/payout status
    }) = ChallengeStateDone;
    // No failure state — errors handled via BlocSignalPresentationMixin + FailureHandler (Q142)
  }
  ```
  - State transitions:
    - `loading → initial` — enrollment check complete, no active challenge
    - `loading → registered` — enrollment check complete, active challenge found
    - `registered → initial` — user leaves challenge (pre-launch) OR claims payout (Q139) OR challenge completes (Q140)
    - `registered → done` — challenge completed (FutureCall #2), shows ChallengeDonePage
    - `done → initial` — user navigates back from ChallengeDonePage
    - `initial → registered` — user joins challenge via payment flow
  - `refresh()` (pull-to-refresh on registered view): dashboard-only fast path — calls `getChallengeDashboard()` directly. If server throws `ChallengeNotFound`/inactive-challenge, catch → fall back to full enrollment check pipeline (same code path as post-join entry) → emits `.initial(isPremium:)`. Happy path = 1 roundtrip; edge case reuses existing enrollment logic, no duplicated branches.
  - **Error during .registered (Q146 Option A)**: Toast via FailureHandler + stay on `.registered`. Never reset to `.initial` on transient errors. User context preserved.

- [ ] **Task 5: Cubit Methods (one per gesture, Q69 Option A)**
  - `init()` — trigger on mount; runs enrollment check; emits `.initial` or `.registered`
  - `refresh()` — pull-to-refresh on registered view
  - `joinByInviteCode(String code)` — validate invite code, navigate to details
  - `navigateToExplore()` — go to /challenge/explore
  - `navigateToCreate()` — go to /challenge/create
  - `navigateToPayment()` — handoff to payment feature

- [ ] **Task 6: Typed Routes**
  - Create `app/routes/challenge_routes.dart`
  - Register under existing `ChallengeBranch` in `app/routes/app_routes.dart`
  - Full-screen routes via `$parentNavigatorKey = RouteNavigatorKeys.root` + `SlideTransitionPage(fullscreenDialog: true)`
  - Routes: `ExploreRoute`, `DetailsRoute(String id)`, `LeaderboardRoute(String id)`, `CreateRoute`
  - Deep links pass `ChallengeSummary` seed to details screen (Q66)

- [ ] **Task 7: Root Page Widget**
  - Create `presentation/views/challenge_page.dart`
  - Reads `ChallengeCubit` state, renders `ChallengeInitialView` or `ChallengeRegisteredView`
  - Listens to `cubit.presentationStream` for side effects (Q145)
  - AppBar with history icon → archive section

- [ ] **Task 8: Shared Widget List**
  - Review `*_shared/lib/src/widgets/` for reusable components
  - List: `BaktazButton`, `BaktazText`, `BaktazCard`, `BaktazProgressBar`, `BaktazAvatar`, `BaktazTextField`, `Shimmer`, `ConfirmationDialog`
  - Create `presentation/widgets/` with challenge-specific widgets
  - Create `dialogs/` folder under `presentation/widgets/`
  - **Root widget (Q145)**: `ChallengePage` (or `ChallengeBranch` wrapper) listens to `cubit.presentationStream` → handles `ChallengeStateException` via `FailureHandler.handleException()`

## Ownership Rules (Deduplication)
- Domain entities, enums, repository interfaces/impls, Cubit state machine, typed routes, root page widget — OWNED BY THIS PLAN (foundation).
- All other plans (01–05) must reuse foundation-owned symbols; do NOT redefine entities, enums, or cubit state.
- If a route plan needs a new entity, check this plan first; add here if cross-route.

## Entity Field Split (Q71 Option A)
- `ChallengeSummary` (lightweight, for list views): id, title, hostName, entryFee, duration, description, slotsTotal, remainingSlots, status, launchType
- `ChallengeDetail` (full, for join/view): ChallengeSummary PLUS prizePool, prizeBreakdown, tieBreaker, rewardMode, suddenDeathActive, suddenDeathEndsAt, disputeOpen, isHost
- **Dashboard** (`ChallengeDashboard`, Q72 Option A): One deep query seam — `getChallengeDashboard(challengeId)` returns `{activeChallenge: ChallengeDetail, leaderboardPreview: List<ChallengeLeaderboardEntry>, userRank: int, rivalAbove: ChallengeLeaderboardEntry?}`
  - One roundtrip: single repo call loads challenge + top-5 leaderboard + current-user row + rival row
  - Rival = entry at `userRankPosition - 1` in leaderboardPreview
  - `rivalAbove = null` when user is rank 1

## Value Objects (Q74 Option A)
- `ChallengeSchedule` sealed union in domain: `dateRange({start: DateTime, end: DateTime})` | `durationDays({days: int})`
- Both public and private use `dateRange` UI; `durationDays` variant reserved for future
- **Duration slider (Q141)**: 30–120 days for both public and private

## Payment Success Screen (Q80 Option A)
- **ChallengePaymentSuccessScreen** ("Race Ticket") always shows: trophy header + STARTS IN countdown hero (if challenge hasn't started) + YOUR ENTRY receipt ledger (entry fee, start date, end date)
- Private challenges also show invite code plaque with copy/share actions
- Closing screen → `context.go('/challenge')` → enrollment recheck → `.registered`

## Server Migration Pattern (Q88 Option B — thin facade)
- `home/ChallengeRepository` becomes thin facade: injects all three challenge repos, forwards calls
- `HomeEndpoint` keeps same signatures but calls `ChallengeEndpoint` internally
- Flutter app untouched — same `client.home.*` calls

## AppConfig Challenge Constants (Q82 Option A)
Centralized in `lib/src/app/config/app_config.dart`:
- `initialPhaseMinDays`, `initialPhaseMaxDays`
- `disputeWindowHours` (default 24)
- `maxAppFeePercentage` (0.10), `maxHostCutPercentage` (0.05)
- `leaderboardPageSize` (50), `searchMaxPageSize` (100), `searchDefaultPageSize` (20)
- `challengeTimeoutSeconds` (30)
- `payoutDelayDays` (30)
- `publicInitialPhaseMinDays` (2), `publicInitialPhaseMaxDays` (14)
- `privateInitialPhaseMinDays` (1), `privateInitialPhaseMaxDays` (30)
- `pendingAutoCancelDays` (30)
- `maxStepSyncStalenessHours` (24)
- `maxStepSpikeThreshold` (5000), `maxStepRatePerHour` (10000)
- `maxArchiveSize` (100)

## LaunchType Enum (Q94 Option A)
- `public` — open to anyone; auto-starts at `startAt` if min participants met
- `private` — invite-only; host manually starts via `startPrivateChallenge`; can archive/cancel before launch

## RewardMode Enum (Q93 Option A)
- `winnerTakesAll` — first place takes entire prize pool
- `top3TieredSplit` — top 3 split prize (1st/2nd/3rd percentages set by host)
- `goalThresholdEqualProfitShare` — all participants who hit step goal split prize equally
- `milestoneHybrid` — tiered base + bonus for reaching milestones

## TieBreaker Enum (Q92 Option A)
- `equalSplit` — tied participants split prize equally
- `suddenDeath` — 24h extension for tied leaders only
- `consistencyMetric` — most days hitting daily step goal wins tie

## AntiCheat Status Enum (Q91 Option A)
- `none` — participant in good standing
- `onHold` — steps frozen, pending community vote
- `cleared` — vote passed, steps resume
- `disqualified` — vote failed, entry fee forfeited, moved to bottom

## Challenge Status Enum (Q90 Option A)
- `pendingLaunch` — challenge created, waiting for startAt
- `initialPhase` — signup window open
- `active` — challenge in progress
- `suddenDeath` — sub-state of active, tied participants only
- `validationWindow` — 24h after endAt, dispute window
- `completed` — challenge finished, payout distributed
- `archived` — user-viewable history
- `cancelled` — challenge cancelled (auto or manual)

Transitions: `pendingLaunch` → `initialPhase` → `active` → `completed`/`cancelled`. `suddenDeath` is sub-state of `active`. `disputed` is intermediate.

## Server Migration Notes
- `IChallengeRepository` (home/) → `IChallengeLifecycleRepository` (challenge/)
- `ActiveChallengeSummary` → `ChallengeDashboard` (enriched with leaderboard + rival)
- `HomeLeaderboardEntry` → `ChallengeLeaderboardEntry` (added `rankTrend`, `onHold`, `forfeited`)
- Existing `home/` stubs keep their signatures; implementation delegates to challenge repos

## Payout Distribution (Q102 Option A)
- Prize pool = sum of all entry fees collected
- App fee = entryFee × `appFeePercentage` (host-configurable, capped by `AppConfig.maxAppFeePercentage`)
- Host cut = entryFee × `hostCutPercentage` (host-configurable, capped by `AppConfig.maxHostCutPercentage`)
- Net to winner(s) = prizePool - appFee - hostCut
- Distribution per reward mode:
  - `winnerTakesAll`: 100% to 1st place
  - `top3TieredSplit`: host-configured percentages for 1st/2nd/3rd
  - `goalThresholdEqualProfitShare`: equal split among all who hit goal
  - `milestoneHybrid`: tiered base + bonus for milestones

## Challenge Completion Result (Q115 Option A)
`ChallengeCompletionResult` freezed entity:
- `winner: bool`
- `finalRank: int`
- `totalSteps: int`
- `payoutAmount: double?` (null for non-winners)
- `payoutStatus: PayoutStatus` (pending/claimed/autoDisbursed)
- `challengeId: UuidValue`
- `completedAt: DateTime`

## Challenge Archive Entity & Server (Q120 Option A)
- `ChallengeArchive` DTO (not DB entity — derived from completed challenges)
- Fields: `challengeId`, `title`, `completedAt`, `finalRank`, `payoutAmount`, `isHost`, `status` (completed/cancelled)
- Server endpoint: `getArchiveChallenges(session) → List<ChallengeArchive>`
- Server endpoint: `getArchiveChallengeDetail(session, challengeId) → ChallengeCompletionResult`
- Client repo: `getArchiveChallenges()` + `getArchiveChallengeDetail(id)`
- **UI**: User sees archive section on `ChallengeInitialView` when `hasArchived == true` (bundled in enrollment check response)
- Archive button on root view (not on ChallengeDonePage)
- **ChallengeDonePage read-only from archive (Q132 Option A)**: All action buttons hidden (Claim Payout, Thanks for Participating, Leave). Pure view.

## Archive Button Visibility (Q121 Option A)
- `getActiveChallengeSummary()` includes `hasArchived: bool` (bundled, no extra roundtrip)
- Button shown on `ChallengeInitialView` ONLY when `hasArchived == true`
- Click → `ChallengeArchiveScreen` (full-screen, vertical cards)

## Dispute = Anti-Cheat Vote (Q127 Option A)
- Same vote mechanism for both auto-detect and manual dispute
- Participants vote via simple majority (50% + 1 threshold)
- **UI**: `ModalBottomSheet` (not full route) — step-log timeline + accused card + Innocent/Cheater buttons + live result bar (Q138 Option A)
  - Dismissable (unlike other mandatory dialogs)
  - CTA on challenge card deep-links to this sheet
  - Live result bar updates on vote
  - Button disabled after voted (or window closed)
- Threshold: `floor(eligibleVoters / 2) + 1`
- Eligible voters: all active participants excluding flagged user
- Pass (Innocent): remove onHold, resume steps
- Fail (Cheater): forfeit entry fee, move to bottom, bar from new joins until challenge ends

## Anti-Cheat Auto-Detection (Q126 Option A)
Server detects anomalies automatically:
- Spike > 5000 steps in 1 hour
- Duplicate timestamps
- Rate > 10,000 steps/hour
- Zero steps for > 3 consecutive days
→ Places suspect on `onHold` status, emits voting alert

## StepsNotSyncedDialog (Q135 Option A)
When user taps "Join Challenge" without recent step sync:
- **Dialog**: `ConfirmationDialog` pattern
  - Title: "Sync your steps"
  - Message: "Connect your health tracker to join this challenge. Your steps won't count until synced."
  - Primary CTA: "Go to Sync Settings" → navigates to `/account` (Sync Settings section)
  - Secondary: "Cancel" → back to details
- **After sync**: User returns and retries join. Server re-validates `lastStepSyncAt`.

## Step Sync Validation (Q123 Option A + Q137 Model Location)
- Server checks `lastStepSyncAt` staleness vs `AppConfig.maxStepSyncStaleness` (24h) during `joinChallenge`
- **Model**: `UserStepsInfo` (.spy.yaml) — one-to-one link to account (`authUserId`, unique index)
  - Fields: `lastStepSyncAt: DateTime`; future-proof for step aggregates (totalSteps, streaks) without touching UserInfo
  - Created lazily on first `syncSteps`; missing row = never synced → stale check fails
- **Server check** in `joinChallenge`: load `UserStepsInfo` by authUserId, verify `lastStepSyncAt` within `AppConfig.maxStepSyncStaleness` (default 24h)
- **UI**: `StepsNotSyncedDialog` (see Q135 above)

## Server Optimizations (Q122 Option A)
- Leaderboard cached in `session.caches.local` for 5 minutes
- Cache invalidated on: join, leave, step sync, challenge end
- **No cache** for enrollment check (real-time required)
- Single query for dashboard: `challenge` + `participants` (top 5 + current user + rival) eager-loaded

## ChallengeDonePage — Read-Only from Archive (Q132 Option A)
When user taps archive entry → re-opens ChallengeDonePage in read-only mode:
- **All action buttons hidden**: Claim Payout, Thanks for Participating, Leave
- Winner: Payout Seal (gold/silver depending on rank) + transaction record
- Non-winner (Q140): Subdued seal + "Thanks for Participating" (read-only) → cubit resets to `.initial(isPremium:)` after view dismissed
- Payout claimed: green checkmark seal + transaction record
- Payout auto-disbursed: clock icon seal + transaction record
- Back button → archive list

## ChallengeArchiveScreen Layout (Q131 Option A)
- Full-screen page, vertical list of challenge cards
- Each card: challenge name, date, final rank badge, payout amount (if winner)
- Tap card → ChallengeDonePage (read-only)
- **No empty state** — archive screen only accessible when `hasArchived = true` (Q121). User can't reach it with zero completed challenges.
- History icon in AppBar → opens this screen

## Archive Flow (Q119 Option A)
- Archive button on `ChallengeInitialView` (not ChallengeDonePage)
- When user is NOT enrolled in any active challenge, `ChallengeInitialView` shows Archive section
- Archive entry: challenge card with final rank, payout amount, date
- Tap → ChallengeDonePage (read-only)
- Unarchive: not supported — archived = permanent

## AppBar Actions (Q118 Option B)
- **Disputed view** (validationWindow with open disputes): "File Dispute" text button in AppBar (not overflow menu)
- **Active/initialPhase view**: "Share" (invite code copy) + "Rules" (bottom sheet) buttons
- **Host view**: same + "Start Challenge Now" (private, initialPhase only)
- Dispute dialog (Q129 A): multi-select participants (max 5) + reason textarea (min 10 chars). One dispute per participant per challenge.

## ChallengeRegisteredPage — Pending Launch (Q128 Option A)
When user is enrolled in a `pendingLaunch` challenge, ChallengeRegisteredPage renders (NOT ChallengeInitialPage). Same dashboard structure. Changes:
- **Prize pool**: Shows **current** prize pool (changes as participants join — live update)
- **Leaderboard**: "Challenge starts on [date]" instead of live ranking
- **Leave**: Enabled but shows non-refundable disclaimer (Q81 override)
- **Host**: "Start Challenge Now" button visible if private + min participants met

## Challenge End Flow (Q101 Option B — REVISED)
- `endAt` reached → status `validationWindow`; steps FROZEN
- **FutureCall #1** at `endAt`: compute winner(s) per reward mode + tie-breaker → calculate payout amounts → store on ChallengeParticipant (PRE-COMPUTE during dispute window)
- **FutureCall #2** at `endAt + 24h`: check for disputes
  - None → set status `completed`, make "Claim Payout" button available
  - Disputes filed → wait for resolution, then set status `completed` and show button
- **Auto-disbursement (FutureCall #3)**: If winner doesn't claim within 30 days of button appearing, automatically disburse funds
- UI buttons appear AFTER FutureCall #2 completes

## UI States for Challenge End Flow (Q114)
- **active**: Normal dashboard (leaderboard + Gap Meter + Leave)
- **validationWindow**: "Validation & Dispute Window" banner (24h countdown), Leave disabled, File Dispute CTA
- **disputePending**: "Dispute Pending" banner + explanation, no actions until resolved
- **disputeUpheld**: "Dispute Upheld - Recalculating" banner, new winner computation triggered
- **disputeRejected**: "Dispute Rejected" banner + Claim Payout activates
- **completed + Winner**: **"Claim Payout"** button → REAL ACTION: calls `claimPayout` endpoint, debits escrow → credits wallet, shows confirmation
- **completed + Non-Winner (Q140)**: **"Thanks for Participating"** button (read-only) + archive → cubit resets to `.initial(isPremium:)` after view dismissed
- **post-claim (Q139)**: After user claims payout → cubit resets to `.initial(isPremium:)` — user returns to Trophy Case to join/explore another challenge.
- **auto-disbursed**: If winner doesn't claim within 30 days → FutureCall #3 auto-credits wallet → same `.initial` reset as claim

## Dispute Outcome Enum (Q117 Option A)
- `none` — no dispute filed
- `open` — dispute filed, voting in progress
- `upheld` — dispute accepted, results recalculated
- `rejected` — dispute dismissed, payout proceeds

## Payout Status Enum (Q116 Option A)
- `pending` — winner computed, funds in escrow, "Claim Payout" button available
- `claimed` — winner claimed payout, funds transferred to wallet
- `autoDisbursed` — user never claimed, FutureCall #3 triggered automatic disbursement

## Cancelled Challenges in Explore (Q134 Option A)
- Cancelled challenges are **hidden from explore list entirely** (`searchChallenges` filters `status.inSet([pendingLaunch, initialPhase])` — cancelled excluded)
- Only visible in archive with "Cancelled" badge

## Cancelled Challenges (Q133 Option A)
**Challenge can ONLY be cancelled during initial phase (before launch):**
- **Auto-cancel**: If minimum participants not met by end of initial phase → status `cancelled`
- **Manual cancel**: Host can cancel during initial phase → status `cancelled`
- **Post-launch**: Challenge CANNOT be cancelled. Users can leave (non-refundable).
- **Refund**: All participants get entry fee refunded to wallet (WalletTransactions credit)
- **Archive**: Cancelled challenges show in archive with "Cancelled" badge
- **No active view**: Cancelled challenges hidden from dashboard

## Pagination Strategy
- **Leaderboard** (`getLeaderboard`): Cursor-based — `UuidValue? afterId` parameter, `orderBy: (t) => t.totalSteps.desc(), t.id.asc()`, `limit: 50`. Flutter infinite scroll loads next page when `lastId` detected.
- **Infinite scroll threshold (Q143 Option B)**: Distance-based (3 items from bottom), NOT time-based (500ms). More reliable for fast/slow scrollers. — `UuidValue? afterId` parameter, `orderBy: (t) => t.totalSteps.desc(), t.id.asc()`, `limit: 50`. Flutter infinite scroll loads next page when `lastId` detected.
- **Search** (`searchChallenges`): Offset-based — `int offset = 0, int limit = 20`. User-driven, offset acceptable. Hard cap via AppConfig.maxPageSize (default 100).
- **Search** (`searchChallenges`): Offset-based — `int offset = 0, int limit = 20`. User-driven, not scrolling, offset acceptable.
- All pagination methods include `limit` capped at AppConfig maxPageSize (default 100).

## Idempotency (Q75 Option B)
- Unique `(challengeId, authUserId)` on `challenge_participants`
- Duplicate INSERT → `DataInsertException` → caught in repository → returns existing participant (no double-debit)
- UI `isLoading` complements (no double-tap)
- No client-side idempotency key needed

## Sudden Death Banner & Leaderboard (Q87 + Q136 Option A)
- Red "⚡ SUDDEN DEATH" banner during extension (challenge.suddenDeathActive == true)
- Countdown to suddenDeathEndsAt
- **Leaderboard filters to tied participants ONLY** — others greyed out with "eliminated from tie-break" note
- Tied participants' steps update live — creates tension
- No separate view — same dashboard with banner overlay
- After extension ends: full leaderboard restores, winner(s) marked

## Initial Phase Behavior (Q86 Option A)
- Same dashboard view for all phases (no separate "waiting" view)
- Public challenges auto-start at `startAt` (no host action needed)
- Private challenges in initial phase show `Start Challenge Now` button on Host Management Card (calls `startPrivateChallenge` endpoint)
- No special "waiting" view — just conditional action button

## Host Management Card (Q85 Option A)
- Visible when `activeChallenge.isHost == true`
- Three actions (MVP scope):
  1. **Share Invite Code** (private challenges only) → copy to clipboard + share sheet
  2. **Start Challenge Now** (private, initialPhase, min participants met) → calls `startPrivateChallenge`
  3. **View Full Leaderboard** → push `LeaderboardRoute(id)` full-screen
- Edit/Pause/Delete deferred to future (complex participant-impact semantics)
- Leave Challenge: handled by global "Leave Challenge" button (disabled for hosts)

## Empty State Handling (Q84 Option A)
- Explore list empty: "No challenges match your filters" + Clear Filters CTA (resets ExploreFilter to defaults, refetches page 1)
- Leaderboard/dashboard: never empty (host participates, single-enrollment gate)

## Cubit Method Surface (Q69 Option A — one method per gesture)
**ChallengeCubit:**
- `init()` — trigger on mount; runs enrollment check
- `refresh()` — pull-to-refresh (dashboard fast path)
- `joinByInviteCode(String code)` — validate + navigate to details
- `navigateToExplore()` — go to /challenge/explore
- `navigateToCreate()` — go to /challenge/create
- `navigateToPayment()` — handoff to payment feature

**ExploreCubit:**
- `init()` — load page 1 with default filters
- `refresh()` — reset cursor, refetch page 1
- `applyFilter(ExploreFilter filter)` — set filter, reset cursor, refetch page 1
- `search(String query)` — set query, reset cursor, refetch page 1
- `loadMore()` — load next page with cursor
- `navigateToDetails(ChallengeSummary summary)` — pass seed to details

**DetailsCubit:**
- `init(ChallengeSummary seed)` — load page 1 with default filters
- `refresh()` — reset cursor, refetch page 1
- `joinChallenge()` — trigger payment flow
- `navigateToPayment()` — handoff to payment feature

**LeaderboardCubit:**
- `init()` — load page 1 with default filters
- `refresh()` — reset cursor, refetch page 1
- `changeSort(LeaderboardSort sort)` — reset cursor, refetch page 1
- `changeSearch(String query)` — reset cursor, refetch page 1
- `loadMore()` — load next page with cursor

## Execution Sequencing (approved, Q100)
`00-foundation → 01-root → 02-discovery → 03-details → 04-leaderboard → [TEST PHASE] → 05-create → 06-verification`

- Foundation: entities, repos, cubit, routes, root page
- Root page: ChallengeInitialView + ChallengeRegisteredView
- Discovery: ChallengeExploreScreen + filter sheet
- Details: ChallengeDetailsScreen + payment flow
- Leaderboard: ChallengeLeaderboardPage
- Create: ChallengeCreateScreen (deferred — payment feature out of scope)
- Verification: format, analyze, codegen, tests

## Checkpoint Definition
**Checkpoint (per plan):** `fvm dart format lib test` clean + `dart analyze` zero errors (--fatal-infos) + codegen (`slang` → `build_runner` → `serverpod generate`) compiles. NO commits during implementation (user commits manually when ready).

## Testing Strategy (Q83 Option A — phased)

**Foundation checkpoint (no server yet):**
- [ ] `dart format` clean
- [ ] `dart analyze` — zero errors/warnings (--fatal-infos)
- [ ] Codegen (`slang` + `build_runner`) compiles

**Route checkpoints (01-05):**
- [ ] `fvm dart format lib test` clean
- [ ] `dart analyze` — zero errors/warnings (--fatal-infos)
- [ ] Codegen (`slang` → `build_runner` → `serverpod generate`) compiles

**Dedicated Test Phase (after all routes):**
- [ ] Repository unit tests (TaskResult folding, retry, mock serverpod client) — 100% target
- [ ] Integration tests (serverpod_test withServer) — server must be running
- [ ] Full golden test suite
- [ ] Coverage audit → target ≥80% overall

**Mock contract (testing.md rules):** `mockito` ONLY — never `mocktail`. Generate mocks once in `test/utils/generated_mocks.dart` via @GenerateMocks/@GenerateNiceMocks and reuse across tests; register dummies with `provideDummy<T>` in setUpAll/flutter_test_config instead of custom wrappers.
