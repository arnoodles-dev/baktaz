# 2026-08-22-00s Server Foundation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement `baktaz_server` challenge backend — `.spy.yaml` data models, `ChallengeEndpoint` RPC surface, scheduled lifecycle jobs, DI wiring, and DB migrations — fulfilling every `// TODO(server)` contract referenced by the Flutter challenge plans.

**Architecture:** Serverpod 2.x layered structure under `lib/src/features/challenge/` — `endpoint/`, `domain/`, `data/`. Models defined in `.spy.yaml`, codegen via `serverpod generate`, migrations via `create_migration` + `apply_migrations` MCP tools.

## Global Constraints
- Target package: `baktaz_server` (`lib/src/features/challenge/`)
- **Option B: Full Migration** — Challenge feature owns ALL lifecycle code. Existing `home/` feature challenge stubs are MIGRATED (not duplicated) to `challenge/`.
- No raw SQL; schema changes via migrations only
- PKs prefer `UuidValue` over `int`
- Endpoints return typed domain models, never raw `Map`/`dynamic`
- All config constants centralized in `lib/src/app/config/app_config.dart`
- **Money representation**: `double` (matches Wallet.cashBalance convention)
- Server repos THROW on failure; endpoints translate to client exceptions

## Implementation Order
This plan executes AFTER the Flutter feature is complete with `TODO(server)` stubs.

## Task 1: Data Models (.spy.yaml)

**Files:**
- Create: `baktaz_server/lib/src/features/challenge/domain/model/challenge.spy.yaml`
- Create: `baktaz_server/lib/src/features/challenge/domain/model/challenge_participant.spy.yaml`
- Create: `baktaz_server/lib/src/features/challenge/domain/model/invite_code.spy.yaml`
- Create: `baktaz_server/lib/src/features/challenge/domain/model/user_steps_info.spy.yaml`
- Create: `baktaz_server/lib/src/features/challenge/domain/model/anti_cheat_vote.spy.yaml`
- Create: `baktaz_server/lib/src/features/challenge/domain/model/dispute.spy.yaml`
- Create enum files under `lib/src/core/domain/model/enum/`

**Models:**
- `Challenge`: id, title, description, entryFeeAmount, durationDays, startAt, endAt, suddenDeathEndsAt, maxParticipants, minParticipants, dailyStepGoal, totalStepGoal, rewardMode, tieBreaker, launchType, status, hostAuthUserId, createdAt, updatedAt
- `ChallengeParticipant`: id, challengeId, authUserId, joinedAt, currentSteps, dailyGoalHitCount, lastSyncedAt, rankTrend, onHold, forfeited, suddenDeathEligible, payoutAmount, claimedAt
- `InviteCode`: id, code, challengeId, expiresAt
- `UserStepsInfo`: id, authUserId (unique), lastStepSyncAt
- `AntiCheatVote`: id, challengeId, targetAuthUserId, voterAuthUserId, approve, createdAt (unique: challengeId, targetAuthUserId, voterAuthUserId)
- `Dispute`: id, challengeId, filedByAuthUserId, reason, status, createdAt, resolvedAt

**Enums:**
- `RewardMode`: winnerTakesAll, top3TieredSplit, goalThresholdEqualProfitShare, milestoneHybrid
- `TieBreaker`: equalSplit, suddenDeath, consistencyMetric
- `LaunchType`: public, private
- `ChallengeStatus`: pendingLaunch, initialPhase, active, validationWindow, completed, archived, cancelled
- `AntiCheatStatus`: none, onHold, cleared, disqualified
- `DisputeStatus`: open, upheld, rejected
- `PayoutStatus`: pending, claimed, autoDisbursed

**Client exceptions:** `InvalidInviteCodeException`, `ChallengeFullException`, `ChallengeExpiredException`, `InsufficientWalletBalanceException`, `StepsNotSyncedException`, `EntryAlreadyExistsException`

- [ ] **Step 1:** Write all model files
- [ ] **Step 2:** Run `serverpod generate`
- [ ] **Step 3:** Verify generated client models appear in `baktaz_client/lib/src/protocol/`
- [ ] **Step 4:** Commit `feat(challenge): add server domain models and enums`

## Task 2: ChallengeEndpoint

