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
- **TODO(chat)**: Event message dispatching deferred to Chat Module — add `// TODO(chat): dispatch event <eventKey>` markers at trigger sites

## Task 1: Data Models (.spy.yaml) & Serverpod Codegen

Create/migrate models:
- `challenges.spy.yaml`: fields: `id`, `name`, `description`, `entryFee: double`, `currency`, `prizePercentage: double` (default 90.0), `platformFeePercentage: double` (default 10.0), `hostCutPercentage: double` (default 0.5), `dailyStepCeiling: int` (default 30,000 — anti-cheat threshold), `dailyStepGoal: int?`, `totalStepGoal: int?`, `status: ChallengeStatus`, `startsAt: DateTime?`, `endsAt: DateTime?`, `createdAt`, `updatedAt`
- `challenge_participants.spy.yaml`: fields: `id`, `challengeId`, `authUserId`, `isHost: bool`, `status: ChallengeParticipantStatus`, `steps: int`, `rank: int?`, `entryFeePaid: bool`, `payoutAmount: double?`, `claimedAt: DateTime?`, `joinedAt: DateTime`
- `challenge_config.spy.yaml`: fields: `minDurationDays: int`, `maxDurationDays: int`, `maxParticipants: int`, `minEntryFee: double`, `maxEntryFee: double`, `maxHostCutPercentage: double`, `minParticipantsForPublic: int`, `minParticipantsForPrivate: int`, `minDailyStepCeiling: int`, `maxDailyStepCeiling: int`, `defaultDailyStepCeiling: int`

## Task 2: ChallengeEndpoint RPC Surface

Endpoints to implement:
- `getChallengeConfig(Session)` → `ChallengeConfig`: returns server-driven creation bounds
- `createChallenge(Session, Challenge)` → `Challenge`: validates `dailyStepCeiling` is within `[minDailyStepCeiling, maxDailyStepCeiling]`, creates challenge with status `draft`. `// TODO(chat): dispatch event 'challenge_created'`
- `joinChallenge(Session, UuidValue challengeId)` → `ChallengeParticipant`: checks capacity, validates invite code if private, creates participant. `// TODO(chat): dispatch event 'participant_joined'`
- `startPrivateChallenge(Session, UuidValue challengeId)` → `Challenge`: validates host, verifies min participants, transitions to `active`. `// TODO(chat): dispatch event 'private_started_early'` / `'challenge_started'`
- `leaveChallenge(Session, UuidValue challengeId)` → `void`: removes participant if initial phase. `// TODO(chat): dispatch event 'participant_left'`
- `syncSteps(Session, int steps, String source)` → `DailyStepTelemetry`: updates participant steps, runs anti-cheat check against challenge's `dailyStepCeiling` (flags `On Hold` if steps exceed ceiling). `// TODO(chat): dispatch event 'anti_cheat_flagged'`, `'user_synced_steps'`, `'rank_overtaken'`

## Task 3: Scheduled Jobs & Lifecycle FutureCalls

1. **Anti-cheat auto-detector**: runs on step sync. If participant's single-day step total > challenge `dailyStepCeiling` → sets status `onHold`, creates event alert. `// TODO(chat): dispatch event 'anti_cheat_vote_opened'`
2. **Phase transition worker**:
   - `initialPhase` end: if public → auto-start `active` (`// TODO(chat): dispatch event 'challenge_started'`); if private with < min participants → status `cancelled` (`// TODO(chat): dispatch event 'challenge_cancelled'`)
3. **Validation window**:
   - FutureCall #1 at `endAt`: compute winner(s), calculate payoutAmount. `// TODO(chat): dispatch event 'challenge_completed'`, `'validation_window_opened'`, `'sudden_death_started'`
   - FutureCall #2 at `endAt + 24h`: check disputes, set status `completed`. `// TODO(chat): dispatch event 'payout_ready'`
   - FutureCall #3 at `endAt + 24h + 30d`: auto-disburse if unclaimed. `// TODO(chat): dispatch event 'payout_disbursed'`
   - FutureCall #4 at `endAt + 24h`: process host cut. `// TODO(chat): dispatch event 'host_cut_paid'` / `'host_cut_forfeited'`

## Task 4: Migrations & Wiring

1. Run `create_migration` + `apply_migrations`
2. Remove old home challenge stubs
3. Wire Flutter `// TODO(server)` calls to endpoints