**Files:**
- Create: `baktaz_server/lib/src/features/challenge/endpoint/challenge_endpoint.dart`
- Create: `baktaz_server/lib/src/features/challenge/data/repository/challenge_lifecycle_repository.dart`
- Create: `baktaz_server/lib/src/features/challenge/data/repository/challenge_discovery_repository.dart`
- Create: `baktaz_server/lib/src/features/challenge/data/repository/challenge_leaderboard_repository.dart`
- Modify: `baktaz_server/lib/src/app/injection/service_locator.dart`

Endpoint methods:
| Method | Signature | Rules |
|--------|-----------|-------|
| getActiveChallengeSummary | `(Session) → ActiveChallengeSummary?` | Authenticated; includes `hasArchived: bool` (Q121) |
| getArchiveChallenges | `(Session) → List<ChallengeArchive>` | Completed challenges where user was participant |
| getArchiveChallengeDetail | `(Session, UuidValue) → ChallengeCompletionResult` | Read-only |
| getChallengeDashboard | `(Session, UuidValue) → ChallengeDashboard` | Deepening Mandate 1: single query, eager-load challenge + top5 + user + rival |
| searchChallenges | `(Session, {query, feeRange, durations, modes, sortBy, offset, limit}) → List<ChallengeSummary>` | Offset pagination, filters status.inSet([pendingLaunch, initialPhase]) |
| validateInviteCode | `(Session, String) → ChallengeDetail` | Throws InvalidInviteCodeException / ChallengeExpiredException |
| getChallengeDetails | `(Session, UuidValue) → ChallengeDetail` | |
| joinChallenge | `(Session, UuidValue) → ChallengeParticipant` | Idempotent (unique constraint), txn: wallet ≥ fee → debit escrow → insert participant |
| leaveChallenge | `(Session, UuidValue)` | Pre-launch only; refund escrow |
| getLeaderboard | `(Session, UuidValue, {afterId, limit}) → List<ChallengeLeaderboardEntry>` | Cursor-based |
| getUserRank | `(Session, UuidValue) → UserRankSummary` | |
| syncSteps | `(Session, int) → void` | Update totals, recompute ranks, anti-cheat spike check |
| createChallenge | `(Session, ChallengeCreateRequest) → Challenge` | Requires Scope.premium |
| startPrivateChallenge | `(Session, UuidValue) → Challenge` | Host-only; debit escrow; status→active |
| claimPayout | `(Session, UuidValue) → WalletTransaction` | Q111 + Q139: debits escrow → credits wallet |
| voteAntiCheat | `(Session, UuidValue, UuidValue, bool) → void` | Insert vote; tally; pass/fail resolution |
| fileDispute | `(Session, UuidValue, String) → Dispute` | validationWindow only; triggers community vote |

- [ ] **Step 1:** Write failing integration test skeleton
- [ ] **Step 2:** Implement repository layer
- [ ] **Step 3:** Implement endpoint methods
- [ ] **Step 4:** Register DI
- [ ] **Step 5:** Unskip + pass integration tests

## Task 3: Scheduled Jobs & Lifecycle Triggers

**Files:**
- Create: `pending_challenge_cancellation_call.dart`
- Create: `public_phase_expiry_call.dart`
- Create: `validation_window_payout_call.dart`

Jobs:
1. **Pending auto-cancel**: private challenges past 30-day window → status cancelled
2. **Public phase expiry**: initialPhase past startAt → if min participants met → active; else cancel + refund
3. **Validation window** (Q101):
   - FutureCall #1 at `endAt`: compute winner(s), calculate payoutAmount
   - FutureCall #2 at `endAt + 24h`: check disputes, set status=completed
   - FutureCall #3 at `endAt + 24h + 30d`: auto-disburse if unclaimed
4. **Sudden death tie-breaker**: when tie detected, extend 24h for tied participants only

- [ ] **Step 1:** Write FutureCall classes
- [ ] **Step 2:** Register calls in server startup
- [ ] **Step 3:** Integration test each trigger path
- [ ] **Step 4:** Commit `feat(challenge): add lifecycle future calls`

## Task 4: Migrations & Flutter Wiring

- [ ] **Step 1:** Run `create_migration` (MCP tool) — review generated SQL
- [ ] **Step 2:** Run `apply_migrations` (MCP tool)
- [ ] **Step 3:** `tail_server_logs` sanity check
- [ ] **Step 4:** Wire every Flutter `// TODO(server)` call site to real client calls
- [ ] **Step 5:** Unskip previously-skipped Flutter data-layer tests
- [ ] **Step 6:** Commit `feat(challenge): wire flutter repos to live endpoints`
